class MainController < ApplicationController

  def index
    @gallery = Dir.glob("app/assets/images/gallery/*.jpg")
    @page = Page.find_by_slug("home")
    @categories = Category.all
  end
end
