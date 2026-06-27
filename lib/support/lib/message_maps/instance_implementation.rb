# frozen_string_literal: true

module Support
  module MessageMaps
    # Instance method implementations for a specific message map.
    # @api private
    class InstanceImplementation < Implementation
      module_infix :instance

      def initialize(...)
        super

        define_instance_methods!
      end

      private

      # @return [void]
      def define_instance_methods!
        class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{map_name}
            self.class.#{map_name}
          end

          def #{realize_method}
            #{map_name}.realize(self)
          end
        RUBY
      end
    end
  end
end
