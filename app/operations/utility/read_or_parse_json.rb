# frozen_string_literal: true

module Utility
  # Given a flexible input object, return parsed JSON. It expects an array or a hash if passing
  # an already-parsed object, but does not check the actual type of parsed JSON. That remains
  # up to a calling operation.
  class ReadOrParseJSON
    include Dry::Core::Memoizable
    include Dry::Monads[:result, :do]

    LOOKS_LIKE_JSON = /\A\s*\{.*\}\s*\z/

    # @param [Hash, Array, String, Pathname] input
    # @return [Dry::Monads::Success(Hash, Array)]
    # @return [Dry::Monads::Failure(:invalid_json_input, Object)]
    # @return [Dry::Monads::Failure(:invalid_json, Object, JSON::ParserError)]
    # @return [Dry::Monads::Failure(:invalid_path, Object, Dry::Files::IOError)]
    def call(input)
      case input
      when Hash, Array
        Success input
      when LOOKS_LIKE_JSON
        parse_json input
      when Pathname, file_exists
        read_json input
      else
        Failure[:invalid_json_input, input]
      end
    end

    private

    # @return [Proc]
    memoize def file_exists
      ->(input) do
        case input
        when Pathname, String
          File.exist? input.to_s
        else
          false
        end
      end
    end

    # @param [String] input
    # @return [Dry::Monads::Result]
    def parse_json(input)
      parsed = JSON.parse input
    rescue JSON::ParserError => e
      Failure[:invalid_json, input, e]
    else
      Success parsed
    end

    # @param [Pathname, String] path
    # @return [Dry::Monads::Result]
    def read_json(path)
      content = File.read path.to_s
    rescue Errno::ENOENT => e
      Failure[:invalid_path, path, e]
    else
      parse_json content
    end
  end
end
