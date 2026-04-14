class MainController < ApplicationController

  def index
    @gallery = Dir.glob("app/assets/images/gallery/*.jpg")
    @page = Page.find_by_slug("home")
    @categories = Category.active.categories.order(row_order: :asc)
    @all = Category.find_by_name("All")

    nav_page_slugs = Page.where(nav: true).where.not(slug: [nil, ""]).pluck(:slug)
    posts_scope = Post.left_joins(:category)
    if nav_page_slugs.any?
      posts_scope = posts_scope.where("categories.slug IS NULL OR categories.slug NOT IN (?)", nav_page_slugs)
    end

    @post = posts_scope.first
    @posts = posts_scope.where.not(id: @post&.id).limit(5)
  end
end
