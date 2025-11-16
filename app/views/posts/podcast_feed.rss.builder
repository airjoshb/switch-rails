xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.rss version: "2.0", "xmlns:itunes" => "http://www.itunes.com/dtds/podcast-1.0.dtd", "xmlns:content" => "http://purl.org/rss/1.0/modules/content/" do
  xml.channel do
    # General Podcast Information
    xml.title "Switch It On!"
    xml.link updates_url
    xml.language "en-us"
    xml.copyright "© #{Time.now.year} Frazley Adventures LLC"
    xml.description "A gluten-free bakery podcast featuring stories, recipes, and interviews."
    xml.itunes :author, "Switch Bakery"
    xml.itunes :type, "episodic"
    xml.itunes :explicit, "false"
    xml.itunes :image, href: image_url("https://res.cloudinary.com/airjoshb/image/upload/v1763269703/switch-it-on_gdaltn.jpg")
    xml.itunes :category, text: "Arts" do
      xml.itunes :category, text: "Food"
    end

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.itunes :title, post.title

        # Use CDATA for HTML or text that may include special chars
        xml.description { xml.cdata! post.content.to_plain_text.truncate(500) }
        xml.itunes :summary do
          # artifact summary might be nil; guard
          summary = post.artifacts.with_media.first&.description.to_s
          xml.cdata! summary
        end

        xml.pubDate post.created_at.rfc2822
        xml.link update_url(post)
        xml.guid update_url(post)
        xml.itunes :episodeType, "full"
        xml.itunes :explicit, "false"

        # Add media file as an enclosure (guard that artifact and media exist)
        artifact = post.artifacts.with_media.first
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