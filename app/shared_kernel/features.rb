# frozen_string_literal: true

module Features
  def self.payment_simulation_devtool_enabled?
    # Strictly enabled ONLY in development environment.
    # Never enabled in test, qa, staging, or production.
    return false unless Rails.env.development?

    ENV.fetch("FEATURE_PAYMENT_SIMULATION", "true") == "true"
  end
end
