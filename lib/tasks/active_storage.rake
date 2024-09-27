namespace :active_storage do

  desc 'Ensures all files are mirrored'
  task mirror_all: [:environment] do
    ActiveStorage::Blob.all.each do |blob|
      blob.mirror_later
    end
  end
end