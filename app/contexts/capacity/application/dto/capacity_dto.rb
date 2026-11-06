module Capacity
  module Application
    module DTO
      CapacityDTO = Struct.new(:available, :available_units, keyword_init: true)
    end
  end
end
