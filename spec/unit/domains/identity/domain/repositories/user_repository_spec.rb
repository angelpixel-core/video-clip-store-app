require "rails_helper"

RSpec.describe Identity::Domain::Repositories::UserRepository do
  it "delegates lookups and persistence to the adapter boundary" do
    repository = instance_double(Identity::Domain::Repositories::User::Contract)
    user = double("user")

    allow(described_class).to receive(:repository).and_return(repository)

    expect(repository).to receive(:find_by_email).with("alice@example.com")
    expect(repository).to receive(:find_by_role).with(:client)
    expect(repository).to receive(:find_by_email_and_role).with("alice@example.com", :client)
    expect(repository).to receive(:find_by_id).with(7)
    expect(repository).to receive(:save).with(user)

    described_class.find_by_email("alice@example.com")
    described_class.find_by_role(:client)
    described_class.find_by_email_and_role("alice@example.com", :client)
    described_class.find_by_id(7)
    described_class.save(user)
  end
end
