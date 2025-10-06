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
    xml.itunes :image, href: image_url("podcast_logo.png") # Replace with your podcast logo URL
    xml.itunes :category, text: "Arts" do
      xml.itunes :category, text: "Food"
    end

    # Podcast Episodes
    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.itunes :title, post.title
        xml.description post.content.to_plain_text.truncate(500) # Truncate description to 500 characters
        xml.itunes :summary, post.artifacts.with_media.first&.description
        xml.pubDate post.created_at.rfc2822
        xml.link update_url(post)
        xml.guid update_url(post)
        xml.itunes :episodeType, "full"
        xml.itunes :explicit, "false"


        # Add media file as an enclosure
        artifact = post.artifacts.with_media.first
        if artifact&.media&.attached? && artifact.media.content_type.start_with?("audio")
          xml.enclosure url: artifact.media.url, length: artifact.media.byte_size, type: artifact.media.content_type
          xml.itunes :duration, artifact.duration if artifact.duration.present?
          xml.itunes :season, artifact.season if artifact.season.present?
          xml.itunes :episode, artifact.episode if artifact.episode.present?
        end
      end
    end
  end
end