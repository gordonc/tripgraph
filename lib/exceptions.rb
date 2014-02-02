module Exceptions
  class ApplicationError < StandardError
    include Nesty::NestedError
  end

  class TripParseError < ApplicationError; end
end
