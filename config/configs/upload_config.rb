# frozen_string_literal: true

class UploadConfig < ApplicationConfig
  # A pattern that matches a URI that doesn't end in a trailing slash.
  SANS_TRAILING_SLASH = %r{(?<!/)\z}

  SKIPPED_PORTS = [80, 443].freeze

  attr_config bucket: "meru-api", public: false, remap_signed_url: false

  attr_config :cdn_host, :mapped_host

  delegate :endpoint, to: :s3

  coerce_types public: :boolean, remap_signed_url: :boolean

  # The host to use for urls when using a custom domain front of the S3/Spaces URL.
  #
  # If {#cdn_host} is set, it will take priority. It assumes that the CDN URL
  # is mapped to the S3/Spaces bucket.
  #
  # In development, we use {#mapped_host} and join it with {#bucket} to form the host
  # in order to provide external access to the minio server running in docker.
  #
  # @return [String, nil]
  attr_reader :host

  # Used to determine several behaviors, including whether to use a custom signer and how to generate URLs.
  #
  # @return [:cdn, :mapped, :fallback]
  attr_reader :host_mode

  # @return [String, nil]
  attr_reader :remapped_scheme

  # @return [String, nil]
  attr_reader :remapped_host

  # @return [Integer, nil]
  attr_reader :remapped_port

  # @return [Hash]
  attr_reader :signer_options

  # @return [S3Config]
  attr_reader :s3

  # Options passed to Shrine's `url_options` plugin, which are used to generate URLs for uploaded files.
  # @return [Hash{Symbol => String}]
  attr_reader :url_options

  alias for_url_options url_options

  def initialize(...)
    super

    @s3 = S3Config.new
    @host_mode = derive_host_mode
    @host = derive_host
    @hostinfo = URI.parse(host) if host.present?
    @signer_options = derive_signer_options
    @url_options = derive_url_options

    if able_to_remap_signed?
      @remapped_scheme = hostinfo.scheme
      @remapped_host = hostinfo.host
      @remapped_port = hostinfo.port.then { |p| p.in?(SKIPPED_PORTS) ? nil : p }
    else
      @remapped_scheme = @remapped_host = @remapped_port = nil
    end
  end

  # @return [URI, nil]
  attr_reader :hostinfo

  # @return [Aws::S3::Bucket]
  def build_client
    name = bucket

    client = s3.build_s3_client

    Aws::S3::Bucket.new(name:, client:)
  end

  # @return [UploadConfig::Signer, nil]
  def build_signer(**options)
    Signer.new(self, **signer_options, **options) unless host_mode == :fallback
  end

  def able_to_remap_signed? = hostinfo.present? && remap_signed_url?

  # Remap a signed URL to use the configured host, if applicable.
  #
  # This only applies when we are running against `spaces`
  # @api private
  # @param [String] url
  # @return [String]
  def maybe_remap_signed(url)
    return url unless able_to_remap_signed?

    uri = URI.parse(url)

    uri.scheme = remapped_scheme
    uri.host = remapped_host
    uri.port = remapped_port

    uri.to_s
  end

  private

  # @return [String, nil]
  def derive_host
    case host_mode
    in :cdn then cdn_host
    in :mapped then URI.join(mapped_host, bucket).to_s
    else nil
    end&.sub(SANS_TRAILING_SLASH, ?/)
  end

  # @return [:cdn, :mapped, :fallback]
  def derive_host_mode
    if valid_url?(cdn_host)
      :cdn
    elsif cdn_host.blank? && valid_url?(mapped_host)
      :mapped
    else
      :fallback
    end
  end

  # @return [String, nil]
  def derive_signer_host
    case host_mode
    in :cdn then endpoint
    in :mapped then mapped_host
    else nil
    end&.sub(SANS_TRAILING_SLASH, ?/)
  end

  def derive_signer_options
    return Dry::Core::Constants::EMPTY_HASH if host_mode == :fallback

    host = derive_signer_host
    force_path_style = host_mode == :mapped

    {
      host:,
      bucket:,
      force_path_style:,
    }.freeze
  end

  # @return [Hash{Symbol => String}]
  def derive_url_options
    base = { host:, public:, }.compact

    cache = { **base }.freeze
    store = { **base }.freeze

    {
      cache:,
      store:,
    }.freeze
  end

  def valid_url?(input) = input.present? && ::Support::GlobalTypes::URL_PATTERN.match?(input)

  # Shrine presigning doesn't work well with CDNs / minio host remapping, so we need to use
  # our own special signer in concert with a patch to `Shrine::Storage::S3#url`.
  #
  # @api private
  class Signer
    # @param [UploadConfig] config
    # @param [String] bucket
    # @param [String] host
    # @param [Boolean] force_path_style
    def initialize(config, bucket:, host:, force_path_style: false)
      @config = config
      @bucket = bucket
      @host = host
      @force_path_style = force_path_style
      @client = build_client
      @presigner = build_presigner
    end

    # @return [String]
    attr_reader :bucket

    alias name bucket

    # @return [Aws::S3::Client]
    attr_reader :client

    # @return [UploadConfig]
    attr_reader :config

    # @return [String]
    attr_reader :endpoint

    # @return [Boolean]
    attr_reader :force_path_style

    alias force_path_style? force_path_style

    # @return [String]
    attr_reader :host

    # @return [Aws::S3::Presigner]
    attr_reader :presigner

    # @param [String] key
    # @param [Hash] options
    # @return [String]
    def call(key, **options)
      config.maybe_remap_signed presign(key, **options)
    end

    def presign(key, **options)
      presigner.presigned_url(:get_object, **options, bucket:, key:)
    end

    private

    # @return [Aws::S3::Client]
    def build_client
      config.s3.build_client_for(host, force_path_style:)
    end

    # @return [Aws::S3::Presigner]
    def build_presigner
      Aws::S3::Presigner.new(client:)
    end
  end
end
