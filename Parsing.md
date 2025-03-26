# 원광대학교 사이버캠퍼스 페이지 파싱 구조 분석

## 1. 게시글 목록 구조 (list.jsp)

### 게시글 목록 구조:
- 공지사항: `<tr class="notice notice-view">`
- 일반게시글: `<tr>` (class 없음)

### 게시글 항목 구조:
- 공지사항 태그: `td:nth-child(1) > span.label`
- 작성자: `td:nth-child(2)`
- 제목: `td:nth-child(3) > a`
- 날짜: `td:nth-child(4)`
- 조회수: `td:nth-child(5)`
- 파일첨부: `td:nth-child(6) > span.label`

### 게시글 링크:
- 원본 형식: `JavaScript:viewGo("1742804766028", 1);`
- 링크 ID 추출 방법: `viewGo("ID", 1)` 에서 ID 부분을 추출
- POST 방식 접근: `/Cyber/ComBoard_V005/Content/view.jsp` (cid 파라미터 필요)
- GET 방식 접근: `/Cyber/ComBoard_V005/Content/print.jsp?gid=1115983888724&bid=1115985252888&cid=POST_ID`
- 필수 폼 파라미터:
  * gid: 1115983888724 (게시판 그룹 ID)
  * bid: 1115985252888 (게시판 ID)  
  * cid: 게시글 ID (viewGo 함수의 첫 번째 파라미터)
  * lpage: 페이지 번호 (기본값 1)

### 페이지네이션:
- 형식: `<div class="pagination">` 내부의 `<ul>` `<li>` 요소들
- 페이지 이동: `JavaScript:listGo(1, 페이지번호);`

### 검색 기능:
- 검색 폼: 하단의 `<form>` 요소
- 검색 필드: `select[name='sField']`
- 검색어: `input[name='sKey']`

## 2. 게시글 상세 페이지 구조 (view.jsp)

### 게시글 메타데이터
- 작성자: `div.row-fluid div.span12 strong:contains("작성자") + a`
- 작성자 이메일: `div.row-fluid div.span12 a[href^='mailto:']`
- 게시글 번호: `div.row-fluid div.span12 strong:contains("NO.") + 텍스트`
- 조회수: `div.row-fluid div.span12 strong:contains("조회수") + 텍스트`
- 작성일: `div.row-fluid div.span12 strong:contains("작성일") + 텍스트`

### 첨부파일 정보
- 첨부파일 링크: `div.row-fluid div.span12 a[href^='javaScript:downGo']`
- 첨부파일 이름: `div.row-fluid div.span12 a[href^='javaScript:downGo'] strong`
- 파일 크기: `span#noPrint strong:first-child`
- 다운로드 횟수: `span#noPrint strong:last-child`

### 게시글 내용
- 게시글 제목: `div.row-fluid div.span12 p`
- 게시글 내용 영역: `div.bbs-div-kcy`
- 실제 내용: `div.bbs-div-kcy table.bbs-form-2017 tbody tr td`
- 대제목: `div.bbs-div-kcy h1`
- 소제목: `div.bbs-div-kcy h2`
- 이미지: `div.bbs-div-kcy img`
  - 이미지 URL 형식: `https://cyberimg.wku.ac.kr/ComBoard/img/upload/[gid]/[bid]/[year]/[month]/[cid]/org/[filename]`

### 버튼 및 기능
- 주소복사 버튼: `button[onclick="JavaScript:copyUrl()"]`
- 인쇄 버튼: `button[onclick='JavaScript:printGo()']`
- 검색목록 버튼: `button[onclick='JavaScript:listGo(1, 1)']`
- 전체목록 버튼: `button[onclick="location.href='/Cyber/ComBoard_V005/Content/list.jsp?gid=1115983888724&bid=1115985252888'"]`

### 폼 및 히든 필드
- 폼 이름: `form[name='view']`
- 게시판 그룹 ID: `input[name='gid']`
- 게시판 ID: `input[name='bid']`
- 게시글 ID: `input[name='cid']`