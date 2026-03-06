# frozen_string_literal: true

module Filtering
  module Scopes
    # The filtering scope implementation for {Submission}.
    class Submissions < ::Filtering::FilterScope[::Submission]
      simple_scope_filter! :parent_entity, :any_entities do |arg|
        arg.description <<~TEXT
        Filter submissions to only those with the given parent entity(ies).
        TEXT
      end

      simple_scope_filter! :schema_version, :schema_versions do |arg|
        arg.description <<~TEXT
        Filter submissions to only those with the given schema version(s).
        TEXT
      end

      simple_state_filter! :submission_states

      simple_scope_filter! :submission_target, :submission_targets do |arg|
        arg.description <<~TEXT
        Filter submissions to only those with the given submission target(s).
        TEXT
      end

      simple_scope_filter! :user, :users do |arg|
        arg.description <<~TEXT
        Filter submissions to only those created by the given user(s).
        TEXT
      end

      timestamps!
    end
  end
end
