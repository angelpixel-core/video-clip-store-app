require "rails_helper"

RSpec.describe Ordering::Domain::Repositories::Order::Contract do
  it "declares the repository interface" do
    contract = described_class.new

    expect { contract.find_by_id(1) }.to raise_error(NotImplementedError)
    expect { contract.find_by_uid("ord_1_01H") }.to raise_error(NotImplementedError)
    expect { contract.save(Ordering::Domain::Aggregates::Order.new) }.to raise_error(NotImplementedError)
    expect { contract.delete(Ordering::Domain::Aggregates::Order.new) }.to raise_error(NotImplementedError)
  end
end
