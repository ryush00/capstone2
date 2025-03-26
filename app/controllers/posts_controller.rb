class PostsController < ApplicationController
  require 'faraday'
  require 'nokogiri'

  def index
    # 원광대 사이버캠퍼스 공지사항 URL
    url = 'https://cyber.wku.ac.kr/Cyber/ComBoard_V005/Content/list.jsp?gid=1115983888724&bid=1115985252888'
    
    begin
      # Faraday를 사용하여 웹 페이지 가져오기
      response = Faraday.get(url)
      
      if response.status == 200
        # Nokogiri를 사용하여 HTML 파싱
        doc = Nokogiri::HTML(response.body)
        
        # 게시글 목록 추출
        @posts = []
        
        # 공지 게시글
        doc.css('tr.notice').each do |row|
          post = {
            type: row.css('td:nth-child(1) span').text.strip,
            author: row.css('td:nth-child(2)').text.strip,
            title: row.css('td:nth-child(3) a').text.strip,
            date: row.css('td:nth-child(4)').text.strip,
            views: row.css('td:nth-child(5)').text.strip,
            has_file: row.css('td:nth-child(6)').text.strip.present?,
            link_id: row.css('td:nth-child(3) a').attr('href')&.to_s&.match(/viewGo\(\"([^\"]+)\"/)&.captures&.first
          }
          
          @posts << post unless post[:title].empty?
        end
        
        # 일반 게시글
        doc.css('table.table tbody tr').each do |row|
          # 헤더 행과 공지 게시글은 건너뜀
          next if row.css('th').any? || row['class']&.include?('notice')
          
          post = {
            number: row.css('td:nth-child(1)').text.strip,
            author: row.css('td:nth-child(2)').text.strip,
            title: row.css('td:nth-child(3) a').text.strip,
            date: row.css('td:nth-child(4)').text.strip,
            views: row.css('td:nth-child(5)').text.strip,
            has_file: row.css('td:nth-child(6) span.label').present?,
            link_id: row.css('td:nth-child(3) a').attr('href')&.to_s&.match(/viewGo\(\"([^\"]+)\"/)&.captures&.first
          }
          
          @posts << post unless post[:title].empty?
        end
      else
        @error = "페이지를 가져올 수 없습니다. 상태 코드: #{response.status}"
      end
    rescue => e
      @error = "오류가 발생했습니다: #{e.message}"
    end
    
    # 페이지 구조 분석
    # 웹 페이지 구조 분석:
    # 
    # 1. 게시글 목록 구조:
    #    - 공지사항: <tr class="notice notice-view">
    #    - 일반게시글: <tr> (class 없음)
    # 
    # 2. 게시글 항목 구조:
    #    - 공지사항 태그: td:nth-child(1) > span.label
    #    - 작성자: td:nth-child(2)
    #    - 제목: td:nth-child(3) > a
    #    - 날짜: td:nth-child(4)
    #    - 조회수: td:nth-child(5)
    #    - 파일첨부: td:nth-child(6) > span.label
    # 
    # 3. 게시글 링크:
    #    - 형식: JavaScript:viewGo("1742804766028", 1);
    #    - 링크 ID 추출 방법: viewGo("ID", 1) 에서 ID 부분을 추출
    # 
    # 4. 페이지네이션:
    #    - 형식: <div class="pagination"> 내부의 <ul> <li> 요소들
    #    - 페이지 이동: JavaScript:listGo(1, 페이지번호);
    # 
    # 5. 검색 기능:
    #    - 검색 폼: 하단의 <form> 요소
    #    - 검색 필드: select[name='sField']
    #    - 검색어: input[name='sKey']
  end
end
