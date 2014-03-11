class SearchController < ApplicationController
  def index
    params.require(:q)
    query = {
      multi_match: {
        query: params[:q],
        fields: ['description', 'trip.name', 'trip.description', 'place.name']
      }
    }

    filter = nil
    if params.has_key?(:top_left) and params.has_key?(:bottom_right)
      filter = {
        geo_bounding_box: {
          'place.location' => {
            top_left: params[:top_left],
            bottom_right: params[:bottom_right] 
          }
        }
      }
    end

    @trip_places = TripPlace.search(query, filter)
  end
end
