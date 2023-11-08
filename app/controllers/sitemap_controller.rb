class SitemapController < ApplicationController
  layout nil

  def index
    @products = Product.active.order(row_order: :asc)
    @posts = Post.all
    @pages = Page.all
    headers["Content-Type"] = "text/xml"
    respond_to do |format|
      format.xml { render :layout => false }
    end
  end
  
end
