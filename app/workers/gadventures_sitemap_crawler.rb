require 'nokogiri'
require 'open-uri'

class GadventuresSitemapCrawler
  include Sidekiq::Worker
  def perform(url)

    uri = URI.parse(url)

    r = Rails.cache.fetch(uri.to_s) do
      open(uri).read
    end

    doc = Nokogiri::HTML(r)

    doc.css("li#sitemap-tours>ul.sitemap.clearfix>li>a").each do |a|
      trip_uri = uri + a['href']
      GadventuresTripParser.perform_async(trip_uri.to_s)
    end

  end
end
