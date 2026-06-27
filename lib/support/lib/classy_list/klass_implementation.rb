# frozen_string_literal: true

module Support
  module ClassyList
    # Class method implementations for a specific message map.
    #
    # @api private
    class KlassImplementation < Implementation
      module_infix :klass

      # @return [Support::ClassyList::InstanceImplementation]
      attr_reader :instance_implementation

      def initialize(...)
        super

        @instance_implementation = InstanceImplementation.new(config)

        define_dsl_methods!
      end

      def extended(base)
        super

        _config = config

        base.define_singleton_method(config_name) { _config }

        base.include @instance_implementation
      end

      private

      # @return [void]
      def define_dsl_methods!
        class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def inherited(other)
            super

            other.instance_variable_set(#{ivar.inspect}, #{list_name}.dup)
          end

          def #{list_name}
            #{ivar} ||= #{config_name}.build_list
          end

          def #{single_dsl_method}(new_item)
            #{list_name}.add!(new_item)
          end

          def #{plural_dsl_method}(*new_items)
            #{list_name}.merge!(new_items)
          end
        RUBY
      end
    end
  end
end
