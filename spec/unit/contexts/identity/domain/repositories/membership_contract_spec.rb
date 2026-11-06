require "rails_helper"

RSpec.describe Identity::Domain::Repositories::Membership::Contract do
  it "declares the repository interface" do
    contract = described_class.new

    user = double("user")
    account = double("account")
    membership = double("membership")

    expect { contract.find_by_user(user) }.to raise_error(NotImplementedError)
    expect { contract.find_by_account(account) }.to raise_error(NotImplementedError)
    expect { contract.find_by_user_and_account(user, account) }.to raise_error(NotImplementedError)
    expect { contract.save(membership) }.to raise_error(NotImplementedError)
  end
end
