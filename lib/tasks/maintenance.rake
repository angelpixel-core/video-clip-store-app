namespace :maintenance do
  desc "Reset order-owned data and workspace fixtures while keeping video types"
  task reset_order_data: :environment do
    reset_order_data!
  end
end

def reset_order_data!
  dry_run = ActiveModel::Type::Boolean.new.cast(ENV["DRY_RUN"])
  confirm = ENV["CONFIRM"].to_s.upcase == "YES"

  tables = [
    [ "clients", reset_data_model("clients") ],
    [ "pms", reset_data_model("pms") ],
    [ "payment_webhook_event_attempts", Payments::Domain::Entities::PaymentWebhookEventAttempt ],
    [ "payment_notification_intents", Payments::Domain::Entities::PaymentNotificationIntent ],
    [ "payment_attempts", Payments::Domain::Entities::PaymentAttempt ],
    [ "payment_webhook_events", Payments::Domain::Entities::PaymentWebhookEvent ],
    [ "comments", Comment ],
    [ "notifications", Notification ],
    [ "video_type_selections", VideoTypeSelection ],
    [ "payments", Payments::Domain::Aggregates::Payment ],
    [ "projects", Project ]
  ]

  puts "Order data reset plan:"
  tables.each do |table_name, model|
    puts "- #{table_name}: #{model.unscoped.count} rows"
  end

  if dry_run
    puts "Dry run only. Re-run with CONFIRM=YES to delete the rows above."
    return
  end

  unless confirm
    abort "Refusing to delete data without CONFIRM=YES. Run again with DRY_RUN=1 first."
  end

  ApplicationRecord.transaction do
    ApplicationRecord.connection.disable_referential_integrity do
      tables.each do |table_name, model|
        deleted = model.unscoped.delete_all
        puts "Deleted #{deleted} rows from #{table_name}"
      end
    end
  end

  puts "Order data reset complete. Order data and demo workspace records were removed; video types were preserved."
end

def reset_data_model(table_name)
  @reset_data_models ||= {}
  @reset_data_models[table_name] ||= Class.new(ApplicationRecord) { self.table_name = table_name }
end
