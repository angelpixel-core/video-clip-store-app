require "rails_helper"

RSpec.describe Identity::Domain::Repositories::User::Contract do
  it "declares the repository interface" do
    contract = described_class.new

    expect { contract.find_by_email("alice@example.com") }.to raise_error(NotImplementedError)
    expect { contract.find_by_email_and_role("alice@example.com", :client) }.to raise_error(NotImplementedError)
    expect { contract.find_by_role(:client) }.to raise_error(NotImplementedError)
    expect { contract.find_by_id(1) }.to raise_error(NotImplementedError)
    expect { contract.save(double("user")) }.to raise_error(NotImplementedError)
  end
end
