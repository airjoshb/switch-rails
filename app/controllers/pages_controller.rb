class PagesController < ApplicationController
  before_action :set_page, only: :show

  def show
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page
      @page = Page.find_by_slug(params[:slug])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_params
      params.require(:page).permit(:page_id, :description, :title, :nav, :slug)
    end

end
