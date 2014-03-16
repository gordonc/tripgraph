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

    config.cache_store = :redis_store, { :namespace => "cache", :expires_in => 1.month }

    config.elasticsearch = { :url => ENV['BONSAI_URL'] || "http://localhost:9200", :log => false, :trace => false }

    config.geocoder = {
      :throttle => (24 * 60 * 60) / 2500,
      :cc_tlds => {
        "England" => "United Kingdom",
        "Inca Trail" => "Peru",
        "Kilimanjaro" => "Tanzania",
        "Machu Picchu" => "Peru",
        "Scotland" => "United Kingdom",
      }
    }

    config.after_initialize do
      require 'aquarium'
      require 'open-uri'
      require 'google_geocoder'

      include Aquarium::Aspects

      Aspect.new :around, :calls_to => [:open_uri], :method_options => [:class], :on_types => [OpenURI] do |join_point, object, name|
        uri = URI::Generic === name ? name : URI.parse(name)
        if uri.host.eql?("maps.googleapis.com")
          s = Redis::Semaphore.new(:google_geocoder)
          result = nil
          s.lock do
            sleep(config.geocoder[:throttle])
            result = join_point.proceed
          end
        else
          result = join_point.proceed
        end

        result
      end

      Aspect.new :around, :calls_to => [:get_cc_tld], :on_types => [GoogleGeocoder::GoogleGeocoder] do |join_point, object, country|
        if config.geocoder[:cc_tlds].key?(country)
          result = join_point.proceed(config.geocoder[:cc_tlds][country])
        else
          result = join_point.proceed
        end

        result
      end
    end
  end
end
