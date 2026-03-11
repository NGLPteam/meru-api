# frozen_string_literal: true

module Links
  # Types related to an {EntityLink}.
  module Types
    extend ::Support::Typespace

    SOURCE_TYPES = %w[Community Collection Item].freeze
    TARGET_TYPES = SOURCE_TYPES.dup.freeze

    SOURCE_SCOPES = SOURCE_TYPES.map(&:tableize).freeze
    TARGET_SCOPES = TARGET_TYPES.map(&:tableize).freeze

    SCOPE_VALUES = SOURCE_SCOPES.product(TARGET_SCOPES).map do |(src, tgt)|
      "#{src}.linked.#{tgt}"
    end

    Operator = Types::Coercible::String.enum("contains", "references")
    Scope = Types::String.enum(*SCOPE_VALUES)
    SourceType = Types::String.enum(*SOURCE_TYPES)
    TargetType = Types::String.enum(*TARGET_TYPES)
  end
end
