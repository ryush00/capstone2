class AddAiToPosts < ActiveRecord::Migration[8.0]
  def change
    change_table :posts do |t|
      t.text :ai_short_description, comment: "AI가 생성한 짧은 설명"
      t.text :ai_summary_markdown, comment: "AI가 생성한 마크다운 요약"
      t.text :ai_target_audience, comment: "AI가 생성한 대상 독자"
      t.text :ai_duration, comment: "AI가 생성한 기간"
      t.text :ai_method, comment: "AI가 생성한 방법"
      t.text :ai_cautions, comment: "AI가 생성한 주의사항 (마크다운 형식)"
      t.text :ai_contact_phone, comment: "AI가 생성한 연락처 전화번호"
      t.text :ai_contact_email, comment: "AI가 생성한 연락처 이메일"
      t.text :ai_contact_department, comment: "AI가 생성한 연락처 부서"
      t.text :ai_department_location, comment: "AI가 생성한 부서 위치"
      t.text :ai_available_time, comment: "AI가 생성한 연락 가능 시간"
      t.text :ai_cost, comment: "AI가 생성한 비용"

      t.datetime :ai_analyzed_at, comment: "AI 분석 완료 시간"
    end
  end
end
