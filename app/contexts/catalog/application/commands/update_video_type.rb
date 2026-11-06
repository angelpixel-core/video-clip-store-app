module Catalog
  module Application
    module Commands
      class UpdateVideoType
        def self.call(video_type:, attrs:)
          new(video_type:, attrs:).call
        end

        def initialize(video_type:, attrs:)
          @video_type = video_type
          @attrs = attrs.to_h
        end

        def call
          video_type.update!(attrs)
          Core::Result::Success.(data: { video_type: video_type })
        rescue ActiveRecord::RecordInvalid => e
          Core::Result::Failure.(message: e.message, code: :invalid_record)
        end

        private

        attr_reader :video_type, :attrs
      end
    end
  end
end
