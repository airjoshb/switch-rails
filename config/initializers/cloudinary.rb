
require 'cloudinary'

Cloudinary.config_from_url("cloudinary://ENV.fetch('CLOUDINARY_URL')")
Cloudinary.config do |config|
  config.secure = true
  config.enhance_image_tag = true
  config.static_file_support= false
end
