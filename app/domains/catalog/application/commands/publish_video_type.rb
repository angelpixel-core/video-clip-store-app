module Catalog
  module Application
    module Commands
      class PublishVideoType
        def self.call(video_type:)
          Core::Result::Success.(data: { video_type: video_type })
        end
      end
    end
  end
end
