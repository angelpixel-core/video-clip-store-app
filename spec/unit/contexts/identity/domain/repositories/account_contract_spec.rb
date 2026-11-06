require "rails_helper"

RSpec.describe Identity::Domain::Repositories::Account::Contract do
  it "declares the repository interface" do
    contract = described_class.new

    expect { contract.find_by_email("client@example.com") }.to raise_error(NotImplementedError)
    expect { contract.find_by_email_and_role("client@example.com", :client) }.to raise_error(NotImplementedError)
    expect { contract.find_by_role(:client) }.to raise_error(NotImplementedError)
    expect { contract.find_by_user(double("user")) }.to raise_error(NotImplementedError)
    expect { contract.find_by_user_and_role(double("user"), :client) }.to raise_error(NotImplementedError)
  end
end
