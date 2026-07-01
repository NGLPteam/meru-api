# frozen_string_literal: true

require_relative "../misbehaving_ssl_upstream/request_middleware"

module Support
  module Networking
    module HTTP
      # Build an HTTP client using Faraday with a common set of middleware options,
      # including one that catches misbehaving SSL upstreams.
      #
      # @see Support::Networking::HTTP::BuildClient
      class ClientBuilder < ::Support::HookBased::Actor
        DEFAULT_RETRY_BLOCK = ->(retry_count:, exception:, **) do
          warn "(#{retry_count} retries): #{exception.message}"
        end

        include Dry::Initializer[undefined: false].define -> do
          param :base_url, ::Support::Networking::Types::URL

          option :allow_insecure, ::Support::Networking::Types::Bool, default: proc { false }

          option :debug_retries, ::Support::Networking::Types::Bool, default: proc { Rails.env.development? }

          option :json_response, ::Support::Networking::Types::Bool, default: proc { false }

          option :max_retries, ::Support::Networking::Types::RetryCount, default: proc { 10 }

          option :retry_backoff_factor, ::Support::Types::Coercible::Float, default: proc { 2 }

          option :retry_interval, ::Support::Networking::Types::Coercible::Float, default: proc { 0.1 }

          option :retry_interval_randomness, ::Support::Networking::Types::Coercible::Float, default: proc { 0.9 }

          option :retry_block, ::Support::Networking::Types.Interface(:call).optional,
            default: proc { DEFAULT_RETRY_BLOCK if debug_retries }

          option :retryable_exceptions, ::Support::Networking::Types::Array,
            as: :exceptions,
            default: proc { ::Support::Networking::RETRYABLE_EXCEPTIONS }
        end

        standard_execution!

        # @return [Faraday::Connection]
        attr_reader :http

        # Options for the faraday-retry middleware.
        #
        # @return [Hash]
        attr_reader :retry_options

        # @return [URI]
        attr_reader :url

        # @return [Dry::Monads::Success(::Faraday::Connection)]
        def call
          run_callbacks :execute do
            yield build!
          end

          Success http
        end

        wrapped_hook! def build
          @url = URI.parse(base_url)

          @retry_options = build_retry_options

          @http = build_faraday_connection

          super
        end

        private

        def build_faraday_connection
          Faraday.new(url:) do |builder|
            builder.request :retry, retry_options
            builder.request :handle_misbehaving_ssl_upstream
            builder.response :follow_redirects, limit: 5
            builder.adapter :net_http

            if json_response
              builder.response :json, parser_options: { decoder: [Oj, :load] }
            end

            if allow_insecure
              builder.ssl.verify = false
            end
          end
        end

        def build_retry_block
          # simplecov:disable
          return unless debug_retries

          DEFAULT_RETRY_BLOCK
          # simplecov:enable
        end

        def build_retry_options
          {
            exceptions:,
            retry_block:,
            max: max_retries,
            interval: retry_interval,
            interval_randomness: retry_interval_randomness,
            backoff_factor: retry_backoff_factor,
          }
        end
      end
    end
  end
end
