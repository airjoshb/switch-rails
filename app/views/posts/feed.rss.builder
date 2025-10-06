xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Switch Bakery from Santa Cruz"
    xml.description "A gluten-free bakery, specializing in bread, cake, and pastries. Come visit our bistro."
    xml.link posts_url
    xml.language "en-US"
	  xml.updatePeriod "hourly"
	  xml.updateFrequency "1"

    @posts.each do |article|
      xml.item do
        xml.title article.title
        xml.image_url article.image.url
        xml.description article.content
        xml.pubDate article.pub_date.to_s
        xml.link update_url(article)
        xml.guid update_url(article)
      end
    end
  end
end