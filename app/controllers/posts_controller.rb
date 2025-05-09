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
  end

  def index
    if params[:refresh]
      FetchPostsJob.perform_later
      redirect_to posts_path, flash: { notice: "게시글 목록 갱신을 요청했습니다." }
    end

    @posts = Post.order(is_notice: :desc, posted_at: :desc).limit(30)
  end
end
