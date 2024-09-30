namespace :active_storage do

  desc 'Ensures all files are mirrored'
  task mirror_all: [:environment] do
    ActiveStorage::Blob.find_each do |blob|
      ActiveStorage::Blob.service.try(:mirror, blob.key, checksum: blob.checksum)
    end && puts("Mirroring done!")
  end
end