module Fulfillment
  module Application
    module Commands
      class UpdateOrder
        def self.call(order:, participant:, attributes:, selections:, finalize:, repository:)
          new(order:, participant:, attributes:, selections:, finalize:, repository:).call
        end

        def initialize(order:, participant:, attributes:, selections:, finalize:, repository:)
          @order = order
          @participant = participant
          @attributes = attributes
          @selections = selections
          @finalize = finalize
          @repository = repository
        end

        def call
          if finalize
            SubmitOrder.call(order: order, participant: participant, attributes: attributes, selections: selections, repository: repository)
          else
            AutosaveDraftOrder.call(order: order, participant: participant, attributes: attributes, selections: selections, repository: repository)
          end
        end

        private

        attr_reader :order, :participant, :attributes, :selections, :finalize, :repository
      end
    end
  end
end
