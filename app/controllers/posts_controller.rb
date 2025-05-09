class PostsController < ApplicationController
  def show
    # params[:id]는 데이터베이스의 게시글 ID (Post 모델의 id)
    @post = Post.find(params[:id])
    
    # 게시글 내용이 없으면 크롤링
    if @post.content.blank?
      Rails.logger.info "게시글 내용이 없어 크롤링합니다. 게시글 ID: #{@post.id}, 원본 CID: #{@post.cid}"
      FetchPostDetailJob.perform_now(@post.id)
      @post.reload
    end
    
    # 한글 인코딩 복원 시도
    if @post.content.present?
      begin
        @content_html = @post.content
      rescue => e
        Rails.logger.error "인코딩 변환 오류: #{e.message}"
        @content_html = @post.content
      end
    else
      @content_html = "<p>게시글 내용을 불러올 수 없습니다.</p>"
    end
  end

  def index
    if params[:refresh]
      FetchPostsJob.perform_later
      redirect_to posts_path, flash: { notice: "게시글 목록 갱신을 요청했습니다." }
    end

    @posts = Post.order(is_notice: :desc, created_at: :desc).limit(30)
  end
end
