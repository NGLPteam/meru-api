# frozen_string_literal: true

module Templates
  module Slots
    # @abstract
    class Abstract
      extend Dry::Core::ClassAttributes

      include Support::EnhancedStoreModel

      defines :kind, type: Templates::Types::SlotKind.optional
      defines :scope, type: Templates::Types::SlotScope
      defines :graphql_object_type_name, type: Templates::Types::String.optional
      defines :graphql_object_type, type: Templates::Types::Class.optional

      kind "block"

      scope "abstract"

      graphql_object_type_name nil

      attribute :compiled, :boolean, default: false

      attribute :liquid_errors, Templates::Slots::Error.to_array_type

      # @return [Class, nil]
      def graphql_object_type
        self.class.graphql_object_type
      end

      # @return [Templates::Types::SlotKind]
      def kind
        self.class.kind
      end

      class << self
        # @return [void]
        def kind!(new_kind)
          kind new_kind

          derive_scope!

          derive_graphql_object_type_name!
        end

        # @param [Templates::Types::SlotKind] kind
        # @return [Class]
        def instance_klass_for(kind)
          case kind.to_s
          in "block"
            Templates::Slots::Instances::Block
          in "inline"
            Templates::Slots::Instances::Inline
          end
        end

        def inherited(subclass)
          super

          subclass.derive_scope!
        end

        # @return [void]
        def derive_graphql_object_type_name!
          graphql_object_type_name derive_graphql_object_type_name

          graphql_object_type graphql_object_type_name.try(:constantize)
        end

        def derive_graphql_object_type_name
          return if name.demodulize == "Abstract"

          "types/template_slot_#{kind}_#{scope}_type".classify
        end

        def derive_scope!
          # simplecov:disable
          case name
          in /::Definitions::/
            scope "definition"
          in /::Instances::/
            scope "instance"
          else
            scope "abstract"
          end
          # simplecov:enable
        end
      end
    end
  end
end
