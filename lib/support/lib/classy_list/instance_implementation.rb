# frozen_string_literal: true

module Support
  module ClassyList
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
          def #{list_name} = self.class.#{list_name}
        RUBY

        if config.realize?
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
          def #{realize_method} = #{list_name}.realize(self)
          RUBY
        end
      end
    end
  end
end
