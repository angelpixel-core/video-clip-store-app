module Shared
  class DbHealthController < ApplicationController
    def show
      ActiveRecord::Base.connection.execute("SELECT 1")
      render plain: "ok", status: :ok
    rescue ActiveRecord::ActiveRecordError => e
      Rails.logger.error("DB health check failed: #{e.class}: #{e.message}")
      render plain: "db error", status: :internal_server_error
    end
  end
end

DbHealthController = Shared::DbHealthController
