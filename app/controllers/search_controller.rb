class SearchController < ApplicationController
  respond_to :json

  def index
    params.require(:q)
    @trip_places = Search.search(params[:q], params[:top_left], params[:bottom_right])
    respond_with @trip_places
  end
end
