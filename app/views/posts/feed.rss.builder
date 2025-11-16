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

    sanitize_for_cdata = ->(str) do
      s = str.to_s
      # normalize to UTF-8, remove invalid/unknown bytes
      s = s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      # remove disallowed XML control chars (keep tab/newline/CR)
      s = s.gsub(/[\u0000-\u0008\u000B\u000C\u000E-\u001F]/, '')
      # split occurrences of ']]>' so CDATA doesn't terminate
      s.gsub(']]>', ']]]]><![CDATA[>')
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
        xml.description { xml.cdata! sanitize_for_cdata.call(description_html) }
        xml.pubDate article.created_at.rfc2822
        # Use absolute URLs; ensure default_url_options[:host] is configured in your env
        xml.link update_url(article)
        xml.guid update_url(article)
        # Add media file as an enclosure (guard that artifact and media exist)
        artifact = article.artifacts.with_media.first
        if artifact&.media&.attached? && artifact.media.content_type&.start_with?("audio")
          blob = artifact.media.blob

          # Try to build an absolute URL for the blob. Prefer rails_blob_url when possible.
          url = begin
            Rails.application.routes.url_helpers.rails_blob_url(blob, host: (Rails.application.routes.default_url_options[:host] || request&.host_with_port))
          rescue => _
            begin
              url_for(artifact.media)
            rescue => _
              artifact.media.respond_to?(:url) ? artifact.media.url : nil
            end
          end

          if url.present?
            length = blob.try(:byte_size) || artifact.media.try(:byte_size) || 0
            type = blob.try(:content_type) || artifact.media.try(:content_type) || "audio/mpeg"
            xml.enclosure url: url, length: length, type: type
          end

          xml.itunes :duration, artifact.duration if artifact.respond_to?(:duration) && artifact.duration.present?
          xml.itunes :season, artifact.season if artifact.respond_to?(:season) && artifact.season.present?
          xml.itunes :episode, artifact.episode if artifact.respond_to?(:episode) && artifact.episode.present?
        end
      end
    end
  end
end