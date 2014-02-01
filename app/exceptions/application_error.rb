class ApplicationError < StandardError
  include Nesty::NestedError
end
