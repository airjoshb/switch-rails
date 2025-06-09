# Replace the 'config_from_url' string value below with your
# product environment's credentials, available from your Cloudinary console.
# =====================================================

require 'cloudinary'

Cloudinary.config_from_url("cloudinary://425996484659722:otFIQ99aO5tmpvX_2pjhoLKyc3s@airjoshb")
Cloudinary.config do |config|
  config.secure = true
  config.enhance_image_tag = true
end