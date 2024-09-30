
require 'cloudinary'

Cloudinary.config do |config|
  config.cloud_name = 'airjoshb'
  config.api_key = ENV.fetch('CLOUDINARY_KEY_ID')
  config.api_secret = ENV.fetch('CLOUDINARY_ACCESS_KEY')
end