require 'aquarium'

include Aquarium::Aspects

require 'open-uri'
Aspect.new :around, :calls_to => [:open_uri], :method_options => [:class], :on_types => [OpenURI] do |join_point, object, name|
  delay = (24 * 60 * 60) / 2500

  uri = URI::Generic === name ? name : URI.parse(name)
  if uri.host.eql?("maps.googleapis.com")
    s = Redis::Semaphore.new(:google_geocoder)
    result = nil
    s.lock do
      sleep(delay)
      result = join_point.proceed
    end
  else
    result = join_point.proceed
  end

  result
end
