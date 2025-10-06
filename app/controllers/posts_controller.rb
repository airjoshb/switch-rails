class PostsController < ApplicationController
  before_action :set_post, only: [:show]

  def index
    @posts= Post.all
  end

  def show

  end

  def feed
    @posts = Post.all.order(created_at: :desc).limit(20)
    respond_to do |format|
      format.rss { render layout: false }
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
