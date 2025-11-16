xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.rss version: "2.0",
        "xmlns:itunes" => "http://www.itunes.com/dtds/podcast-1.0.dtd",
        "xmlns:content" => "http://purl.org/rss/1.0/modules/content/",
        "xmlns:atom" => "http://www.w3.org/2005/Atom" do

  xml.channel do
    # Atom self link (validators expect this)
    begin
      atom_href = begin
        podcast_feed_url
      rescue
        if defined?(request) && request.present?
          "#{request.protocol}#{request.host_with_port}#{podcast_feed_path}"
        else
          nil
        end
      end

      if atom_href.present?
        xml.tag!('atom:link', rel: 'self', type: 'application/rss+xml', href: atom_href)
      end
    rescue => e
      Rails.logger.warn "[Podcast Feed] atom self link generation failed: #{e.class} #{e.message}"
    end

    # General Podcast Information
    xml.title "Switch It On!"
    xml.link updates_url
    xml.language "en-us"
    xml.copyright "© #{Time.now.year} Frazley Adventures LLC"
    xml.description "A gluten-free bakery podcast featuring stories, recipes, and interviews."
    xml.itunes :author, "Switch Bakery"
    xml.itunes :type, "episodic"
    xml.itunes :explicit, "clean"
    xml.itunes :owner do
      xml.itunes :name, "Switch Bakery"
      xml.itunes :email, "hey@switchbakery.com"
    end
    xml.itunes :image, href: image_url("https://res.cloudinary.com/airjoshb/image/upload/v1763271778/switch-bakery/switch-bakery1400x1400bb_bdoabe.jpg")
    xml.itunes :category, text: "Arts" do
      xml.itunes :category, text: "Food"
    end

    # ensure we have a sanitizer helper near the top of the file (add once)
    sanitize_for_cdata = ->(str) do
      s = str.to_s
      s = s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      s = s.gsub(/[\u0000-\u0008\u000B\u000C\u000E-\u001F]/, '')
      s.gsub(']]>', ']]]]><![CDATA[>')
    end

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.itunes :title, post.title

        # Use CDATA for HTML or text that may include special chars
        xml.description { xml.cdata! post.content.to_plain_text.truncate(500) }

        # replacement for the itunes :summary block
        xml.itunes :summary do
          raw_summary = post.artifacts.with_media.first&.description.to_s

          # strip HTML tags — use view helper if available, otherwise fallback
          summary_text = if respond_to?(:strip_tags)
                           strip_tags(raw_summary)
                         else
                           ActionController::Base.helpers.strip_tags(raw_summary)
                         end

          summary_text = summary_text.to_s.strip
          summary_text = summary_text.truncate(500)

          xml.cdata! sanitize_for_cdata.call(summary_text)
        end

        xml.pubDate post.created_at.rfc2822
        xml.link update_url(post)
        xml.guid update_url(post)
        xml.itunes :episodeType, "full"
        xml.itunes :explicit, "clean"

        # Add media file as an enclosure (guard that artifact and media exist)
        artifact = post.artifacts.with_media.first
        if artifact&.media&.attached? && artifact.media.content_type&.start_with?("audio")
          blob = artifact.media.blob

          # Determine host for absolute URL: default_url_options[:host] or request.host_with_port
          host = Rails.application.routes.default_url_options[:host] ||
                 (defined?(request) && request&.host_with_port)

          url = begin
            if defined?(Rails) && blob.respond_to?(:service)
              Rails.application.routes.url_helpers.rails_blob_url(blob, host: host)
            else
              # fallback
              url_for(artifact.media)
            end
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