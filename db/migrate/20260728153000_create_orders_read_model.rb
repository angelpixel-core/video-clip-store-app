class CreateOrdersReadModel < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :owner_account, null: false, foreign_key: { to_table: :accounts }
      t.references :participant_account, null: false, foreign_key: { to_table: :accounts }
      t.string :name
      t.string :raw_footage_url
      t.json :raw_footage_metadata
      t.json :customer_snapshot
      t.string :uid
      t.string :status, null: false, default: "draft"
      t.string :payment_status, null: false, default: "unpaid"
      t.string :production_status, null: false, default: "not_started"
      t.string :delivery_status, null: false, default: "not_ready"

      t.timestamps
    end

    add_index :orders, :status
    add_index :orders, :uid, unique: true

    create_table :order_lines do |t|
      t.references :order, null: false, foreign_key: true
      t.json :offering_snapshot, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :line_total_cents, null: false, default: 0

      t.timestamps
    end

    create_table :source_videos do |t|
      t.references :order, null: false, foreign_key: true
      t.string :source_url
      t.text :editing_instructions

      t.timestamps
    end

    Project.includes(:owner, :participant, video_type_selections: :video_type).find_each do |project|
      sync_order_from_project(project)
    end
  end

  private

  def sync_order_from_project(project)
    order = Ordering::Adapters::Persistence::Order::OrderRecord.find_or_initialize_by(id: project.id)
    order.owner_account_id = project.owner_account_id
    order.participant_account_id = project.participant_account_id
    order.name = project.name
    order.raw_footage_url = project.raw_footage_url
    order.raw_footage_metadata = project.raw_footage_metadata
    order.customer_snapshot = {
      account_id: project.owner.id,
      account_uid: project.owner.try(:uid),
      name: project.owner.name,
      email: project.owner.email,
      role: project.owner.role
    }
    order.uid = project.id.to_s
    order.status = map_project_status(project.status)
    order.payment_status = project.active_payment&.status.presence || (project.draft? ? "unpaid" : "pending")
    order.production_status = map_project_status_to_production(project.status)
    order.delivery_status = map_project_status_to_delivery(project.status)
    order.created_at = project.created_at
    order.updated_at = project.updated_at
    order.save!

    order.order_line_records.delete_all
    project.video_type_selections.includes(:video_type).each do |selection|
      order.order_line_records.create!(
        offering_snapshot: {
          offering_id: selection.video_type_id,
          offering_uid: selection.video_type.try(:uid),
          name: selection.video_type.name,
          description: selection.video_type.description,
          price_cents: selection.video_type.price_cents,
          output_format: selection.video_type.output_format
        },
        quantity: selection.quantity,
        line_total_cents: selection.quantity * selection.video_type.price_cents,
        created_at: project.created_at,
        updated_at: project.updated_at
      )
    end

    if project.raw_footage_url.present?
      source_video = order.source_video_record || order.build_source_video_record
      source_video.source_url = project.raw_footage_url
      source_video.editing_instructions = nil
      source_video.created_at = project.created_at
      source_video.updated_at = project.updated_at
      source_video.save!
    end
  end

  def map_project_status(status)
    case status.to_s
    when "draft"
      "draft"
    when "pending"
      "placed"
    when "in_progress"
      "confirmed"
    else
      "completed"
    end
  end

  def map_project_status_to_production(status)
    case status.to_s
    when "draft", "pending"
      "not_started"
    when "in_progress"
      "in_progress"
    else
      "completed"
    end
  end

  def map_project_status_to_delivery(status)
    case status.to_s
    when "draft", "pending"
      "not_ready"
    when "in_progress"
      "ready"
    else
      "delivered"
    end
  end
end
