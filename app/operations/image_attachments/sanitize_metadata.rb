# frozen_string_literal: true

module ImageAttachments
  class SanitizeMetadata
    def call(value)
      ImageAttachments::Types::Metadata[value].deep_stringify_keys.compact
    rescue Dry::Types::CoercionError
      # simplecov:disable
      nil
      # simplecov:enable
    end
  end
end
