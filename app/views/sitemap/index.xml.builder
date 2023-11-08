xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc "https://switchbakery.com"
    xml.priority 1.0
    xml.changefreq("daily")
  end

  for p in @products
    xml.url do
      xml.loc("https://switchbakery.com#{product_path(p)}")
      xml.changefreq("weekly")
      if p.updated_at.nil?
        xml.lastmod(p.created_at.strftime("%Y-%m-%d"))
      else
        xml.lastmod(p.updated_at.strftime("%Y-%m-%d"))
      end
    end
  end

  for p in @pages
    xml.url do
      xml.loc("https://switchbakery.com#{page_path(p)}")
      xml.changefreq("daily")
      if p.updated_at.nil?
        xml.lastmod(p.created_at.strftime("%Y-%m-%d"))
      else
        xml.lastmod(p.updated_at.strftime("%Y-%m-%d"))
      end
    end
  end

  for p in @posts
    xml.url do
      xml.loc("https://switchbakery.com#{update_path(p)}")
      xml.changefreq("daily")
      if p.updated_at.nil?
        xml.lastmod(p.created_at.strftime("%Y-%m-%d"))
      else
        xml.lastmod(p.updated_at.strftime("%Y-%m-%d"))
      end
    end
  end
  
end
