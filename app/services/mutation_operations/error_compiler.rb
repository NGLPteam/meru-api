# frozen_string_literal: true

module MutationOperations
  class ErrorCompiler
    include Dry::Initializer.define -> do
      option :attribute_names, Support::GlobalTypes::Array.of(Support::GlobalTypes::String)
    end

    include Support::Deps[normalize_path: "dry_mutations.normalize_attribute_path"]

    GLOBAL_PATH = %w[$global].freeze

    # @param [String] message
    # @param [String, #to_s, nil] code
    # @param [<String, #to_s>, nil] path
    # @return [MutationOperations::UserError]
    def call(message, code: nil, path: nil, force_attribute: false)
      path = normalize_path.call path

      attribute_path = path.join(?.)

      error = MutationOperations::UserError.new(
        message:,
        code:,
        path:,
        attribute_path:,
        global: force_attribute ? false : !attribute_path.in?(attribute_names)
      )

      return error
    end

    # @return [MutationOperations::UserError]
    def global(message, code: nil)
      MutationOperations::UserError.new(
        message:,
        code:,
        path: GLOBAL_PATH,
        attribute_path: "$global",
        global: true
      )
    end
  end
end
