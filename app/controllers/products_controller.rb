class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update]
  before_action :set_categories, only: [:show, :index]

  def index
    if params[:category]
      @category = Category.find_by_name(params[:category])
      @image = @category.image.variant(resize_to_limit: [200, 200])
      @products = @category.products.active
      @title = @category.name + " fresh from the bakery"
    else
      @products = Product.active.order(row_order: :asc)
      @image = nil
      @title = "fresh from the bakery"
    end
  end

  def edit
    @product.variations.build
  end

  def show

  end

  def new
    @product = Product.new
    5.times {@product.variations.build}
  end

  def create
    @product.create(product_params)
    if @product.valid?
      redirect_to product_path(@product)
    else
      flash[:errors] = @product.errors.full_messages
      redirect_to new_product_path(@product)
    end
  end
  
  def update
    
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.friendly.find(params[:id])
  end

  def set_categories
    @categories = Category.all.order(row_order: :asc)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def product_params
    params.require(:product).permit(:name, :description, :image, :row_order, :active, :variations_attributes => [:unit_quantity, :name, :price, :active, :row_order, :image, :inventory])
  end

end
