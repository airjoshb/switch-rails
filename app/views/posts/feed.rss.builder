xml.instruct! :xml, version: "1.0", encoding: "UTF-8"

xml.rss version: "2.0" do
  xml.channel do
    xml.title "Switch Bakery Updates"
    xml.description "A gluten-free bakery, specializing in bread, cake, and pastries. Latest updates and posts."
    xml.link updates_url
    xml.language "en-US"
    xml.pubDate(@posts.first.created_at.rfc2822) if @posts.any?
    xml.lastBuildDate((Time.zone&.now || Time.now).rfc2822)
    xml.generator "Switch Bakery"

    # Optional channel image (uncomment and set a logo in app/assets/images if desired)
    # begin
    #   xml.image do
    #     xml.url image_url("site_logo.png")
    #     xml.title "Switch Bakery"
    #     xml.link root_url
    #   end
    # rescue
    # end

    @posts.each do |article|
      xml.item do
        if article.respond_to?(:image) && article.image&.attached?
          # url_for / rails_blob_url require route host; url helpers in views should work
          begin
            xml.image_url url_for(article.image)
          rescue
            xml.image_url article.image.url if article.image.respond_to?(:url)
          end
        end
        xml.title(article.title)
        # Use CDATA for HTML so validators accept embedded tags/entities
        xml.description { xml.cdata! article.content.to_s }
        xml.pubDate article.created_at.rfc2822
        # Use absolute URLs; ensure default_url_options[:host] is configured in your env
        xml.link update_url(article)
        xml.guid update_url(article)
      end
    end
  end
end