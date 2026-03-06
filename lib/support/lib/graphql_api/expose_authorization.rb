# frozen_string_literal: true

module Support
  module GraphQLAPI
    # A slightly more fluent interface for making sure auth rules are documented.
    module ExposeAuthorization
      def expose_authorization_rule(action, description = nil, with: nil, **field_options)
        field_options[:description] = description

        expose_authorization_rules action, with:, field_options:
      end
    end
  end
end
