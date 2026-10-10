require "rails_helper"

require Rails.root.join("app/domains/billing/application/handlers/invoice_builder")

RSpec.describe Billing::Application::Handlers::InvoiceBuilder do
  it "builds a billed invoice document from a payment" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    order = Order.create!(owner: client, participant: pm, name: "Project Draft", raw_footage_url: "https://example.com/draft.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    order.video_type_selections.create!(video_type: video_type, quantity: 2)

    payment = Payments::Application::Commands::CreatePayment.call(order: order).data.fetch(:payment)
    payment.update!(status: :succeeded, confirmed_at: Time.current)

    invoice = described_class.call(payment: payment)

    expect(invoice).to be_a(Billing::Domain::Aggregates::Invoice)
    expect(invoice.number).to eq("INV-#{payment.id.to_s.rjust(7, '0')}")
    expect(invoice.filename).to eq("INV-#{payment.id.to_s.rjust(7, '0')}.html")
    expect(invoice.order_id).to eq(order.id)
    expect(invoice.order_name).to eq("Project Draft")
    expect(invoice.recipient_email).to eq("client@example.com")
    expect(invoice.lines.count).to eq(1)
    expect(invoice.lines.first.line_total_cents).to eq(50_000)
    expect(invoice.total_cents).to eq(50_000)
    expect(invoice.content_type).to eq("text/html")
    expect(invoice.content).to include("Invoice INV-#{payment.id.to_s.rjust(7, '0')}")
    expect(invoice.content).to include("Highlight Reel")
  end
end
