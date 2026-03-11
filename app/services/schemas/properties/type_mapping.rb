# frozen_string_literal: true

module Schemas
  module Properties
    class TypeMapping
      include ::Support::Typing
      include Dry::Core::Equalizer.new(:paths)

      include Dry::Initializer[undefined: false].define -> do
        param :map, Schemas::Properties::Types::TypeMap, default: proc { {} }

        option :paths, Schemas::Properties::Types::FullPathList, default: proc { map.keys.map { |x| x.sub(/\.\$type\z/, "") } }

        option :set, Schemas::Properties::Types::TypeSet, default: proc { map.values.sort.uniq }
      end

      # @param [<#to_s>] types
      def has_any_types?(*types)
        types.flatten.any? { |type| has_type? type }
      end

      # @note We process contributors in a special way in {Types::SchemaInstanceContextType},
      #   specifically when deciding whether to calculate whether or not to include all
      #   contributors as select options until we refactor that in the frontend.
      def has_contributors?
        has_any_types? "contributor", "contributors"
      end

      # @param [#to_s] type
      def has_type?(type)
        type.to_s.in? set
      end
    end
  end
end
