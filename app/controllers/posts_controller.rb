class PostsController < ApplicationController
  before_action :set_post, only: [:show]

  def index
    if params[:category]
      @category = Category.find_by_slug(params[:category])
      @posts = Post.where(category_id: @category.id) if @category
    else
      @posts= Post.all
    end
  end

  def show

  end

  def feed
    @posts = Post.all.order(created_at: :desc).limit(20)

    respond_to do |format|
      format.rss { render layout: false }                                  # /feed with Accept: application/rss+xml
      format.xml { render "feed", formats: [:rss], layout: false }         # Accept: application/xml or text/xml -> render RSS template
      format.any { render "feed", formats: [:rss], layout: false }         # fallback: render RSS if client doesn't specify acceptable mime
    end
  end

  def podcast_feed
    @posts = Post.joins(:category).where(categories: { name: "Podcasts" }).includes(:artifacts)
    respond_to do |format|
      format.rss { render layout: false }                                  # /feed with Accept: application/rss+xml
      format.xml { render "feed", formats: [:rss], layout: false }         # Accept: application/xml or text/xml -> render RSS template
      format.any { render "feed", formats: [:rss], layout: false }         # fallback: render RSS if client doesn't specify acceptable mime
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.friendly.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def post_params
    params.require(:post).permit(:title, :image)
  end

end
