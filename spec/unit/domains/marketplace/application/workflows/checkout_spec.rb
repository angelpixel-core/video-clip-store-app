require "rails_helper"

RSpec.describe Marketplace::Application::Workflows::Checkout do
  describe "validation" do
    it "fails before calling downstream ports when the submission has no line items" do
      submission = submission_double(line_items: [])
      ports = downstream_ports

      result = described_class.call(submission:, **ports)

      expect(result).to be_failure
      expect(result.code).to eq(:invalid_record)
      expect(result.message).to eq("Submission requires at least one line item")
      expect(ports.fetch(:payment_port)).not_to have_received(:call)
      expect(ports.fetch(:capacity_port)).not_to have_received(:reserve)
    end
  end

  it "stops before reserving when availability rejects a line item" do
    line_item = double("LineItem", quantity: 1, offer_variant: :offer)
    submission = submission_double(line_items: [ line_item ])
    ports = downstream_ports
    availability = Catalog::Domain::ValueObjects::Availability.new(available: false, reason: :marketplace_closed)
    allow(ports.fetch(:availability_port)).to receive(:evaluate).and_return(availability)

    result = described_class.call(submission:, **ports)

    expect(result).to be_failure
    expect(result.code).to eq(:unavailable)
    expect(result.data).to include(line_item:, availability:)
    expect(ports.fetch(:capacity_port)).not_to have_received(:reserve)
    expect(ports.fetch(:payment_port)).not_to have_received(:call)
  end

  it "propagates a reservation failure without processing payment" do
    submission = submission_double
    ports = downstream_ports
    reservation_failure = Core::Result::Failure.(message: "reservation conflict", code: :reservation_conflict, data: { order_id: 1 })
    allow(ports.fetch(:capacity_port)).to receive(:reserve).and_return(reservation_failure)

    result = described_class.call(submission:, **ports)

    expect(result).to be_failure
    expect(result.code).to eq(:reservation_conflict)
    expect(result.data).to include(submission:, order: submission.order, order_id: 1)
    expect(ports.fetch(:payment_port)).not_to have_received(:call)
    expect(ports.fetch(:capacity_port)).not_to have_received(:release)
  end

  it "passes payment arguments and returns the complete success contract" do
    submission = submission_double
    ports = downstream_ports
    payment = double("Payment", id: 123, active?: true)
    reservation = double("Reservation", order_id: 1)
    gateway = double("PaymentGateway")
    allow(ports.fetch(:capacity_port)).to receive(:reserve).and_return(Core::Result::Success.(data: { reservation: }))
    allow(ports.fetch(:payment_port)).to receive(:call).and_return(Core::Result::Success.(data: { payment: }))
    allow(ports.fetch(:capacity_port)).to receive(:commit).and_return(Core::Result::Success.(data: { reservation: }))

    result = described_class.call(submission:, payment_gateway: gateway, **ports)

    expect(ports.fetch(:payment_port)).to have_received(:call).with(
      order: submission.order,
      provider: "fake",
      payment_method_type: "card",
      gateway:
    )
    expect(ports.fetch(:capacity_port)).to have_received(:reserve).with(order_id: 1, units: 1)
    expect(ports.fetch(:capacity_port)).to have_received(:commit).with(reservation:)
    expect(result).to be_success
    expect(result.data).to eq(submission:, order: submission.order, payment:, reservation:)
  end

  it "releases capacity when payment fails" do
    submission = submission_double
    ports = downstream_ports
    reservation = double("Reservation", order_id: 1)
    payment_failure = Core::Result::Failure.(message: "gateway down", code: :provider_error, data: { provider: "fake" })
    allow(ports.fetch(:capacity_port)).to receive(:reserve).and_return(Core::Result::Success.(data: { reservation: }))
    allow(ports.fetch(:payment_port)).to receive(:call).and_return(payment_failure)

    result = described_class.call(submission:, **ports)

    expect(result).to be_failure
    expect(result.message).to eq("gateway down")
    expect(result.code).to eq(:provider_error)
    expect(result.data).to include(submission:, order: submission.order, provider: "fake")
    expect(ports.fetch(:capacity_port)).to have_received(:release).with(reservation:)
    expect(ports.fetch(:capacity_port)).not_to have_received(:commit)
  end

  it "releases capacity when payment is inactive at the success checkpoint" do
    submission = submission_double
    ports = downstream_ports
    reservation = double("Reservation", order_id: 1)
    payment = double("Payment", active?: false)
    allow(ports.fetch(:capacity_port)).to receive(:reserve).and_return(Core::Result::Success.(data: { reservation: }))
    allow(ports.fetch(:payment_port)).to receive(:call).and_return(Core::Result::Success.(data: { payment: }))

    result = described_class.call(submission:, **ports)

    expect(result).to be_failure
    expect(result.code).to eq(:invalid_record)
    expect(result.message).to eq("Payment must be active before success checkpoint")
    expect(ports.fetch(:capacity_port)).to have_received(:release).with(reservation:)
    expect(ports.fetch(:capacity_port)).not_to have_received(:commit)
  end

  it "releases capacity and skips follow-ups when commit fails" do
    submission = submission_double
    ports = downstream_ports
    reservation = double("Reservation", order_id: 1)
    payment = double("Payment", active?: true)
    commit_failure = Core::Result::Failure.(message: "commit failed", code: :commit_error, data: {})
    allow(ports.fetch(:capacity_port)).to receive(:reserve).and_return(Core::Result::Success.(data: { reservation: }))
    allow(ports.fetch(:payment_port)).to receive(:call).and_return(Core::Result::Success.(data: { payment: }))
    allow(ports.fetch(:capacity_port)).to receive(:commit).and_return(commit_failure)

    result = described_class.call(submission:, **ports)

    expect(result).to be_failure
    expect(result.code).to eq(:commit_error)
    expect(ports.fetch(:capacity_port)).to have_received(:release).with(reservation:)
    expect(ports.fetch(:invoicing_port)).not_to have_received(:call)
    expect(ports.fetch(:notification_port)).not_to have_received(:call)
  end

  it "runs invoicing and notification only after a successful commit" do
    submission = submission_double
    ports = downstream_ports
    reservation = double("Reservation", order_id: 1)
    payment = double("Payment", active?: true)
    allow(ports.fetch(:capacity_port)).to receive(:reserve).and_return(Core::Result::Success.(data: { reservation: }))
    allow(ports.fetch(:payment_port)).to receive(:call).and_return(Core::Result::Success.(data: { payment: }))
    allow(ports.fetch(:capacity_port)).to receive(:commit).and_return(Core::Result::Success.(data: { reservation: }))

    result = described_class.call(submission:, **ports)

    expect(result).to be_success
    expect(ports.fetch(:invoicing_port)).to have_received(:call).with(payment:)
    expect(ports.fetch(:notification_port)).to have_received(:call).with(order: submission.order)
  end

  private

  def submission_double(line_items: [ double("LineItem", quantity: 1, offer_variant: :offer) ])
    order = double("Order", id: 1, submitted?: true)
    double("Submission", order:, fulfillment_account: double("Account"), line_items:, payment_provider: "fake", payment_method_type: "card")
  end

  def downstream_ports
    {
      payment_port: instance_double("PaymentPort").tap { |port| allow(port).to receive(:call) },
      availability_port: instance_double("AvailabilityPort").tap do |port|
        allow(port).to receive(:evaluate).and_return(double("Availability", unavailable?: false))
      end,
      capacity_port: instance_double("CapacityPort").tap do |port|
        allow(port).to receive(:reserve).and_return(Core::Result::Success.(data: { reservation: double("Reservation", order_id: 1) }))
        allow(port).to receive(:commit).and_return(Core::Result::Success.(data: {}))
        allow(port).to receive(:release)
      end,
      invoicing_port: instance_double("InvoicingPort").tap { |port| allow(port).to receive(:call) },
      notification_port: instance_double("NotificationPort").tap { |port| allow(port).to receive(:call) }
    }
  end
end
