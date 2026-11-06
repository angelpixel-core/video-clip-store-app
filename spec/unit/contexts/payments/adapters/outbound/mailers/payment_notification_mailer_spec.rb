require "rails_helper"

RSpec.describe Payments::Adapters::Outbound::Mailers::PaymentNotificationMailer do
  describe "payment_status_changed" do
    it "sends a compact text email for a succeeded payment to the client" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
      payment = Payments::Domain::Aggregates::Payment.create!(project: project, status: :succeeded, provider: "fake", idempotency_key: SecureRandom.uuid, amount_cents: 50_000, currency: "USD", provider_reference: "fake-abc123")
      intent = Payments::Domain::Entities::PaymentNotificationIntent.create!(payment: payment, project: project, event_type: "payment.succeeded", from_status: "processing", to_status: "succeeded", payload: { "payment_id" => payment.id }, status: :pending, scheduled_at: Time.current)

      mail = described_class.payment_status_changed(intent, recipient_role: :client)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Payment succeeded for Project")
      expect(mail.body.encoded).to include("Your payment was confirmed")
      expect(mail.body.encoded).to include("Project: Project")
      expect(mail.body.encoded).to include("Client: Client")
      expect(mail.body.encoded).to include("Payment status: Processing -> Succeeded")
      expect(mail.body.encoded).to include("Amount: USD 500.00")
    end

    it "sends a compact text email for a succeeded payment to the pm" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
      payment = Payments::Domain::Aggregates::Payment.create!(project: project, status: :succeeded, provider: "fake", idempotency_key: SecureRandom.uuid, amount_cents: 25_000, currency: "USD", provider_reference: "fake-def456")
      intent = Payments::Domain::Entities::PaymentNotificationIntent.create!(payment: payment, project: project, event_type: "payment.succeeded", from_status: "processing", to_status: "succeeded", payload: { "payment_id" => payment.id, "provider_event_id" => "evt_123", "webhook_event_id" => 5 }, status: :pending, scheduled_at: Time.current)

      mail = described_class.payment_status_changed(intent, recipient_role: :pm)

      expect(mail.to).to eq([ "pm@example.com" ])
      expect(mail.subject).to eq("Payment succeeded for Project - PM update")
      expect(mail.body.encoded).to include("Payment confirmation succeeded")
      expect(mail.body.encoded).to include("Webhook event id: 5")
      expect(mail.body.encoded).to include("Provider event id: evt_123")
      expect(mail.body.encoded).to include("Project status: Succeeded")
    end

    it "sends a compact text email for a failed payment to the client" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
      payment = Payments::Domain::Aggregates::Payment.create!(project: project, status: :failed, provider: "fake", idempotency_key: SecureRandom.uuid, amount_cents: 25_000, currency: "USD", provider_reference: "fake-def456")
      intent = Payments::Domain::Entities::PaymentNotificationIntent.create!(payment: payment, project: project, event_type: "payment.failed", from_status: "processing", to_status: "failed", payload: { "payment_id" => payment.id }, status: :pending, scheduled_at: Time.current)

      mail = described_class.payment_status_changed(intent, recipient_role: :client)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Payment failed for Project")
      expect(mail.body.encoded).to include("Your payment could not be confirmed")
      expect(mail.body.encoded).to include("Payment status: Processing -> Failed")
      expect(mail.body.encoded).to include("Amount: USD 250.00")
    end

    it "sends a compact text email for a failed payment to the pm" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
      payment = Payments::Domain::Aggregates::Payment.create!(project: project, status: :failed, provider: "fake", idempotency_key: SecureRandom.uuid, amount_cents: 25_000, currency: "USD", provider_reference: "fake-def456")
      intent = Payments::Domain::Entities::PaymentNotificationIntent.create!(payment: payment, project: project, event_type: "payment.failed", from_status: "processing", to_status: "failed", payload: { "payment_id" => payment.id, "provider_event_id" => "evt_456", "webhook_event_id" => 7 }, status: :pending, scheduled_at: Time.current)

      mail = described_class.payment_status_changed(intent, recipient_role: :pm)

      expect(mail.to).to eq([ "pm@example.com" ])
      expect(mail.subject).to eq("Payment failed for Project - PM update")
      expect(mail.body.encoded).to include("Payment confirmation failed")
      expect(mail.body.encoded).to include("Webhook event id: 7")
      expect(mail.body.encoded).to include("Provider event id: evt_456")
      expect(mail.body.encoded).to include("Project status: Failed")
    end

    it "includes the normalized failure reason for a final failed payment" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
      payment = Payments::Domain::Aggregates::Payment.create!(project: project, status: :failed, provider: "fake", idempotency_key: SecureRandom.uuid, amount_cents: 25_000, currency: "USD", provider_reference: "fake-def456")
      intent = Payments::Domain::Entities::PaymentNotificationIntent.create!(payment: payment, project: project, event_type: "payment.failed_final", from_status: "processing", to_status: "failed", payload: { "payment_id" => payment.id, "failure_reason_code" => "provider_timeout" }, status: :pending, scheduled_at: Time.current)

      mail = described_class.payment_status_changed(intent, recipient_role: :client)

      expect(mail.body.encoded).to include("Failure reason: provider_timeout")
    end

    it "sends the final failed payment email to the pm with the normalized reason" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
      payment = Payments::Domain::Aggregates::Payment.create!(project: project, status: :failed, provider: "fake", idempotency_key: SecureRandom.uuid, amount_cents: 25_000, currency: "USD", provider_reference: "fake-def456")
      intent = Payments::Domain::Entities::PaymentNotificationIntent.create!(payment: payment, project: project, event_type: "payment.failed_final", from_status: "processing", to_status: "failed", payload: { "payment_id" => payment.id, "provider_event_id" => "evt_789", "webhook_event_id" => 9, "failure_reason_code" => "provider_timeout" }, status: :pending, scheduled_at: Time.current)

      mail = described_class.payment_status_changed(intent, recipient_role: :pm)

      expect(mail.to).to eq([ "pm@example.com" ])
      expect(mail.subject).to eq("Payment failed for Project - PM update")
      expect(mail.body.encoded).to include("Payment confirmation failed")
      expect(mail.body.encoded).to include("Failure reason: provider_timeout")
      expect(mail.body.encoded).to include("Webhook event id: 9")
      expect(mail.body.encoded).to include("Provider event id: evt_789")
    end
  end
end
