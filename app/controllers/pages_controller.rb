class PagesController < ApplicationController
  before_action :set_page, only: :show

  def show
    redirect_to(root_url, :notice => 'Record not found') unless @page
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page
      @page = Page.find_by_slug(params[:slug])
      @posts = Post.joins(:category).where(categories: {name: @page.title})
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_params
      params.require(:page).permit(:page_id, :description, :title, :nav, :slug)
    end

end
