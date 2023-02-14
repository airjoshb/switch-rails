class MainController < ApplicationController

  def index
    @gallery = Dir.glob("app/assets/images/gallery/*.jpg")
    @page = Page.find_by_slug("home")
    @categories = Category.where.not(name: "All")
    @all = Category.find_by_name("All")
    @posts = Post.last(4)
  end
end
