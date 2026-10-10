require "dry/system/container"

class AppContainer < Dry::System::Container
  include Payments::Container
  include Billing::Container
end
