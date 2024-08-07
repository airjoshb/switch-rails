class MainController < ApplicationController

  def index
    @gallery = Dir.glob("app/assets/images/gallery/*.jpg")
    @page = Page.find_by_slug("home")
    @categories = Category.active.categories.order(row_order: :asc)
    @all = Category.find_by_name("All")
    @posts = Post.first(4)
  end
end
