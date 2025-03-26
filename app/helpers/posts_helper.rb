module PostsHelper
  # GET 방식으로 원본 페이지 링크 생성
  # @param post [Post] 게시글 객체
  # @return [String] 원본 페이지 URL (print.jsp)
  def post_print_url(post)
    "https://cyber.wku.ac.kr/Cyber/ComBoard_V005/Content/print.jsp?gid=#{post.gid}&bid=#{post.bid}&cid=#{post.cid}"
  end
  
  # POST 방식으로 원본 페이지 링크 생성 (Stimulus 사용)
  # @param post [Post] 게시글 객체
  # @return [String] Stimulus 컨트롤러를 사용한 링크 HTML
  def post_view_link(post)
    link_to "POST 방식으로 보기", "#", 
      data: {
        controller: "post-view",
        post_view_gid_value: post.gid,
        post_view_bid_value: post.bid,
        post_view_cid_value: post.cid,
        post_view_lpage_value: "1",
        action: "click->post-view#view"
      },
      class: "text-blue-600 hover:text-blue-800 hover:underline flex items-center"
  end
  
  # 원본 페이지 링크 옵션들
  # @param post [Post] 게시글 객체
  # @return [String] 원본 페이지 접근 옵션 HTML
  def original_page_links(post)
    content_tag :div, class: 'flex space-x-4 mt-2' do
      concat link_to "GET 방식으로 보기", post_print_url(post), 
             target: "_blank", 
             class: "text-blue-600 hover:text-blue-800 hover:underline flex items-center"
      concat post_view_link(post)
    end
  end
end
