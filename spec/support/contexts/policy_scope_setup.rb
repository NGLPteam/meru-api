# frozen_string_literal: true

require_relative "policy_setup"
require_relative "../matchers/record_matching"

RSpec.shared_context "policy scope setup", with_known_records: true do
  let(:target) { record.class.all }

  let(:authorized_scope) { policy.apply_scope(target, type: :active_record_relation) }

  subject { authorized_scope }

  shared_examples_for "a scope that includes known records" do
    it "includes accessible records" do
      is_expected.to match_known_records(mode: :inclusion)
    end
  end

  shared_examples_for "a scope that excludes known records" do
    it "excludes known records" do
      is_expected.to match_known_records(mode: :exclusion)
    end
  end

  shared_examples_for "an empty scope" do
    it "contains no records" do
      is_expected.to be_blank
    end
  end

  shared_examples_for "a scope that is visible to admin users" do
    context "as an admin" do
      let(:user) { admin }

      include_examples "a scope that includes known records"
    end
  end

  shared_examples_for "a scope that is hidden from admin users" do
    context "as an admin" do
      let(:user) { admin }

      include_examples "a scope that excludes known records"
    end
  end

  shared_examples_for "a scope that is visible to authenticated non-admin users" do
    context "as a regular user" do
      let(:user) { regular_user }

      include_examples "a scope that includes known records"
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      include_examples "a scope that excludes known records"
    end
  end

  shared_examples_for "a scope that is visible to non-admin users" do
    context "as a regular user" do
      let(:user) { regular_user }

      include_examples "a scope that includes known records"
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      include_examples "a scope that includes known records"
    end
  end

  shared_examples_for "a scope that is hidden from non-admin users" do
    context "as a regular user" do
      let(:user) { regular_user }

      include_examples "a scope that excludes known records"
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      include_examples "a scope that excludes known records"
    end
  end

  shared_examples_for "a full-access scope" do
    context "as an admin" do
      let(:user) { admin }

      include_examples "a scope that includes known records"
    end

    context "as a regular user" do
      let(:user) { regular_user }

      include_examples "a scope that includes known records"
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      include_examples "a scope that includes known records"
    end
  end

  shared_examples_for "an admin-only scope" do
    include_examples "a scope that is visible to admin users"
    include_examples "a scope that is hidden from non-admin users"
  end

  shared_examples_for "an admin-and-authenticated-only scope" do
    include_examples "a scope that is visible to admin users"
    include_examples "a scope that is visible to authenticated non-admin users"
  end

  shared_examples_for "a forbidden access scope" do
    include_examples "a scope that is hidden from admin users"
    include_examples "a scope that is hidden from non-admin users"
  end
end

RSpec.shared_context "depositing policy scope setup", policy_scope: true do
  include_context "policy scope setup"
  include_context "depositing policy setup"
end

RSpec.configure do |config|
  config.include RecordMatching::KnownRecordHelpers, policy_scope: true
  config.extend RecordMatching::KnownRecordHelpers::ClassMethods, policy_scope: true
end
