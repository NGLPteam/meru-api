# frozen_string_literal: true

module CacheWarmers
  # @see CacheWarmers::Run
  class Runner < Support::HookBased::Actor
    include Dry::Core::Constants
    include Dry::Initializer[undefined: false].define -> do
      param :cache_warmer, Types::CacheWarmer
    end

    standard_execution!

    define_model_callbacks :make_request

    delegate :warmable, to: :cache_warmer

    delegate :cache_warming_enabled?, to: :warmable

    # @return [<String>]
    attr_reader :urls

    # @return [Integer]
    attr_reader :warming_count

    # @return [Dry::Monads::Success(Integer)]
    def call
      run_callbacks :execute do
        yield prepare!

        yield make_requests!
      end

      Success warming_count
    end

    wrapped_hook! def prepare
      @cache_warming = nil

      @frontend_url = LocationsConfig.frontend_request

      @http = yield Support::System["networking.http.build_client"].(@frontend_url, allow_insecure: true)

      @urls = build_urls

      @warming_count = 0

      super
    end

    wrapped_hook! def make_requests
      urls.each do |url|
        make_request!(url)
      end

      super
    end

    around_make_request :time_request!

    private

    # @param [String] url
    # @return [void]
    def make_request!(url)
      @cache_warming = cache_warmer.cache_warmings.build(url:)

      run_callbacks :make_request do
        response = @http.get(url)

        @cache_warming.status = response.status
      rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Faraday::Error => e
        @cache_warming.error_klass = e.class.name
        @cache_warming.error_message = e.message
        @cache_warming.status = -1
      end

      @cache_warming.save!

      @warming_count += 1
    ensure
      @cache_warming = nil
    end

    # @return [void]
    def time_request!
      @cache_warming.duration = AbsoluteTime.realtime do
        yield
      end
    end

    # @return [<String>]
    def build_urls
      return EMPTY_ARRAY unless cache_warming_enabled?

      [].tap do |u|
        u.concat(frontend_entity_urls)
      end
    end

    # @return [<String>]
    def frontend_entity_urls
      [].tap do |u|
        url = FrontendConfig.entity_url_for(warmable)

        u << url
      end
    end
  end
end
