require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Tripgraph
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.cache_store = :redis_store, { :url => ENV['REDISCLOUD_URL'] || "redis://localhost", :namespace => "cache" }
    config.redis = { :url => ENV['REDISCLOUD_URL'] || "redis://localhost" }
    config.redis_semaphore = { :url => ENV['REDISCLOUD_URL'] || "redis://localhost" }

    config.elasticsearch = { :url => ENV['BONSAI_URL'] || "http://localhost:9200", :log => false, :trace => false }

    config.google_geocoder = {
      :throttle => (24 * 60 * 60) / 2500,
      :country_map => {
        "England" => "United Kingdom",
        "Scotland" => "United Kingdom",
        "Tibet" => "China",
      }
    }

    config.after_initialize do
      require 'trip_writer'
      require 'google_geocoder'
      require 'aquarium'
      require 'open-uri'
      require 'json'

      include Aquarium::Aspects
      logger = ActiveSupport::TaggedLogging.new(Rails.logger)

      # log TripWriter job executions
      Aspect.new :before, :calls_to => [:perform_async], :method_options => [:class], :on_types => [TripWriter] do |join_point, object, trip|
        logger.tagged(TripWriter.name) { logger.debug trip.to_json }
      end

      # throttle GoogleGeocoder geocoding requests
      Aspect.new :around, :calls_to => [:open_uri], :method_options => [:class], :on_types => [OpenURI] do |join_point, object, name|
        uri = URI::Generic === name ? name : URI.parse(name)
        if uri.host.eql?("maps.googleapis.com")
          s = Redis::Semaphore.new(:google_geocoder, config.redis_semaphore)
          result = nil
          s.lock do
            sleep(config.google_geocoder[:throttle])
            result = join_point.proceed
          end
        else
          result = join_point.proceed
        end

        result
      end

      # substitute GoogleGeocoder cc_tld lookup
      Aspect.new :around, :calls_to => [:get_cc_tld], :on_types => [GoogleGeocoder::GoogleGeocoder] do |join_point, object, country|
        if config.google_geocoder[:country_map].key?(country)
          result = join_point.proceed(config.google_geocoder[:country_map][country])
        else
          result = join_point.proceed
        end

        result
      end
    end
  end
end
