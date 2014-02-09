require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'aquarium'
require 'open-uri'

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

    config.cache_store = :redis_store, { :namespace => "cache" }
    config.elasticsearch = { :trace => false }
    config.geocoder = { :throttle => (24 * 60 * 60) / 2500 }

    config.after_initialize do
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
    end
  end
end
