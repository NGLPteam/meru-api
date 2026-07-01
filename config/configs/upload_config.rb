# frozen_string_literal: true

class UploadConfig < ApplicationConfig
  # A pattern that matches a URI that doesn't end in a trailing slash.
  SANS_TRAILING_SLASH = %r{(?<!/)\z}

  attr_config bucket: "meru-api", public: false, spaces: false

  attr_config :cdn_host, :mapped_host

  delegate :endpoint, to: :s3

  coerce_types public: :boolean, spaces: :boolean

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

  # @return [:cdn, :mapped, :fallback]
  attr_reader :host_mode

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
    @url_options = derive_url_options
  end

  # @return [Aws::S3::Bucket]
  def build_client
    name = bucket

    client = s3.build_s3_client

    Aws::S3::Bucket.new(name:, client:)
  end

  # @return [UploadConfig::Signer, nil]
  def build_signer
    Signer.new(self) unless host_mode == :fallback
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

  # @api private
  class Signer
    # @param [UploadConfig] config
    def initialize(config)
      @config = config
      @bucket = config.bucket
      @host = config.host
      @client = config.s3.build_client_for(host, force_path_style: false)
      @presigner = Aws::S3::Presigner.new(client:)
    end

    # @return [String]
    attr_reader :bucket

    # @return [String]
    attr_reader :host

    # @return [Aws::S3::Client]
    attr_reader :client

    # @return [Aws::S3::Presigner]
    attr_reader :presigner

    # @param [String] key
    # @param [Hash] options
    # @return [String]
    def call(key, **options)
      presigner.presigned_url(:get_object, **options, bucket:, key:)
    end
  end
end
