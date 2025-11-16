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
    begin
      xml.image do
        xml.url image_url("https://switchbakery.com/assets/switch-bakery-gluten-free-bread-70d45051c17a2f94233ee38dff1810f4eafc7930cfa10f75ed87daa7a70b4c5d.png")
        xml.title "Switch Bakery"
        xml.link root_url
      end
    rescue
    end

    @posts.each do |article|
      xml.item do
        if article.image.attached?
          begin
            img_url = url_for(article.image) # requires default_url_options[:host] set
          rescue
            img_url = article.image.url if article.image.respond_to?(:url)
          end
          # prepend an <img> to the description so readers show inline image
          description_html = "<p><img src=\"#{img_url}\" alt=\"#{h(article.title)}\" style=\"max-width:100%;height:auto;\"/></p>#{article.content.to_s}"
        else
          description_html = article.content.to_s
        end

        xml.title(article.title)
        # Use CDATA for HTML so validators accept embedded tags/entities
        xml.description { xml.cdata! description_html }
        xml.pubDate article.created_at.rfc2822
        # Use absolute URLs; ensure default_url_options[:host] is configured in your env
        xml.link update_url(article)
        xml.guid update_url(article)
        # Add media file as an enclosure (guard that artifact and media exist)
        artifact = article.artifacts.with_media.first
        if artifact&.media&.attached? && artifact.media.content_type.start_with?("audio")
          begin
            xml.enclosure url: url_for(artifact.media), length: artifact.media.byte_size, type: artifact.media.content_type
          rescue
            xml.enclosure url: artifact.media.url, length: artifact.media.byte_size, type: artifact.media.content_type
          end
          xml.itunes :duration, artifact.duration if artifact.duration.present?
          xml.itunes :season, artifact.season if artifact.season.present?
          xml.itunes :episode, artifact.episode if artifact.episode.present?
        end
      end
    end
  end
end