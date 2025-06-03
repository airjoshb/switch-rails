class FanComment < ApplicationRecord
  belongs_to :customer

  scope :not_blank, ->{ where.not(comment: [nil, '']) }
end
