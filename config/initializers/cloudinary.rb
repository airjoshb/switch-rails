
require 'cloudinary'

Cloudinary.config_from_url("cloudinary://ENV.fetch('CLOUDINARY_KEY_ID'):ENV.fetch('CLOUDINARY_ACCESS_KEY')@airjoshb")
Cloudinary.config do |config|
  config.secure = true
end