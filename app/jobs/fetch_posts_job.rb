class FetchPostsJob < ApplicationJob
  require "faraday"
  require "nokogiri"

  queue_as :default

  # 사이버캠퍼스 상수
  BASE_URL = "https://cyber.wku.ac.kr/Cyber/ComBoard_V005/Content".freeze
  GID = "1115983888724".freeze
  BID = "1115985252888".freeze

  # 게시글 목록 페이지를 크롤링하고 게시글 레코드를 업서트합니다
  # @param page [Integer] 크롤링할 페이지 번호, 기본값은 1
  def perform(page = 1)
    Rails.logger.info "페이지 #{page}에서 게시글 크롤링 시작"

    # 페이지 URL 구성
    url = "#{BASE_URL}/list.jsp?gid=#{GID}&bid=#{BID}"
    url += "&lpage=#{page}" if page > 1

    begin
      # 페이지 가져오기
      response = Faraday.get(url)

      if response.status == 200
        # HTML 파싱
        doc = Nokogiri::HTML(response.body)

        # 처리된 게시글 수 추적
        posts_count = 0

        # 공지사항 처리
        doc.css("tr.notice").reverse_each do |row|
          process_notice_post(row)
          posts_count += 1
        end

        # 일반 게시글 처리
        doc.css("table.table tbody tr").reverse_each do |row|
          # 헤더 행과 공지 게시글은 건너뜀
          next if row.css("th").any? || row["class"]&.include?("notice")

          process_regular_post(row)
          posts_count += 1
        end

        Rails.logger.info "페이지 #{page}에서 #{posts_count}개의 게시글을 성공적으로 처리했습니다"
      else
        Rails.logger.error "페이지 가져오기 실패. 상태 코드: #{response.status}"
      end
    rescue => e
      Rails.logger.error "게시글 크롤링 중 오류 발생: #{e.message}\n#{e.backtrace.join("\n")}"
    end

    FetchPostDetailJob.perform_later(nil, 30) if page == 1
  end

  private

  # 공지사항 게시글을 처리하고 데이터베이스에 업서트합니다
  # @param row [Nokogiri::XML::Element] 게시글의 테이블 행 요소
  def process_notice_post(row)
    cid = extract_cid(row.css("td:nth-child(3) a").attr("href")&.to_s)
    return if cid.blank?

    # 원본 URL 생성
    source_url = "#{BASE_URL}/print.jsp?gid=#{GID}&bid=#{BID}&cid=#{cid}"

    # 게시글 속성 구성 (view에서만 확인 가능한 정보는 제외)
    # posted_at은 목록에서는 정확도가 낮으므로 FetchPostDetailJob에서 처리
    post_attributes = {
      title: row.css("td:nth-child(3) a").text.strip,
      author_name: row.css("td:nth-child(2)").text.strip,
      view_count: row.css("td:nth-child(5)").text.strip.to_i,
      is_notice: true,
      cid: cid,
      gid: GID,
      bid: BID,
      source_url: source_url,
      scraped_at: Time.current
    }

    # 게시글 업서트
    upsert_post(post_attributes)
  end

  # 일반 게시글을 처리하고 데이터베이스에 업서트합니다
  # @param row [Nokogiri::XML::Element] 게시글의 테이블 행 요소
  def process_regular_post(row)
    cid = extract_cid(row.css("td:nth-child(3) a").attr("href")&.to_s)
    return if cid.blank?

    # 원본 URL 생성
    source_url = "#{BASE_URL}/print.jsp?gid=#{GID}&bid=#{BID}&cid=#{cid}"

    # 게시글 속성 구성 (view에서만 확인 가능한 정보는 제외)
    post_attributes = {
      title: row.css("td:nth-child(3) a").text.strip,
      author_name: row.css("td:nth-child(2)").text.strip,
      view_count: row.css("td:nth-child(5)").text.strip.to_i,
      is_notice: false,
      cid: cid,
      gid: GID,
      bid: BID,
      source_url: source_url,
      scraped_at: Time.current
    }

    # 게시글 업서트
    upsert_post(post_attributes)
  end

  # viewGo JavaScript 함수에서 게시글 CID를 추출합니다
  # @param href [String] href 속성 내용
  # @return [String, nil] 추출된 CID 또는 찾지 못한 경우 nil
  def extract_cid(href)
    href&.match(/viewGo\(\"([^\"]+)\"/)&.captures&.first
  end

  # 데이터베이스에 게시글 레코드를 업서트합니다
  # @param attributes [Hash] 게시글 속성
  def upsert_post(attributes)
    # CID로 기존 게시글을 찾거나 새 게시글을 초기화
    post = Post.find_or_initialize_by(cid: attributes[:cid])

    # 게시글 속성 업데이트
    post.assign_attributes(attributes)

    changed = post.changed - [ "view_count", "scraped_at" ]
    # view_count, scraped_at를 제외하고 수정된 상태라면
    if changed.any?
      puts "수정된 요소: #{changed.join(', ')}"
    else
      puts "수정된 요소 없음"
    end

    # 만약 이미 존재하는 레코드인 경우 last_updated_at 설정
    post.last_updated_at = Time.current unless post.new_record?

    # 게시글 저장
    if post.save
      Rails.logger.info "게시글 업서트 완료: #{post.title} (CID: #{post.cid})"
    else
      Rails.logger.error "게시글 업서트 실패 (CID: #{attributes[:cid]}): #{post.errors.full_messages.join(', ')}"
    end
  end
end
