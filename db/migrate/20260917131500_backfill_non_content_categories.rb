class BackfillNonContentCategories < ActiveRecord::Migration[7.1]
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

  NON_CONTENT_NAMES = [
    "Bread & Focaccia",
    "Cookies & Brownies",
    "Desserts",
    "Keto & Sugar-free Treats",
    "Menus",
    "Careers"
  ].freeze

  def up
    migration_category = Class.new(ActiveRecord::Base) do
      self.table_name = "categories"
    end

    migration_category
      .where(slug: NON_CONTENT_SLUGS)
      .or(migration_category.where(name: NON_CONTENT_NAMES))
      .update_all(content: false)
  end

  def down
    # Intentionally no-op: we cannot safely infer prior content values.
  end
end
