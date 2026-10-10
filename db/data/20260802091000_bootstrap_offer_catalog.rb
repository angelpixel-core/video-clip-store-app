# frozen_string_literal: true

class BootstrapOfferCatalog < ActiveRecord::Migration[8.1]
  def up
    video_editing_offer = bootstrap_offer!(key: "video_editing", name: "Video Editing", description: "Video editing services")
    video_type = bootstrap_offer_item_type!(key: "video_type", name: "Video Type", description: "Selectable video editing component")

    bootstrap_offer_item_type_assignment!(offer: video_editing_offer, offer_item_type: video_type, required: true, position: 1, min_selections: 1, max_selections: 10)

    legacy_video_type_model.order(:name).find_each.with_index(1) do |existing_video_type, position|
      bootstrap_offer_variant!(
        offer: video_editing_offer,
        offer_item_type: video_type,
        key: existing_video_type.name.parameterize(separator: "_"),
        name: existing_video_type.name,
        description: existing_video_type.description,
        price_cents: existing_video_type.price_cents,
        output_format: existing_video_type.output_format,
        position: position
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def bootstrap_offer!(key:, name:, description:)
    offer = offer_model.find_or_create_by!(key: key) do |record|
      record.name = name
      record.description = description
      record.active = true
    end

    offer.update!(name: name, description: description, active: true) if offer.name != name || offer.description != description || !offer.active?
    offer
  end

  def bootstrap_offer_item_type!(key:, name:, description:)
    item_type = offer_item_type_model.find_or_create_by!(key: key) do |record|
      record.name = name
      record.description = description
      record.input_kind = "selection"
      record.active = true
    end

    if item_type.name != name || item_type.description != description || item_type.input_kind != "selection" || !item_type.active?
      item_type.update!(name: name, description: description, input_kind: "selection", active: true)
    end
    item_type
  end

  def bootstrap_offer_item_type_assignment!(offer:, offer_item_type:, required:, position:, min_selections:, max_selections:)
    assignment = offer_item_type_assignment_model.find_or_initialize_by(offer_id: offer.id, offer_item_type_id: offer_item_type.id)
    assignment.required = required
    assignment.position = position
    assignment.min_selections = min_selections
    assignment.max_selections = max_selections
    assignment.save!
  end

  def bootstrap_offer_variant!(offer:, offer_item_type:, key:, name:, description:, price_cents:, output_format:, position:)
    variant = offer_variant_model.find_or_initialize_by(offer_id: offer.id, key: key)
    variant.offer_item_type_id = offer_item_type.id
    variant.name = name
    variant.description = description
    variant.price_cents = price_cents
    variant.output_format = output_format
    variant.active = true
    variant.position = position
    variant.save!
  end

  def offer_model
    bootstrap_model("offers")
  end

  def offer_item_type_model
    bootstrap_model("offer_item_types")
  end

  def offer_item_type_assignment_model
    bootstrap_model("offer_item_type_assignments")
  end

  def offer_variant_model
    bootstrap_model("offer_variants")
  end

  def legacy_video_type_model
    bootstrap_model("video_types")
  end

  def bootstrap_model(table_name)
    @bootstrap_models ||= {}
    @bootstrap_models[table_name] ||= Class.new(ActiveRecord::Base) { self.table_name = table_name }
  end
end
