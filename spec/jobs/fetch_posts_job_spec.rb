require "rails_helper"

RSpec.describe FetchPostsJob, type: :job do
  describe "#perform" do
    let(:html_content) do
      <<~HTML
        <!DOCTYPE html>
        <html>
        <head><title>Test</title></head>
        <body>
          <table class="table">
            <tbody>
              <tr class="notice notice-view">
                <td><span class="label">공지</span></td>
                <td>관리자</td>
                <td><a href="javascript:viewGo(&#34;12345&#34;, 1);">공지 게시글</a></td>
                <td>2025-04-08</td>
                <td>10</td>
                <td></td>
              </tr>
              <tr>
                <td></td>
                <td>사용자</td>
                <td><a href="javascript:viewGo(&#34;67890&#34;, 1);">일반 게시글</a></td>
                <td>2025-04-07</td>
                <td>5</td>
                <td></td>
              </tr>
            </tbody>
          </table>
        </body>
        </html>
      HTML
    end

    before do
      # 테스트 데이터 초기화
      Post.destroy_all

      # Faraday 응답 모의 처리
      response_double = instance_double(Faraday::Response, status: 200, body: html_content)
      allow(Faraday).to receive(:get).and_return(response_double)
    end

    context "정상적인 응답을 받을 때" do
      it "게시글을 적절히 처리한다" do
        # 테스트 데이터 초기화 확인
        expect(Post.count).to eq(0)

        # 작업 실행
        subject.perform

        # 총 게시글 수 확인
        expect(Post.count).to eq(2)

        # 공지 게시글 확인
        notice_post = Post.find_by(cid: "12345")
        expect(notice_post).to be_present
        expect(notice_post.is_notice).to be true
        expect(notice_post.title).to eq("공지 게시글")

        # 일반 게시글 확인
        regular_post = Post.find_by(cid: "67890")
        expect(regular_post).to be_present
        expect(regular_post.is_notice).to be false
        expect(regular_post.title).to eq("일반 게시글")
      end
    end

    context "공지에서 제외된 게시글이 있을 때" do
      before do
        # 이전에 공지로 표시된 게시글 생성
        Post.create!(
          title: "예전 공지",
          cid: "99999",
          gid: FetchPostsJob::GID,
          bid: FetchPostsJob::BID,
          is_notice: true,
          author_name: "관리자",
          view_count: 20,
          source_url: "https://example.com",
          scraped_at: Time.current
        )
      end

      it "현재 공지 목록에 없는 게시글의 공지 상태를 해제한다" do
        subject.perform
        old_post = Post.find_by(cid: "99999")
        expect(old_post).to be_present
        expect(old_post.is_notice).to be false
      end
    end
  end
end
