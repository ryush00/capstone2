#!/usr/bin/env ruby
require 'faraday'

url = 'https://cyber.wku.ac.kr/Cyber/ComBoard_V005/Content/list.jsp?gid=1115983888724&bid=1115985252888'

response = Faraday.get(url)

if response.status == 200
  puts response.body
else
  puts "Failed with HTTP Status: #{response.status}"
end