# frozen_string_literal: true

module Frontend
  module Cache
    # A response from a revalidation request to the frontend.
    #
    # @api private
    # @see Frontend::Cache::AbstractRevalidator
    class RevalidationResponse < Support::FlexibleStruct
      include Dry::Monads[:result]

      attribute? :revalidated, Types::Params::Bool.default(false)

      attribute? :now, Types::Params::Time.optional

      attribute? :message, Types::String.optional

      # @return [Dry::Monads::Success(Time)]
      # @return [Dry::Monads::Failure(:failed_to_revalidate)]
      def to_monad
        if revalidated
          Success(now || Time.current)
        else
          Failure[:failed_to_revalidate]
        end
      end
    end
  end
end
