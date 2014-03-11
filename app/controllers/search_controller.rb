class SearchController < ApplicationController
  def index
    params.require(:q)
    @trip_places = Search.search(params[:q], params[:top_left], params[:bottom_right])
  end
end
