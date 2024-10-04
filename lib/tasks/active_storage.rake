namespace :active_storage do

  desc 'Ensures all files are mirrored'
  task mirror_all: [:environment] do
    ActiveStorage::Blob.all.each do |blob|
      blob.update(service_name: "mirror")
      puts("updated service name")
      blob.mirror_later
    end
  end
end