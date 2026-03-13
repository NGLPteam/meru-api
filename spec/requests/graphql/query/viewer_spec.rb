# frozen_string_literal: true

RSpec.describe "Query.viewer", type: :request do
  graphql_query! <<~GRAPHQL
  query getViewer {
    viewer {
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

  let(:expected_upload_token) do
    current_user.has_any_upload_access? ? be_present : be_nil
  end

  let(:current_user) { AnonymousUser.new }

  let(:expected_access_management) { ::Types::AccessManagementType.name_for_value(current_user.access_management) }

  let(:can_receive_review_requests) { false }

  let(:expected_shape) do
    gql.query do |q|
      q.prop :viewer do |v|
        v[:access_management] = expected_access_management
        v[:allowed_actions] = current_user.allowed_actions
        v[:anonymous] = current_user.anonymous?
        v[:email] = current_user.email
        v[:email_verified] = current_user.email_verified
        v[:global_admin] = current_user.has_global_admin_access?
        v[:id] = current_user.to_encoded_id
        v[:name] = current_user.name
        v[:slug] = current_user.system_slug
        v[:upload_access] = current_user.has_any_upload_access?
        v[:upload_token] = expected_upload_token

        v.auth_results(can_receive_review_requests:)
      end
    end
  end

  shared_examples_for "a found viewer" do
    it "fetches information about the current user" do
      expect_request! do |req|
        req.effect! execute_safely

        req.data! expected_shape
      end
    end
  end

  as_an_admin_user do
    let(:can_receive_review_requests) { true }

    include_examples "a found viewer"
  end

  as_a_regular_user do
    let(:can_receive_review_requests) { false }

    include_examples "a found viewer"
  end

  as_an_anonymous_user do
    include_examples "a found viewer"
  end
end
