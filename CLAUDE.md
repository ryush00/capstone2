# capstone2 프로젝트를 위한 Claude 가이드라인

## 명령어
- 서버 실행: `bin/rails server`
- 콘솔: `bin/rails console`
- 린트: `bin/rubocop`
- 테스트(전체): `bundle exec rspec`
- 테스트(단일): `bundle exec rspec spec/path/to_spec.rb:line_number`
- 시스템 테스트: `bundle exec rspec spec/system`
- 자산 컴파일: `bin/rails assets:precompile`

## 코드 스타일
- Rails 8 규칙 준수 (Turbo, Stimulus, Sourcemap 활용)
- Ruby 표준 스타일 가이드 준수
- 들여쓰기: 2칸 스페이스
- 컨트롤러: RESTful 리소스 패턴 사용
- 뷰: 부분 뷰로 코드 구성
- JS: Stimulus 컨트롤러 사용
- DB 변경: 마이그레이션 파일 사용
- 모델: 유효성 검사 및 관계 명시적 정의
- 테스트: RSpec 사용 (FactoryBot, Capybara 활용)
- API: RESTful JSON 응답 형식 사용