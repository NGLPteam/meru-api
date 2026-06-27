# frozen_string_literal: true

module Support
  module MessageMaps
    # Class method implementations for a specific message map.
    #
    # @api private
    class KlassImplementation < Implementation
      module_infix :klass

      # @return [Support::MessageMaps::InstanceImplementation]
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

            other.instance_variable_set(#{ivar.inspect}, #{map_name}.dup)
          end

          def #{map_name}
            #{ivar} ||= Support::MessageMaps::Map.new
          end

          def #{single_dsl_method}(key, target = nil, &block)
            message =
              if block_given? ^ target.present?
                block || target
              elsif block_given? && target.present?
                raise ArgumentError, "Must provide either a block or a target, but not both"
              else
                key.to_sym
              end

            mapping = { key.to_sym => message }

            #{plural_dsl_method}(**mapping)
          end

          def #{plural_dsl_method}(*method_names, **additional_mapping)
            #{ivar} = #{map_name}.merge(*method_names, **additional_mapping)
          end
        RUBY
      end
    end
  end
end
