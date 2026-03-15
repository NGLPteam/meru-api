# frozen_string_literal: true

module Support
  # A client for talking to the local Tus server. It is intended for internal use only,
  # and will likely not be part of the final API in this form.
  #
  # @api private
  class TusClient
    CHUNK_SIZE = 100.megabytes
    TUS_VERSION = "1.0.0"
    NUM_RETRIES = 5

    def initialize(server_url, headers: {})
      @server_uri = URI.parse(server_url)

      # better to open the connection now
      @http = Net::HTTP.new(@server_uri.host, @server_uri.port)

      @http.use_ssl = (@server_uri.scheme == "https")

      @http.start

      @additional_headers = headers

      # we cache this value for further use
      @capabilities = capabilities
    end

    # @param [Pathname, String] file_path
    # @return [String] the tus uri
    def upload(file_path)
      raise "No such file!" unless File.file?(file_path)

      file_name = File.basename(file_path)
      file_size = File.size(file_path)

      File.open(file_path, "rb") do |io|
        upload_by_io(file_name:, file_size:, io:)
      end
    end

    # @return [String] the tus URI
    def upload_by_io(file_name:, file_size:, io:)
      raise 'Cannot upload a stream of unknown size!' unless file_size

      uri = create_remote(file_name, file_size)

      # we use only parameters that are known to the server
      offset, length = upload_parameters(uri)

      chunks = Enumerator.new do |yielder|
        loop do
          chunk = io.read(CHUNK_SIZE)

          break unless chunk

          yielder << chunk
        end
      end

      begin
        offset = chunks.lazy.inject(offset) do |current_offset, chunk|
          upload_chunk(uri, current_offset, chunk)
        end
      rescue StandardError
        raise "Broken upload! Cannot send a chunk!"
      end

      raise "Broken upload!" unless offset == length

      io.close

      return uri
    end

    private

    def capabilities
      raise "Uninitialized connection!" unless @http

      response = @http.options(@server_uri.request_uri)

      response["Tus-Extension"]&.split(?,)
    end

    def create_remote(file_name, file_size)
      raise "New file uploading is not supported!" unless @capabilities.include?("creation")

      request = Net::HTTP::Post.new(@server_uri.request_uri)

      request["Content-Length"] = 0
      request["Upload-Length"] = file_size
      request["Upload-Metadata"] = "filename: #{Base64.strict_encode64(file_name)},is_confidential"

      apply_request_headers! request

      response = nil

      NUM_RETRIES.times do
        response = @http.request(request)
        break
      rescue StandardError
        next
      end

      raise "Cannot create a remote file!" unless response.is_a?(Net::HTTPCreated)

      location_url = response["Location"]

      raise "Malformed server response: missing 'Location' header" unless location_url

      URI.parse(location_url).path
    end

    def upload_parameters(uri)
      request = Net::HTTP::Head.new(uri)

      apply_request_headers! request

      response = @http.request(request)

      [response["Upload-Offset"], response["Upload-Length"]].map(&:to_i)
    end

    def upload_chunk(uri, offset, chunk)
      request = Net::HTTP::Patch.new(uri)
      request["Content-Type"] = "application/offset+octet-stream"
      request["Upload-Offset"] = offset

      apply_request_headers! request

      request.body = chunk

      response = nil

      NUM_RETRIES.times do
        response = @http.request(request)
        break
      rescue StandardError
        next
      end

      raise "Cannot upload a chunk!" unless response.is_a?(Net::HTTPNoContent)

      resulting_offset = response["Upload-Offset"].to_i

      expected_offset = offset + chunk.size

      raise "Chunk upload is broken!" unless resulting_offset == expected_offset

      resulting_offset
    end

    def apply_request_headers!(request)
      request["Tus-Resumable"] = TUS_VERSION

      @additional_headers.each do |name, value|
        request[name] = value
      end
    end

    class << self
      # Build a client for the provided base URL.
      #
      # @example
      #   client = TusClient.build "http://localhost:6222"
      #
      # @param [String] base_url
      # @return [TusClient]
      def build(base_url)
        server_url = URI.join(base_url, "/files").to_s

        new server_url, headers: generate_additional_headers
      end

      # {.build Build} a client for the default local docker environment.
      #
      # @return [TusClient]
      def local
        build "http://localhost:6222"
      end

      private

      # Generate an upload token
      # @return [String]
      def generate_upload_token
        Common::Container["uploads.encode_token"].call.value!
      end

      def generate_additional_headers
        {}.tap do |h|
          h["Upload-Token"] = generate_upload_token
        end
      end
    end
  end
end
