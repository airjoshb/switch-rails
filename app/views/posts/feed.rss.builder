xml.instruct! :xml, version: "1.0", encoding: "UTF-8"

xml.rss version: "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    # Atom self link (some validators require this)
    begin
      atom_href = nil
      begin
        atom_href = feed_url
      rescue
        # fallback: construct absolute URL from request if feed_url isn't available
        if defined?(request) && request.present?
          atom_href = "#{request.protocol}#{request.host_with_port}#{feed_path}"
        end
      end

      # Only emit a properly-namespaced atom:link when we have a valid href
      if atom_href.present?
        xml.tag!('atom:link', rel: 'self', type: 'application/rss+xml', href: atom_href)
      end
    rescue => e
      Rails.logger.warn "[Feed] atom self link generation failed: #{e.class} #{e.message}"
    end

    xml.title "Updates from Switch Bakery"
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
        xml.title "Updates from Switch Bakery"
        xml.link updates_url
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
          # Determine a host for absolute URLs: prefer Rails default_url_options, otherwise use request host.
          host = Rails.application.routes.default_url_options[:host] ||
                 (defined?(request) && request&.host_with_port)

          img_url = nil

          begin
            # Prefer rails_blob_url to get an absolute URL for ActiveStorage blobs.
            if article.image.respond_to?(:blob) && article.image.blob.present?
              img_url = Rails.application.routes.url_helpers.rails_blob_url(article.image, host: host)
            else
              img_url = url_for(article.image)
            end
          rescue => _
            # Fallbacks for providers that expose a direct URL (Cloudinary, etc.)
            img_url = article.image.respond_to?(:url) ? article.image.url : nil
          end

          # Ensure we have an absolute URL; if still nil or relative, try prepending host (best-effort)
          if img_url.present? && host.present? && img_url.start_with?('/')
            img_url = "#{request.protocol}#{host}#{img_url}" rescue "#{host}#{img_url}"
          end

          # Build description with inline image (use empty src if none to avoid nil)
          img_src = img_url.presence || ''
          description_html = "<p><img src=\"#{img_src}\" alt=\"#{h(article.title)}\" style=\"max-width:100%;height:auto;\"/></p>#{article.content.to_s}"
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
        end
      end
    end
  end
end