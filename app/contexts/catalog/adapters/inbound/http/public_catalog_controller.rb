module Catalog
  module Adapters
    module Inbound
      module Http
        class PublicCatalogController < ApplicationController
          def index
            result = Catalog::Application::Queries::ListPublicVideoTypes.call(account: workspace_for(:client))
            @video_types = result.data.fetch(:video_types)
          end

          def show
            result = Catalog::Application::Queries::FindVideoType.call(id: params[:id])
            if result.success?
              @video_type = result.data.fetch(:video_type)
            else
              head :not_found
            end
          end
        end
      end
    end
  end
end
