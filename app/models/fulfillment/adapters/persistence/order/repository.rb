module Fulfillment
  module Adapters
    module Persistence
      module Order
        class Repository < Fulfillment::Domain::Repositories::Order::Contract
          def find_for_show(id)
            ::Project.includes(:owner, :participant, comments: :author_account, video_type_selections: :video_type).find(id)
          end

          def find_for_edit(owner, id)
            owner.projects.includes(video_type_selections: :video_type).find(id)
          end

          def find_for_workspace_action(participant, id)
            participant.projects.find(id)
          end

          def find_or_create_draft_for_owner(owner, participant)
            owner.projects.draft.order(created_at: :desc).first || owner.projects.create!(participant: participant, status: :draft)
          end

          def replace_selections(order, selections)
            order.video_type_selections.delete_all

            selections.each do |selection|
              order.video_type_selections.create!(
                video_type_id: resolve_video_type_id(selection),
                quantity: selection.fetch(:quantity)
              )
            end
          end

          private

          def resolve_video_type_id(selection)
            legacy_video_type_id = selection[:video_type_id].presence || selection[:offer_variant_id].presence
            raise KeyError, "video type id is required" if legacy_video_type_id.blank?

            return legacy_video_type_id.to_i if VideoType.exists?(id: legacy_video_type_id)

            offer_variant = OfferVariant.find(legacy_video_type_id)
            video_type = VideoType.find_or_create_by!(name: offer_variant.name) do |vt|
              vt.description = offer_variant.description
              vt.price_cents = offer_variant.price_cents
              vt.output_format = offer_variant.output_format.presence || "mp4"
            end
            video_type.id
          end
        end
      end
    end
  end
end
