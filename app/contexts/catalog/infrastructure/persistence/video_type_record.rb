module Catalog
  module Infrastructure
    module Persistence
      class VideoTypeRecord
        def self.model
          Catalog::Domain::Entities::VideoType
        end
      end
    end
  end
end
