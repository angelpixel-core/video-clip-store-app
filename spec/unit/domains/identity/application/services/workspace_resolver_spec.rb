require "rails_helper"

require Rails.root.join("app/domains/identity/application/services/workspace_resolver")

RSpec.describe Identity::Application::Services::WorkspaceResolver do
  around do |example|
    original_client = ENV["DEFAULT_CLIENT_WORKSPACE_EMAIL"]
    original_pm = ENV["DEFAULT_PM_WORKSPACE_EMAIL"]

    example.run

    restore_env("DEFAULT_CLIENT_WORKSPACE_EMAIL", original_client)
    restore_env("DEFAULT_PM_WORKSPACE_EMAIL", original_pm)
  end

  def restore_env(key, value)
    if value.nil?
      ENV.delete(key)
    else
      ENV[key] = value
    end
  end

  it "resolves a workspace from env vars" do
    ENV["DEFAULT_CLIENT_WORKSPACE_EMAIL"] = "client@example.com"
    ENV["DEFAULT_PM_WORKSPACE_EMAIL"] = "pm@example.com"

    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")

    expect(described_class.new.workspace_for(:client)).to eq(client)
    expect(described_class.new.workspace_for(:pm)).to eq(pm)
  end

  it "resolves each workspace independently" do
    ENV["DEFAULT_CLIENT_WORKSPACE_EMAIL"] = "client@example.com"
    ENV["DEFAULT_PM_WORKSPACE_EMAIL"] = "pm@example.com"

    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    query = class_double(Identity::Application::Queries::ResolveWorkspaceAccount).as_stubbed_const

    expect(query).to receive(:call).with(
      email: "client@example.com",
      role: :client,
      user_repository: anything,
      account_repository: anything
    ).and_return(Core::Result::Success.(data: { account: client }))

    expect(query).to receive(:call).with(
      email: "pm@example.com",
      role: :pm,
      user_repository: anything,
      account_repository: anything
    ).and_return(Core::Result::Success.(data: { account: pm }))

    expect(described_class.new.workspace_for(:client)).to eq(client)
    expect(described_class.new.workspace_for(:pm)).to eq(pm)
  end

  it "fails explicitly when the client env var is missing" do
    ENV.delete("DEFAULT_CLIENT_WORKSPACE_EMAIL")
    ENV["DEFAULT_PM_WORKSPACE_EMAIL"] = "pm@example.com"

    expect { described_class.new.workspace_for(:client) }.to raise_error(KeyError, /DEFAULT_CLIENT_WORKSPACE_EMAIL/)
  end

  it "fails explicitly when the pm env var is missing" do
    ENV["DEFAULT_CLIENT_WORKSPACE_EMAIL"] = "client@example.com"
    ENV.delete("DEFAULT_PM_WORKSPACE_EMAIL")

    expect { described_class.new.workspace_for(:pm) }.to raise_error(KeyError, /DEFAULT_PM_WORKSPACE_EMAIL/)
  end
end
