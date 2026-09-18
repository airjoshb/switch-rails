class MainController < ApplicationController

  def index
    @gallery = Dir.glob("app/assets/images/gallery/*.jpg")
    @page = Page.find_by_slug("home")
    @categories = Category.active.categories.order(row_order: :asc)
    @all = Category.find_by_name("All")

    posts_scope = Post.content_posts

    @post = posts_scope.first
    @posts = posts_scope.where.not(id: @post&.id).limit(5)
  end
end
