class BoxVariation < ApplicationRecord
  belongs_to :box
  belongs_to :variation

  scope :add_ons, ->{ where(add_on: true) }
end
