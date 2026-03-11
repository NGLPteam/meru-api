# frozen_string_literal: true

module Support
  module Params
    # @api private
    module Types
      extend ::Support::Typespace

      Param = Coercible::String

      ParamList = Array.of(Param)

      ParamMap = Hash.map(Param, Any)
    end
  end
end
