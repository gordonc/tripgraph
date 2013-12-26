class GAdventuresSitemapCrawler
  include Sidekiq::Worker
  def perform(url)

    require 'nokogiri'
    require 'open-uri'

    uri = URI.parse(url)

    r = Rails.cache.fetch(uri.to_s, :expires_in => 1.day) do
      open(uri).read
    end

    doc = Nokogiri::HTML(r)

    doc.css("li#sitemap-trips ul.sitemap.clearfix li a").each do |a|
      GAdventuresTripParser.perform_async((uri + a['href']).to_s)
    end

  end
end
