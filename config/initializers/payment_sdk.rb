# frozen_string_literal: true

require "payment/sdk"

Payment::SDK.configure do |config|
  config.base_url = ENV.fetch("PAYMENT_PLATFORM_BASE_URL", "http://payment-sandbox:8080/v1")
  config.api_key = ENV.fetch("PAYMENT_PLATFORM_API_KEY", "sandbox_test_key")
  config.signing_secret = ENV.fetch("PAYMENT_PLATFORM_SIGNING_SECRET", "sandbox_test_secret")
  config.logger = Rails.logger
end
