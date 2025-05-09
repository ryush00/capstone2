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

## 커밋 메시지 형식
- 유형은 영어로, 설명은 한국어로 작성
- 형식: `{type}: {한국어 설명}`
- 유형 예시:
  - `feat`: 새로운 기능 추가
  - `fix`: 버그 수정
  - `docs`: 문서 변경
  - `style`: 코드 포맷팅, 세미콜론 누락 등
  - `refactor`: 코드 리팩토링
  - `test`: 테스트 코드 추가/수정
  - `chore`: 빌드 프로세스, 라이브러리 변경 등

## 기타
- 작업 후 테스트가 없다면 테스트를 작성해 주세요.
- 작업 후 git commit 명령어를 실행할지 묻고, git commit을 진행해 주세요.