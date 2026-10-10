# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# --- Phase 1: Identity & Multi-Tenancy ---

tenant = Identity::Domain::Aggregates::Tenant.find_or_create_by!(slug: "default") do |t|
  t.name = "Wanderlust Default Tenant"
end

organization = Identity::Domain::Aggregates::Organization.find_or_create_by!(slug: "wanderlust-videos", tenant_id: tenant.id) do |o|
  o.name = "Wanderlust Videos"
end

pm_email = ENV.fetch("DEFAULT_PM_WORKSPACE_EMAIL", "pm@example.com")
pm_user = Identity::Domain::Aggregates::User.find_or_create_by!(email: pm_email) do |u|
  u.name = "Default Project Manager"
  u.notification_settings = {}
end

pm_account = Identity::Domain::Aggregates::Account.find_or_create_by!(email: pm_email, role: "pm") do |a|
  a.name = pm_user.name
  a.organization_id = organization.id
end

Identity::Domain::Aggregates::Membership.find_or_create_by!(user_id: pm_user.id, account_id: pm_account.id) do |m|
  m.role = "pm"
end

client_email = ENV.fetch("DEFAULT_CLIENT_WORKSPACE_EMAIL", "client@example.com")
client_user = Identity::Domain::Aggregates::User.find_or_create_by!(email: client_email) do |u|
  u.name = "Default Client"
  u.notification_settings = {}
end

client_account = Identity::Domain::Aggregates::Account.find_or_create_by!(email: client_email, role: "client") do |a|
  a.name = client_user.name
  a.organization_id = organization.id
end

Identity::Domain::Aggregates::Membership.find_or_create_by!(user_id: client_user.id, account_id: client_account.id) do |m|
  m.role = "client"
end

# --- Phase 2: Catalog & Legacy Offerings Sync ---

video_types = [
  { name: "Social Cut", description: "Short-form edit for social channels", price_cents: 15_000, output_format: "mp4" },
  { name: "Highlight Reel", description: "Polished highlight package", price_cents: 25_000, output_format: "mp4" }
]

video_types.each do |attrs|
  VideoType.find_or_create_by!(name: attrs[:name]) do |video_type|
    video_type.description = attrs[:description]
    video_type.price_cents = attrs[:price_cents]
    video_type.output_format = attrs[:output_format]
  end
end

video_editing_offer = Offer.find_or_create_by!(key: "video_editing") do |record|
  record.name = "Video Editing"
  record.description = "Video editing services"
  record.active = true
end

video_type_item = OfferItemType.find_or_create_by!(key: "video_type") do |record|
  record.name = "Video Type"
  record.description = "Selectable video editing component"
  record.input_kind = "selection"
  record.active = true
end

OfferItemTypeAssignment.find_or_create_by!(offer_id: video_editing_offer.id, offer_item_type_id: video_type_item.id) do |assignment|
  assignment.required = true
  assignment.position = 1
  assignment.min_selections = 1
  assignment.max_selections = 10
end

VideoType.order(:name).each_with_index do |existing_video_type, index|
  OfferVariant.find_or_create_by!(offer_id: video_editing_offer.id, key: existing_video_type.name.parameterize(separator: "_")) do |variant|
    variant.offer_item_type_id = video_type_item.id
    variant.name = existing_video_type.name
    variant.description = existing_video_type.description
    variant.price_cents = existing_video_type.price_cents
    variant.output_format = existing_video_type.output_format
    variant.active = true
    variant.position = index + 1
  end
end

# --- Phase 3: Sample Data (Draft Project / Order) ---

Project.find_or_create_by!(owner_account_id: client_account.id, participant_account_id: pm_account.id, name: "Seed Project") do |project|
  project.raw_footage_url = "https://example.com/raw-footage.mov"
  project.status = "draft"
end

puts "Seed data successfully populated!"
