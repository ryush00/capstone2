#!/usr/bin/env ruby
require 'faraday'
require 'nokogiri'

url = 'https://cyber.wku.ac.kr/Cyber/ComBoard_V005/Content/list.jsp?gid=1115983888724&bid=1115985252888'

response = Faraday.get(url)

if response.status == 200
  doc = Nokogiri::HTML(response.body)
  
  # 첫 번째 링크의 href 추출
  first_link = doc.css('td:nth-child(3) a').first
  if first_link
    href = first_link['href']
    puts "First link href: #{href}"
    
    # viewGo 함수 파라미터 추출
    if href =~ /viewGo\(\"([^\"]+)\"\s*,\s*(\d+)\)/
      post_id = $1
      page = $2
      puts "Post ID: #{post_id}, Page: #{page}"
    end
  end
  
  # 폼 요소 찾기
  form = doc.css('form[name="list"]').first
  if form
    puts "\nForm elements:"
    form.css('input').each do |input|
      puts "#{input['name']}: #{input['value']}"
    end
  end
else
  puts "Failed with HTTP Status: #{response.status}"
end