require "dry/system/container"

module Infrastructure
  module DI
    class AppContainer < Dry::System::Container
      include Payments::Infrastructure::DI::Container
      include Billing::Infrastructure::DI::Container
    end
  end
end

AppContainer = Infrastructure::DI::AppContainer
