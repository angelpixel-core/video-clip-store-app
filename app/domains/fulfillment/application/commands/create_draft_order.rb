module Fulfillment
  module Application
    module Commands
      class CreateDraftOrder
        def self.call(client_workspace:, pm_workspace:, repository:)
          new(client_workspace:, pm_workspace:, repository:).call
        end

        def initialize(client_workspace:, pm_workspace:, repository:)
          @client_workspace = client_workspace
          @pm_workspace = pm_workspace
          @repository = repository
        end

        def call
          Core::Result::Success.(data: { order: draft_order })
        end

        private

        attr_reader :client_workspace, :pm_workspace, :repository

        def draft_order
          repository.find_or_create_draft_for_owner(client_workspace, pm_workspace)
        end
      end
    end
  end
end
