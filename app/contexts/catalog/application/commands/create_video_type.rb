module Catalog
  module Application
    module Commands
      class CreateVideoType
        def self.call(attrs:)
          new(attrs:).call
        end

        def initialize(attrs:)
          @attrs = attrs.to_h
        end

        def call
          video_type = Catalog::Domain::Entities::VideoType.create!(attrs)
          Core::Result::Success.(data: { video_type: video_type })
        rescue ActiveRecord::RecordInvalid => e
          Core::Result::Failure.(message: e.message, code: :invalid_record)
        end

        private

        attr_reader :attrs
      end
    end
  end
end
