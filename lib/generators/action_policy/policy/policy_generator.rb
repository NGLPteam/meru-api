# frozen_string_literal: true

require "rails/generators"

module ActionPolicy
  module Generators
    # We use a modified version of the action policy generator so that we can control
    # the default parent class for generated policies.
    class PolicyGenerator < ::Rails::Generators::NamedBase
      DEFAULT_PARENT_CLASS = "ApplicationPolicy"

      source_root File.expand_path("templates", __dir__)

      class_option :parent, type: :string, desc: "The parent class for the generated policy", default: DEFAULT_PARENT_CLASS

      def run_install_if_needed
        # :nocov:
        # No-op. We assume ActionPolicy is already installed.
        # :nocov:
      end

      def create_policy
        template "policy.rb", File.join("app/policies", class_path, "#{file_name}_policy.rb")
      end

      hook_for :test_framework

      private

      def parent_class_name
        parent || DEFAULT_PARENT_CLASS
      end

      def parent
        options[:parent]
      end
    end
  end
end
