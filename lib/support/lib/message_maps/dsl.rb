# frozen_string_literal: true

module Support
  module MessageMaps
    # A concern for classes that can define a "message map" using a DSL.
    #
    # A message map allows a class to generate a hash at runtime based on
    # a predefined mapping of keys to method names or procs. This can be
    # useful for defining a consistent export of common service objects.
    module DSL
      extend ActiveSupport::Concern

      module ClassMethods
        # @param [Symbol] name The name of the message map to define.
        # @param [Symbol] dsl_base The base name for the DSL methods to define.
        # @return [void]
        def has_message_map!(name, dsl_base, **options)
          config = Configuration.new(name, **options, dsl_base:)

          extend config.klass_implementation
        end
      end
    end
  end
end
