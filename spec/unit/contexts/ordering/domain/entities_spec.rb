require "rails_helper"

RSpec.describe "Ordering entities" do
  it "keeps customer and offering snapshots historical" do
    customer = Ordering::Domain::Entities::CustomerSnapshot.new(account_id: 1, name: "Client", email: "CLIENT@example.com", role: "client")
    offering = Struct.new(:id, :uid, :name, :description, :price_cents, :output_format, keyword_init: true).new(
      id: 7,
      uid: "off_7",
      name: "Highlight Reel",
      description: "Short edit",
      price_cents: 25_000,
      output_format: "mp4"
    )
    snapshot = Ordering::Domain::Entities::OfferingSnapshot.from_offering(offering)

    expect(customer.to_h).to eq(account_id: 1, name: "Client", email: "client@example.com", role: "client")
    expect(snapshot.to_h).to eq(offering_id: 7, offering_uid: "off_7", name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
  end

  it "builds source videos without requiring them in draft" do
    source_video = Ordering::Domain::Entities::SourceVideo.new

    expect(source_video.to_h).to eq({})
  end

  it "calculates a line item total" do
    offering = Ordering::Domain::Entities::OfferingSnapshot.new(offering_id: 7, name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    line = Ordering::Domain::Entities::LineItem.new(offering_snapshot: offering, quantity: 2)

    expect(line.line_total_cents).to eq(50_000)
    expect(line.line_total.to_i).to eq(50_000)
  end
end
