# frozen_string_literal: true

require "rails_helper"

RSpec.describe Features do
  describe ".payment_simulation_devtool_enabled?" do
    it "returns true in development by default" do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
      expect(described_class.payment_simulation_devtool_enabled?).to be true
    end

    it "can be disabled in development via ENV flag" do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
      stub_const("ENV", ENV.to_h.merge("FEATURE_PAYMENT_SIMULATION" => "false"))
      expect(described_class.payment_simulation_devtool_enabled?).to be false
    end

    it "returns false in test environment" do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("test"))
      expect(described_class.payment_simulation_devtool_enabled?).to be false
    end

    it "returns false in qa environment" do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("qa"))
      expect(described_class.payment_simulation_devtool_enabled?).to be false
    end

    it "returns false in staging environment" do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("staging"))
      expect(described_class.payment_simulation_devtool_enabled?).to be false
    end

    it "returns false in production environment" do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
      expect(described_class.payment_simulation_devtool_enabled?).to be false
    end
  end
end
