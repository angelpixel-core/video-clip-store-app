require "rails_helper"

RSpec.describe "Ordering outbound ports" do
  it "keeps concrete invoicing and notification implementations out of the workflow core" do
    source = File.read(Rails.root.join("app/domains/ordering/application/commands/process_submission.rb"))

    expect(source).not_to include("Billing::")
    expect(source).not_to include("NotificationJob")
    expect(source).not_to include("Adapters::Outbound::Billing")
    expect(source).not_to include("Adapters::Outbound::Notifications")
    expect(source).to include("Ordering::Application::Ports::InvoicingPort")
    expect(source).to include("Ordering::Application::Ports::NotificationPort")
  end

  it "keeps concrete follow-up wiring at the fulfillment composition root" do
    source = File.read(Rails.root.join("app/domains/fulfillment/application/commands/submit_order.rb"))

    expect(source).to include("Ordering::Adapters::Outbound::Billing::InvoiceFollowUp")
    expect(source).to include("Ordering::Adapters::Outbound::Notifications::NotificationJob")
    expect(source).to include("invoicing_port: invoicing_port")
    expect(source).to include("notification_port: notification_port")
  end

  it "uses explicit provider contracts for each downstream capability" do
    expect(Ordering::Application::Ports::PaymentPort).to be < Core::Services::Provider
    expect(Ordering::Application::Ports::AvailabilityPort).to be < Core::Services::Provider
    expect(Ordering::Application::Ports::CapacityPort).to be < Core::Services::Provider
    expect(Ordering::Application::Ports::InvoicingPort).to be < Core::Services::Provider
    expect(Ordering::Application::Ports::NotificationPort).to be < Core::Services::Provider
  end

  it "adapts payment and availability calls" do
    payment_result = instance_double("PaymentResult")
    allow(Payments::Application::Commands::CreatePayment).to receive(:call).and_return(payment_result)
    allow(Catalog::Domain::Policies::AvailabilityPolicy).to receive(:evaluate).and_return(:availability)

    payment_port = Ordering::Adapters::Outbound::Payments::PaymentCommand.new
    availability_port = Ordering::Adapters::Outbound::Catalog::AvailabilityPolicy.new

    expect(payment_port.call(order: :order)).to eq(payment_result)
    expect(availability_port.evaluate(:offerable, quantity: 2, context: {})).to eq(:availability)
  end

  it "adapts capacity commands through one ordering port" do
    reservation = instance_double("Reservation", order_id: 42)
    result = instance_double("Result")
    allow(Capacity::Application::Commands::ReserveCapacity).to receive(:call).and_return(result)
    allow(Capacity::Application::Commands::CommitCapacity).to receive(:call).and_return(result)
    allow(Capacity::Application::Commands::ReleaseCapacity).to receive(:call).and_return(result)
    port = Ordering::Adapters::Outbound::Capacity::Commands.new

    expect(port.reserve(order_id: 42, units: 3)).to eq(result)
    expect(port.commit(reservation: reservation)).to eq(result)
    expect(port.release(reservation: reservation)).to eq(result)
  end

  it "adapts invoice and notification follow-up calls" do
    payment = instance_double("Payment", id: 7)
    order = instance_double("Order", id: 9)
    allow(Billing::Application::Handlers::GenerateInvoiceJob).to receive(:perform_later)
    allow(::NotificationJob).to receive(:perform_later)

    Ordering::Adapters::Outbound::Billing::InvoiceFollowUp.call(payment: payment)
    Ordering::Adapters::Outbound::Notifications::NotificationJob.call(order: order)

    expect(Billing::Application::Handlers::GenerateInvoiceJob).to have_received(:perform_later).with(7)
    expect(::NotificationJob).to have_received(:perform_later).with(9)
  end
end
