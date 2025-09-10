# frozen_string_literal: true

module Frontend
  module Cache
    # A service that talks to the Meru frontend in order to revalidate
    # its cache for a certain segment of the frontend.
    #
    # @abstract
    class AbstractRevalidator < Support::HookBased::Actor
      extend Dry::Core::ClassAttributes
      extend Dry::Initializer

      option :base_url, Types::String, default: proc { self.class.base_url }

      option :manual, Types::Bool, default: proc { false }

      alias url base_url

      # @!attribute [r] base_url
      # @!scope class
      # @see LocationsConfig
      # @return [String]
      defines :base_url, type: Types::String

      # @!attribute [r] kind
      # @!scope class
      # @return [Frontend::Types::RevalidationKind]
      defines :kind, type: Types::RevalidationKind

      # @!attribute [r] uri_path
      # @!scope class
      # @return [String]
      defines :uri_path, type: Types::String

      base_url LocationsConfig.frontend

      kind "instance"

      uri_path ?/

      standard_execution!

      # Attributes for logging into a {FrontendRevalidation}.
      # @return [{Symbol => Object}]
      attr_reader :attrs

      # @return [Faraday::Connection]
      attr_reader :connection

      # @see #build_params
      # @return [{Symbol => Object}]
      attr_reader :params

      delegate :kind, :uri_path, to: :class

      # @return [Dry::Monads::Success(void)]
      def call
        run_callbacks :execute do
          yield prepare!

          yield make_request!

          yield record_revalidation!
        end

        Success()
      end

      wrapped_hook! def prepare
        @connection = build_connection
        @params = build_params
        @attrs = build_attrs

        super
      end

      wrapped_hook! def make_request
        raw_response = connection.delete(uri_path) do |req|
          req.body = params.to_json if params.present?
        end

        response = Frontend::Cache::RevalidationResponse.new(raw_response.body)
      rescue Faraday::ForbiddenError
        Failure[:invalid_secret]
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Faraday::Error => e
        if e.kind_of?(Faraday::TimeoutError) || (e.kind_of?(Faraday::ConnectionFailed) && e.cause.kind_of?(Net::OpenTimeout))
          Failure[:timeout]
        else
          Failure[:request_failed]
        end
      else
        attrs[:revalidated_at] = yield response

        Success response
      end

      wrapped_hook! def record_revalidation
        ::FrontendRevalidation.insert(attrs)

        Success()
      end

      private

      # @return [Faraday::Connection]
      def build_connection
        retry_options = {
          exceptions: ::Support::Networking::RETRYABLE_EXCEPTIONS,
          max: 3,
          interval: 0.1,
          interval_randomness: 0.9,
          backoff_factor: 2,
        }

        Faraday.new(url:) do |builder|
          builder.request :authorization, "Bearer", FrontendConfig.revalidate_secret
          builder.request :json
          builder.request :retry, retry_options
          builder.response :follow_redirects, limit: 5
          builder.response :raise_error
          builder.adapter :net_http

          builder.response :json, parser_options: { decoder: [Oj, :load] }
        end
      end

      def build_attrs
        {
          kind:,
          manual:,
          params:,
        }
      end

      # @abstract
      # @return [{Symbol => Object}]
      def build_params
        {}
      end

      class << self
        # @!attribute [r] endpoint
        # @!scope class
        # @return [String] The full endpoint URL
        def endpoint
          @endpoint ||= build_endpoint
        end

        # Sets the {#uri_path} and rebuilds the {#endpoint}.
        # @return [String]
        def uri_path!(path)
          uri_path path
        ensure
          @endpoint = build_endpoint
        end

        private

        def build_endpoint
          URI.join(base_url, uri_path).to_s
        end
      end
    end
  end
end
