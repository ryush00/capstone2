class FetchPostDetailJob < ApplicationJob
  require 'faraday'
  require 'nokogiri'
  
  queue_as :default

  # 사이버캠퍼스 상수
  BASE_URL = 'https://cyber.wku.ac.kr/Cyber/ComBoard_V005/Content'.freeze
  
  # 특정 게시글의 상세 내용을 크롤링합니다
  # @param post_id [Integer] 크롤링할 게시글의 ID
  # @param limit [Integer] 한 번에 처리할 최대 게시글 수, 기본값은 1
  def perform(post_id = nil, limit = 1)
    if post_id.present?
      # 특정 게시글만 처리
      post = Post.find_by(id: post_id)
      process_post(post) if post.present?
    else
      # 처리된 게시글 수 추적
      processed_count = 0
      
      # 지정된 limit만큼 게시글 처리
      Rails.logger.info "최대 #{limit}개의 게시글 상세 정보 크롤링 시작"
      
      # limit 수만큼 반복
      limit.times do |i|
        # 트랜잭션 내에서 FOR UPDATE SKIP LOCKED를 사용하여 처리할 게시글 가져오기
        post = nil
        
        Post.transaction do
          # 상세 정보가 없는 게시글 중 하나를 선택하고 잠금 설정
          # FOR UPDATE로 레코드를 잠그고 SKIP LOCKED로 이미 잠긴 레코드는 건너뜀
          post = Post.where(posted_date: nil)
                     .order(created_at: :desc)
                     .lock("FOR UPDATE SKIP LOCKED")
                     .first
          
          if post.present?
            process_post(post)
            processed_count += 1
          end
        end
        
        # 더 이상 처리할 게시글이 없으면 반복 중단
        break if post.nil?
        
        # 서버에 부담을 주지 않도록 요청 사이에 짧은 대기 시간 추가
        sleep(1) if i < limit - 1 && post.present?
      end
      
      if processed_count > 0
        Rails.logger.info "총 #{processed_count}개의 게시글 상세 정보 크롤링 완료"
      else
        Rails.logger.info "처리할 게시글이 없습니다"
      end
    end
  end
  
  private
  
  # 개별 게시글의 상세 정보를 크롤링합니다
  # @param post [Post] 처리할 게시글 객체
  def process_post(post)
    Rails.logger.info "게시글 상세 정보 크롤링 시작: #{post.title} (ID: #{post.id}, CID: #{post.cid})"
    
    # 게시글 URL (view.jsp는 POST 요청 필요)
    url = "#{BASE_URL}/view.jsp"
    
    begin
      # POST 요청 보내기
      response = Faraday.post(url) do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.body = "gid=#{post.gid}&bid=#{post.bid}&cid=#{post.cid}&lpage=1"
      end
      
      if response.status == 200
        # HTML 파싱
        doc = Nokogiri::HTML(response.body)
        
        # 게시글 내용 추출 (여러 선택자 시도)
        content_html = ""
        
        # 1. 기본 bbs-div-kcy 선택자 시도
        if doc.css('div.bbs-div-kcy').any?
          content_html = doc.css('div.bbs-div-kcy').to_s
        # 2. 이미지가 직접 삽입된 경우
        elsif doc.css('div.row-fluid div.span12 div[style="padding-left:5px"] img').any?
          img_container = doc.css('div.row-fluid div.span12 div[style="padding-left:5px"]')
          content_html = img_container.to_s
        # 3. 그 외 내용이 있을 수 있는 요소
        elsif doc.css('div.viewbox div.content, div.viewbox div.cont, div#viewContent').any?
          content_html = doc.css('div.viewbox div.content, div.viewbox div.cont, div#viewContent').first.to_s
        # 4. 마지막으로 3번째 row-fluid 확인 (일반적인 내용 위치)
        elsif doc.css('div.row-fluid')[2]
          content_div = doc.css('div.row-fluid')[2]
          # 내용이 실제로 있는지 확인
          if content_div.css('img').any? || content_div.text.strip.length > 50
            content_html = content_div.to_s
          end
        end
        
        # 내용이 여전히 없으면 제목을 추출하고 내용 없음 알림
        if content_html.blank?
          title_element = doc.css('div.row-fluid div.span12 p').first
          title = title_element ? title_element.text.strip : "제목 없음"
          content_html = "<p>이 게시글은 내용이 없거나 추출할 수 없는 형식입니다.</p>"
          Rails.logger.warn "게시글 내용을 추출할 수 없습니다: #{title} (CID: #{post.cid})"
        end
        
        # 작성자 정보 추출
        author_info_element = doc.css('div.row-fluid div.span12').first
        if author_info_element
          # 이메일 링크에서 ID와 이메일 추출
          email_link = author_info_element.css('a[href^="mailto:"]').first
          if email_link
            author_id = email_link.text.strip
            author_email = email_link['href'].sub('mailto:', '')
          end
          
          # 날짜 정보 추출
          author_text = author_info_element.text.strip.gsub(/\s+/, ' ')
          date_match = author_text.match(/등록일\s*:\s*(\d{4}년\s*\d{2}월\s*\d{2}일\s*\d{2}시\s*\d{2}분\s*\d{2}초)/)
          
          if date_match
            # 한국어 날짜 형식을 DateTime으로 변환
            begin
              date_str = date_match[1]
              date_str = date_str.gsub(/년|월/, '-').gsub(/일/, ' ').gsub(/시|분/, ':').gsub(/초/, '')
              date_str = date_str.gsub(/\s+/, ' ').gsub(/- /, '-').gsub(/: /, ':').strip
              posted_date = DateTime.parse(date_str)
            rescue ArgumentError=> e
              posted_date = nil
              Rails.logger.warn "날짜 파싱 실패: #{date_match[1]}"
            end
          end
        end
        
        # 첨부파일 정보 추출
        attachment_urls = []
        attachment_names = []
        
        doc.css('ul.filelist li a').each do |attachment|
          name = attachment.text.strip
          download_link = attachment['href']
          
          if name.present? && download_link.present?
            attachment_names << name
            attachment_urls << "https://cyber.wku.ac.kr#{download_link}" if download_link.start_with?('/')
          end
        end
        
        # 게시글 업데이트
        post.content = content_html
        post.posted_date = posted_date if posted_date.present?
        post.author_id = author_id if author_id.present?
        post.author_email = author_email if author_email.present?
        post.attachment_urls = attachment_urls
        post.attachment_names = attachment_names
        post.last_updated_at = Time.current
        
        if post.save
          Rails.logger.info "게시글 상세 정보 업데이트 완료: #{post.title}"
        else
          Rails.logger.error "게시글 상세 정보 업데이트 실패: #{post.errors.full_messages.join(', ')}"
        end
      else
        Rails.logger.error "게시글 페이지 가져오기 실패. 상태 코드: #{response.status}"
      end
    rescue => e
      Rails.logger.error "게시글 상세 크롤링 중 오류 발생: #{e.message}\n#{e.backtrace.join("\n")}"
    end
  end
end
