class MainController < ApplicationController

  def index
    @gallery = Dir.glob("app/assets/images/gallery/*.jpg")
    @page = Page.find_by_slug("home")
    @categories = Category.active.categories.order(row_order: :asc)
    @all = Category.find_by_name("All")
    @post = Post.first
    @posts = Post.first(5).without(@post)
  end
end
