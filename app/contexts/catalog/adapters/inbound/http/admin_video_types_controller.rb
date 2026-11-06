module Catalog
  module Adapters
    module Inbound
      module Http
        class AdminVideoTypesController < ApplicationController
          def index
            @video_types = Catalog::Application::Queries::ListAdminVideoTypes.call.data.fetch(:video_types)
          end

          def create
            result = Catalog::Application::Commands::CreateVideoType.call(attrs: video_type_params)
            if result.success?
              redirect_to admin_video_types_path, notice: "Video type created."
            else
              redirect_to admin_video_types_path, alert: result.message
            end
          end

          def update
            video_type = Catalog::Domain::Repositories::OfferRepository.find_by_id(params[:id])
            result = Catalog::Application::Commands::UpdateVideoType.call(video_type:, attrs: video_type_params)

            if result.success?
              redirect_to admin_video_types_path, notice: "Video type updated."
            else
              redirect_to admin_video_types_path, alert: result.message
            end
          end

          private

          def video_type_params
            params.require(:video_type).permit(:name, :description, :price_cents, :output_format)
          end
        end
      end
    end
  end
end
