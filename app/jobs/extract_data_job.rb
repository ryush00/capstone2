class ExtractDataJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    client = OpenAI::Client.new(
      access_token: Rails.application.credentials.openai[:access_token],
      log_errors: true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
    )

    post = Post.find(post_id)
    return unless post

    content = post.content

    schema = JSON.parse(<<-HEREDOC
{
  "name": "summary_schema",
  "strict": false,
  "schema": {
    "type": "object",
    "properties": {
      "short_description": {
        "type": "string",
        "description": "A brief summary of the content. Do not ends with '이다' or '입니다' and dot."
      },
      "summary_markdown": {
        "type": "string",
        "description": "A detailed summary formatted in Markdown."
      },
      "target_audience": {
        "type": "string",
        "description": "The intended audience for the content."
      },
      "duration": {
        "type": "string",
        "description": "The time duration related to the content."
      },
      "method": {
        "type": "string",
        "description": "The method or approach being described."
      },
      "cautions": {
        "type": "string",
        "description": "Precautions or considerations to be aware of. Formatted in Markdown."
      },
      "contact_phone": {
        "type": "string",
        "description": "The phone number for inquiries."
      },
      "contact_email": {
        "type": "string",
        "description": "The email address for inquiries."
      },
      "contact_department": {
        "type": "string",
        "description": "The name of the department to contact."
      },
      "department_location": {
        "type": "string",
        "description": "The physical location of the contact department."
      },
      "available_time": {
        "type": "string",
        "description": "The hours during which inquiries can be made."
      },
      "cost": {
        "type": "string",
        "description": "The cost associated with the content."
      }
    },
    "required": [
      "short_description",
      "summary_markdown"
    ],
    "additionalProperties": false
  }
}
HEREDOC
    )

    # content에서 img를 뽑아서 image_urls 배열에 추가
    image_urls = []
    
    # content가 nil이 아닌 경우에만 처리
    if content.present?
      doc = Nokogiri::HTML(content)
      doc.css('img').each do |img|
        src = img['src']
        if src.present?
          # 상대 경로인 경우 절대 경로로 변환
          if src.start_with?('/')
            image_urls << "https://cyber.wku.ac.kr#{src}"
          else
            image_urls << src
          end
        end
      end
      
      # 중복 제거
      image_urls.uniq!
    end

    contents = []

    contents << { type: "input_text", text: "제목: #{post.title}" }
    contents << { type: "input_text", text: content }
    image_urls.each do |url|
      contents << { type: "input_image", image_url: url }
    end
    p contents
    # 이미지 URL이 없는 경우 로그 출력
    Rails.logger.info "추출된 이미지 URL이 없습니다." if image_urls.empty?
    

    response = client.responses.create(
      parameters: {
        model: "o4-mini",
        instructions: "당신은 원광대학교 공지사항에 올라온 내용을 분석하고 학생들에게 알려주기 전 전처리를 맡았습니다. 규격에 맞춰 데이터를 추출해 주세요. 기간인 경우 `ㅇㅇㅇㅇ년 ㅇㅇ월 ㅇㅇ일 ~ ㅇㅇㅇㅇ년 ㅇㅇ월 ㅇㅇ일` 형식으로 맞춰주세요. 요일이 명시적으로 적힌 경우 요일을 뒷부분에 (토) 처럼 적어주세요. 시간이 적혀있다면 24시간 형식으로 00:00 으로 적어주세요. 데이터는 마크다운 형식으로 정리해 주세요. 답변은 한국어로 적어주세요. 짧은 요약은 입니다 등으로 끝내지 마세요. 'ㅇㅇㅇㅇ 안내', 'ㅇㅇㅇㅇ 개최' 처럼 끝내세요.",
        text: {
          format: {
            type: "json_schema",
            **schema
          }
        },
        input: [{role: "user", content: contents }],
      }
    )

    output = response.dig("output", 1, "content", 0, "text")
    
    p output
    result = JSON.parse(output)

    post.update!(
      ai_short_description: result["short_description"],
      ai_summary_markdown: result["summary_markdown"],
      ai_target_audience: result["target_audience"],
      ai_duration: result["duration"],
      ai_method: result["method"],
      ai_cautions: result["cautions"],
      ai_contact_phone: result["contact_phone"],
      ai_contact_email: result["contact_email"],
      ai_contact_department: result["contact_department"],
      ai_department_location: result["department_location"],
      ai_available_time: result["available_time"],
      ai_cost: result["cost"],
      ai_analyzed_at: Time.current
    )
    p result
    # # message type가 아니면 reject 
    # response = responses.reject()

    # # 
    # puts response.class
    # puts "---"*5
    # puts response.dig("output")
    # puts "---"*5
    # puts "Response: #{response.inspect}"
    # puts "---"*5
    # puts response.dig("output", 0, "content", 0, "text")
    # puts "---"*5

    # result = JSON.parse(response.dig("output", 0, "content", 0, "text"))

    # p result
  end
end