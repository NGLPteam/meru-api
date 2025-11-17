# frozen_string_literal: true

Rails.application.routes.draw do
  mount Middleware::TusUploader, at: "/files"

  mount GoodJob::Engine => "/sekrit/good_job"

  resources :downloads, only: %i[show]

  resource :identity, path: "whoami", only: %i[show]

  namespace :introspection do
    resources :layouts, only: %i[show], param: :layout_kind, constraints: Layout.constraints do
      member do
        post :validate
      end
    end

    resources :schema_versions, only: %i[show] do
      resources :root_layouts, as: :layout, path: :layout, only: %i[show], param: :layout_kind, constraints: Layout.constraints
    end
  end

  post "/graphql", to: "graphql#execute"

  scope "/graphql" do
    resources :example_queries, only: %i[index]
  end

  get "/ping", to: "status#ping"

  get "/up" => "rails/health#show", as: :rails_health_check

  root to: "status#root"
end
