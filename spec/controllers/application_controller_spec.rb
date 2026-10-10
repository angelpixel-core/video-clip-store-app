require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller(ApplicationController) do
    def client_workspace
      render plain: workspace_for(:client).name
    end

    def pm_workspace
      render plain: workspace_for(:pm).name
    end
  end

  before do
    routes.draw do
      get "client_workspace" => "anonymous#client_workspace"
      get "pm_workspace" => "anonymous#pm_workspace"
    end
  end

  it "keeps workspace_for wired to the workspace resolver" do
    client = workspace_account(:client, email: "controller-client@example.com", name: "Controller Client")
    pm = workspace_account(:pm, email: "controller-pm@example.com", name: "Controller PM")
    resolver = instance_double(Identity::Application::Services::WorkspaceResolver)

    allow(resolver).to receive(:workspace_for).with(:client).and_return(client)
    allow(resolver).to receive(:workspace_for).with(:pm).and_return(pm)
    allow(controller).to receive(:workspace_resolver).and_return(resolver)

    get :client_workspace
    expect(response.body).to eq("Controller Client")

    get :pm_workspace
    expect(response.body).to eq("Controller PM")
  end
end
