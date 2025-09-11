# frozen_string_literal: true

RSpec.describe Mutations::FrontendCacheRevalidateEntity, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation FrontendCacheRevalidateEntity($input: FrontendCacheRevalidateEntityInput!) {
    frontendCacheRevalidateEntity(input: $input) {
      revalidated

      ... ErrorFragment
    }
  }
  GRAPHQL

  let_it_be(:revalidator_klass) { Frontend::Cache::EntityRevalidator }

  let_it_be(:endpoint) { revalidator_klass.endpoint }
  let_it_be(:kind) { revalidator_klass.kind }

  let_it_be(:community) { FactoryBot.create(:community) }
  let_it_be(:collection) { FactoryBot.create(:collection, community:) }

  let_mutation_input!(:entity_id) { collection.to_encoded_id }

  let(:valid_mutation_shape) do
    gql.mutation(:frontend_cache_revalidate_entity) do |m|
      m[:revalidated] = true
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :frontend_cache_revalidate_entity
  end

  shared_examples_for "an authorized mutation" do
    context "when the request is successful" do
      let(:expected_shape) { valid_mutation_shape }

      before do
        now = Time.current.to_i * 1000

        body = { revalidated: true, now:, }.to_json

        headers = { "Content-Type" => "application/json" }

        stub_request(:delete, endpoint)
          .to_return(status: 200, body:, headers:)
      end

      it "revalidates the entity" do
        expect_request! do |req|
          req.effect! change(FrontendRevalidation.manual.where(kind:), :count).by(1)
          req.effect! have_enqueued_job(Entities::RevalidateFrontendCacheJob).with(community).once

          req.data! expected_shape
        end
      end
    end

    context "when the request times out" do
      let(:expected_shape) do
        gql.mutation(:"frontend_cache_revalidate_#{kind}", no_errors: false) do |m|
          m[:revalidated] = be_blank

          m.global_errors do |ge|
            ge.coded_error :revalidation_timeout
          end
        end
      end

      before do
        stub_request(:delete, endpoint).to_timeout
      end

      it "returns the right error" do
        expect_request! do |req|
          req.effect! keep_the_same(FrontendRevalidation, :count)
          req.effect! have_enqueued_no_jobs(Entities::RevalidateFrontendCacheJob)

          req.data! expected_shape
        end
      end
    end

    context "when the request fails to connect" do
      let(:expected_shape) do
        gql.mutation(:"frontend_cache_revalidate_#{kind}", no_errors: false) do |m|
          m[:revalidated] = be_blank

          m.global_errors do |ge|
            ge.coded_error :revalidation_request_failed
          end
        end
      end

      before do
        stub_request(:delete, endpoint).to_raise(Faraday::ConnectionFailed, "Connection failed")
      end

      it "returns the right error" do
        expect_request! do |req|
          req.effect! keep_the_same(FrontendRevalidation, :count)
          req.effect! have_enqueued_no_jobs(Entities::RevalidateFrontendCacheJob)

          req.data! expected_shape
        end
      end
    end

    context "when the request fails to authenticate" do
      let(:expected_shape) do
        gql.mutation(:"frontend_cache_revalidate_#{kind}", no_errors: false) do |m|
          m[:revalidated] = be_blank

          m.global_errors do |ge|
            ge.coded_error :revalidation_secret_invalid
          end
        end
      end

      before do
        stub_request(:delete, endpoint).to_return(status: 403)
      end

      it "returns the right error" do
        expect_request! do |req|
          req.effect! keep_the_same(FrontendRevalidation, :count)
          req.effect! have_enqueued_no_jobs(Entities::RevalidateFrontendCacheJob)

          req.data! expected_shape
        end
      end
    end

    context "when the request succeeds but the response has the wrong shape" do
      let(:expected_shape) do
        gql.mutation(:"frontend_cache_revalidate_#{kind}", no_errors: false) do |m|
          m[:revalidated] = be_blank

          m.global_errors do |ge|
            ge.coded_error :revalidation_request_failed
          end
        end
      end

      before do
        body = { revalidated: false }.to_json
        headers = { "Content-Type" => "application/json" }

        stub_request(:delete, endpoint).to_return(status: 200, body:, headers:)
      end

      it "returns the right error" do
        expect_request! do |req|
          req.effect! keep_the_same(FrontendRevalidation, :count)
          req.effect! have_enqueued_no_jobs(Entities::RevalidateFrontendCacheJob)

          req.data! expected_shape
        end
      end
    end
  end

  shared_examples_for "an unauthorized mutation" do
    let(:expected_shape) { empty_mutation_shape }

    it "is not authorized" do
      expect_request! do |req|
        req.effect! execute_safely

        req.unauthorized!

        req.data! expected_shape
      end
    end
  end

  as_an_admin_user do
    it_behaves_like "an authorized mutation"
  end

  as_an_anonymous_user do
    it_behaves_like "an unauthorized mutation"
  end
end
