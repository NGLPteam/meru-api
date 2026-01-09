# frozen_string_literal: true

require "test_prof/ext/active_record_refind"

using TestProf::Ext::ActiveRecordRefind

module TestHelpers
  module GraphQLRequest
    module ExampleHelpers
      QUERIES_ROOT = Rails.root.join("spec", "data", "queries")

      def expect_request!(**options, &)
        tester = TestingAPI::TestContainer["requests.build"].(&)

        options.merge! tester.inferred_options

        req_expectation = tester.has_expectation? ? tester.expectation : execute_safely

        aggregate_failures do
          expect_the_default_request(**options).to req_expectation

          if tester.has_data? || tester.has_top_level_errors?
            expect_graphql_data tester.data if tester.has_data?

            expect_graphql_response_errors tester.top_level_errors if tester.has_top_level_errors?
          end
        end
      end

      def expect_the_default_request(run_jobs: false, **options)
        expect do
          make_default_request!(**options)

          flush_enqueued_jobs if run_jobs
        end
      end

      def make_default_request!(override_inputs: {}, variables: graphql_variables, token: self.token, **options)
        if override_inputs.any?
          variables => { input:, }

          variables = variables.merge(input: input.merge(override_inputs))
        end

        make_graphql_request! query, token:, variables:, **options
      end

      def make_graphql_request!(query, token: nil, variables: {}, camelize_variables: true, no_top_level_errors: true, operation: operation_name)
        headers = {}

        headers["ACCEPT"] = "application/json"
        headers["AUTHORIZATION"] = "Bearer #{token}" if token.present?
        headers["CONTENT_TYPE"] = "application/json"

        params = {
          query: query&.strip_heredoc&.strip
        }

        params[:operationName] = operation if operation.present?

        params[:variables] = encode_graphql_variables variables, camelize: camelize_variables

        params.compact!

        post("/graphql", params: params.to_json, headers:)

        expect(Array(graphql_response(:errors))).to eq([]) if no_top_level_errors
      end

      # @param [String] name
      def named_query(name)
        basename = "#{name}.graphql"

        QUERIES_ROOT.join(basename).read
      end

      def expect_graphql_data(shape)
        expect(graphql_response(decamelize: true)).to include_json data: shape
      end

      def expect_graphql_response_errors(shape)
        expect(graphql_response(decamelize: true)).to include_json errors: shape
      end

      def graphql_response(*path, decamelize: false)
        parsed_graphql_response(decamelize:).then do |res|
          path.present? ? res.dig(*path) : res
        end
      end

      def parsed_graphql_response(decamelize: false)
        TestingAPI::TestContainer["requests.response_transformer"].call(response.parsed_body, decamelize:)
      end

      def encode_graphql_variables(variables, camelize: true)
        return nil if variables.blank?

        return variables unless camelize

        TestingAPI::TestContainer["requests.variable_transformer"].call(variables)
      end

      def generate_slug_for(uuid)
        Support::System["slugs.encode_id"].call(uuid).value_or(nil)
      end

      def random_slug
        generate_slug_for SecureRandom.uuid
      end

      def graphql_upload_from(*path_parts, **options)
        uploaded_file = Rails.root.join(*path_parts).open "r+" do |f|
          f.binmode

          Shrine.upload(f, :cache)
        end

        to_graphql_upload uploaded_file, **options
      end

      # @param [Shrine::UploadedFile] uploaded_file
      # @return [Hash]
      def to_graphql_upload(uploaded_file, storage: "CACHE", alt: nil)
        uploaded_file.as_json.merge(storage:).deep_transform_keys do |k|
          k.to_s.camelize(:lower)
        end.tap do |h|
          h["metadata"]["alt"] = alt if alt.present?
          h["metadata"].delete "size"
        end
      end

      # @return [Testing::GQLShaper]
      def gql
        @gql ||= TestingAPI::TestContainer["gql"]
      end
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

RSpec.shared_context "with default graphql context" do
  let_it_be(:anonymous_user) { AnonymousUser.new }

  let_it_be(:admin_user, refind: true) do
    FactoryBot.create :user, :admin, given_name: "Admin", family_name: "User"
  end

  let_it_be(:regular_user, refind: true) do
    FactoryBot.create :user, given_name: "Regular", family_name: "User"
  end

  let(:current_user) { anonymous_user }

  let(:token) { current_user.anonymous? ? nil : token_helper.build_token(from_user: current_user) }

  let(:query) { "" }

  let(:graphql_variables) { {} }

  let(:operation_name) { nil }

  before do
    [admin_user, regular_user, current_user].each do |user|
      Testing::Keycloak::GlobalRegistry.users.add_existing! user
    end
  end
end

RSpec.configure do |config|
  config.include TestHelpers::GraphQLRequest::ExampleHelpers, type: :request
  config.extend TestHelpers::GraphQLRequest::SpecHelpers, type: :request
  config.include_context "with default graphql context", type: :request
end
