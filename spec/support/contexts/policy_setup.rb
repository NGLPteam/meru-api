# frozen_string_literal: true

require_relative "authorization_testing"

RSpec.shared_context "policy setup" do
  include_context "authorization testing"

  let(:user) { regular_user }

  let(:context) { { user:, } }

  shared_examples_for "a permission granted to admin users" do
    succeed "as an admin" do
      let(:user) { admin_user }
    end
  end

  shared_examples_for "a permission denied to admin users" do
    failed "as an admin" do
      let(:user) { admin_user }
    end
  end

  shared_examples_for "a permission granted to non-admin users" do
    succeed "as a regular user" do
      let(:user) { regular_user }
    end

    succeed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  shared_examples_for "a permission granted to authenticated users" do
    succeed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  shared_examples_for "a permission denied to non-admin users" do
    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  shared_examples_for "an admin-only permission" do
    include_examples "a permission granted to admin users"
    include_examples "a permission denied to non-admin users"
  end

  shared_examples_for "a forbidden permission" do
    include_examples "a permission denied to admin users"
    include_examples "a permission denied to non-admin users"
  end

  shared_examples_for "a full access permission" do
    include_examples "a permission granted to admin users"
    include_examples "a permission granted to non-admin users"
  end
end

RSpec.shared_context "depositing policy setup" do
  include_context "policy setup"
  include_context "depositing authorization testing"

  shared_examples_for "a permission granted to reviewers" do
    succeed "as a reviewer" do
      let(:user) { reviewer }
    end
  end

  shared_examples_for "a permission denied to reviewers" do
    failed "as a reviewer" do
      let(:user) { reviewer }
    end
  end

  shared_examples_for "a permission granted to submitters" do
    succeed "as the submitter" do
      let(:user) { submitter }
    end
  end

  shared_examples_for "a permission denied to submitters" do
    failed "as the submitter" do
      let(:user) { submitter }
    end
  end

  shared_examples_for "a full-access depositing permission" do
    include_examples "a full access permission"
    include_examples "a permission granted to reviewers"
    include_examples "a permission granted to submitters"
  end

  shared_examples_for "an admin+reviewer+submitter-only permission" do
    include_examples "an admin-only permission"
    include_examples "a permission granted to reviewers"
    include_examples "a permission granted to submitters"
  end

  shared_examples_for "an admin+reviewer-only permission" do
    include_examples "an admin-only permission"

    include_examples "a permission granted to reviewers"
    include_examples "a permission denied to submitters"
  end

  shared_examples_for "an admin+submitter-only permission" do
    include_examples "an admin-only permission"
    include_examples "a permission denied to reviewers"
    include_examples "a permission granted to submitters"
  end

  shared_examples_for "an admin-only depositing permission" do
    include_examples "an admin-only permission"
    include_examples "a permission denied to reviewers"
    include_examples "a permission denied to submitters"
  end

  shared_examples_for "a forbidden depositing permission" do
    include_examples "a forbidden permission"
    include_examples "a permission denied to reviewers"
    include_examples "a permission denied to submitters"
  end
end
