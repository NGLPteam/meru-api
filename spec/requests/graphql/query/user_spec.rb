# frozen_string_literal: true

RSpec.describe "Query.user", type: :request do
  graphql_query! <<~GRAPHQL
  query getUser($slug: Slug!) {
    user(slug: $slug) {
      ... VOGCommonFields

      accessManagement
      globalAdmin

      canReceiveReviewRequests {
        ... AuthorizationResultFragment
      }

      canRevalidateInstance {
        ... AuthorizationResultFragment
      }
    }
  }

  fragment VOGCommonFields on User {
    id
    slug

    name
    givenName
    familyName
    username
    email

    allowedActions
    anonymous
    emailVerified
    uploadAccess
    uploadToken

    canDestroy {
      ... AuthorizationResultFragment
    }

    canResetPassword {
      ... AuthorizationResultFragment
    }

    canUpdate {
      ... AuthorizationResultFragment
    }

    avatar {
      alt
      originalFilename
      purpose
      storage

      metadata {
        alt
      }

      original {
        alt
        contentType
        originalFilename
        storage
      }

      hero {
        ... ImageSizeFragment
      }

      large {
        ... ImageSizeFragment
      }

      medium {
        ... ImageSizeFragment
      }

      small {
        ... ImageSizeFragment
      }

      thumb {
        ... ImageSizeFragment
      }
    }
  }

  fragment ImageSizeFragment on ImageSize {
    height
    size
    width

    png {
      storage
      url
    }

    webp {
      storage
      url
    }
  }
  GRAPHQL

  let_it_be(:existing_user, refind: true) { FactoryBot.create :user, :with_avatar }

  let(:can_destroy) { false }
  let(:can_reset_password) { false }
  let(:can_receive_review_requests) { false }
  let(:can_update) { false }

  let(:found_user) { nil }

  let(:slug) { found_user&.system_slug || random_slug }

  let!(:graphql_variables) { { slug:, } }

  let(:has_upload_access) { found_user&.has_any_upload_access? || false }

  shared_examples_for "a self-lookup" do
    context "when looking up self" do
      let(:found_user) { current_user }

      include_examples "a found user"
    end
  end

  shared_examples "a found user" do
    let(:expected_shape) do
      gql.query do |q|
        q.prop :user do |u|
          u[:name] = found_user.name
          u[:slug] = slug
          u[:upload_access] = has_upload_access

          u.auth_results(can_destroy:, can_reset_password:, can_receive_review_requests:, can_update:)
        end
      end
    end

    it "finds the right user" do
      expect_request! do |req|
        req.data! expected_shape
      end
    end
  end

  shared_examples_for "a not found user" do
    let(:expected_shape) do
      gql.query do |q|
        q[:user] = be_blank
      end
    end

    it "finds nothing" do
      expect_request! do |req|
        req.data! expected_shape
      end
    end
  end

  as_an_admin_user do
    let(:can_reset_password) { true }
    let(:can_receive_review_requests) { false }
    let(:can_update) { true }

    it_behaves_like "a self-lookup" do
      let(:can_receive_review_requests) { true }
      let(:has_upload_access) { true }
      let(:can_update) { true }
    end

    context "against another user" do
      let(:found_user) { existing_user }

      it_behaves_like "a found user"
    end

    context "with an invalid slug" do
      let(:found_user) { nil }

      it_behaves_like "a not found user"
    end
  end

  as_a_regular_user do
    it_behaves_like "a self-lookup" do
      let(:can_reset_password) { true }
      let(:can_update) { true }
      let(:has_upload_access) { false }
    end

    context "against another user" do
      let(:found_user) { existing_user }

      it_behaves_like "a not found user"
    end

    context "with an invalid slug" do
      let(:found_user) { nil }

      it_behaves_like "a not found user"
    end
  end

  as_an_anonymous_user do
    context "against another user" do
      let(:found_user) { existing_user }

      it_behaves_like "a not found user"
    end

    context "with an invalid slug" do
      let(:found_user) { nil }

      it_behaves_like "a not found user"
    end
  end
end
