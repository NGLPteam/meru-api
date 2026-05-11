# frozen_string_literal: true

module TestHelpers
  module CurrentUser
    class << self
      def attach_to!(config, **options)
        config.include ExampleHelpers, **options
        config.extend SpecHelpers, **options
        config.include_context "with current user context", **options
      end
    end

    module ExampleHelpers
    end

    module SpecHelpers
      def as_an_admin_user(&)
        context "as an admin" do
          let(:current_user) { admin_user }

          instance_eval(&)
        end
      end

      def as_a_regular_user(&)
        context "as a regular user" do
          let(:current_user) { regular_user }

          instance_eval(&)
        end
      end

      def as_an_anonymous_user(&)
        context "as a anonymous user" do
          let(:current_user) { anonymous_user }

          instance_eval(&)
        end
      end
    end
  end
end

RSpec.shared_context "with current user context" do
  let_it_be(:anonymous_user) { AnonymousUser.new }

  let_it_be(:admin_user, refind: true) do
    FactoryBot.create :user, :admin, given_name: "Admin", family_name: "User"
  end

  let_it_be(:regular_user, refind: true) do
    FactoryBot.create :user, given_name: "Regular", family_name: "User"
  end

  let(:current_user) { anonymous_user }

  before do
    [admin_user, regular_user, current_user].uniq.each do |user|
      Testing::Keycloak::GlobalRegistry.users.add_existing! user
    end
  end
end

RSpec.configure do |config|
  TestHelpers::CurrentUser.attach_to!(config, with_current_user: true)
end
