require "rails_helper"

RSpec.describe "Profile requests" do
  before do
    workspace_account(:client, name: "Default Client")
    workspace_account(:pm, name: "Default PM")
  end

  it "attaches an avatar from a safe https url" do
    svg = StringIO.new(%(<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64"><circle cx="32" cy="32" r="32" fill="#333"/></svg>))
    def svg.content_type
      "image/svg+xml"
    end

    allow(URI).to receive(:open).and_return(svg)

    patch profile_path, params: {
      profile: {
        scope: "client",
        avatar_url: "https://example.com/avatar.svg"
      }
    }

    expect(response).to redirect_to(profile_path)
    expect(find_workspace_account(:client, email: "client@example.com").avatar).to be_attached
  end

  it "rejects a non-https avatar url" do
    patch profile_path, params: {
      profile: {
        scope: "client",
        avatar_url: "http://example.com/avatar.svg"
      }
    }

    expect(response).to redirect_to(profile_path)
    follow_redirect!
    expect(response.body).to include("Avatar URL must be https://")
  end
end
