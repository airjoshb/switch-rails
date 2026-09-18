class AddContentToCategories < ActiveRecord::Migration[7.1]
  NON_CONTENT_SLUGS = %w[
    bread
    cookies-brownies
    cake
    keto-sugar-free
    menu
    careers
    all
    unpublished
    embeds
    fans
    subscripton
    locations
  ].freeze

  def up
    add_column :categories, :content, :boolean, default: true, null: false

    migration_category = Class.new(ActiveRecord::Base) do
      self.table_name = "categories"
    end

    migration_category.reset_column_information
    migration_category.where(slug: NON_CONTENT_SLUGS).update_all(content: false)
  end

  def down
    remove_column :categories, :content
  end
end
