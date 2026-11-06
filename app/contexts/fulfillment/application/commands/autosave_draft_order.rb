module Fulfillment
  module Application
    module Commands
      class AutosaveDraftOrder
        def self.call(order:, participant:, attributes:, selections:, repository:)
          new(order:, participant:, attributes:, selections:, repository:).call
        end

        def initialize(order:, participant:, attributes:, selections:, repository:)
          @order = order
          @participant = participant
          @attributes = attributes
          @selections = selections
          @repository = repository
        end

        def call
          order.class.transaction do
            order.with_lock do
              order.assign_attributes(attributes)
              order.participant ||= participant
              order.status = :draft
              order.save!
              repository.replace_selections(order, selections)
              order.sync_order_listing!
            end
          end

          Core::Result::Success.(data: { order: order })
        rescue ActiveRecord::RecordInvalid, ArgumentError => e
          Core::Result::Failure.(message: e.message, code: :invalid_record, data: { order_id: order.id })
        end

        private

        attr_reader :order, :participant, :attributes, :selections, :repository
      end
    end
  end
end
