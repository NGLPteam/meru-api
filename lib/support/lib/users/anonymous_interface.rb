# frozen_string_literal: true

module Support
  module Users
    # Standard interface for an anonymous user.
    module AnonymousInterface
      # @see {#allowed_actions}
      # @return [<String>]
      ALLOWED_ACTIONS = [].freeze

      # @return [String]
      ID = "ANONYMOUS"

      # @return [ActiveSupport::TimeWithZone]
      NOW = Time.zone.at(0)

      # @note For anonymous users, this is always an empty array.
      # @see User#allowed_actions
      # @return [<String>]
      def allowed_actions = ALLOWED_ACTIONS

      # @note Always true for an {AnonymousUser}.
      # @see User#anonymous?
      def anonymous? = true

      alias anonymous anonymous?

      # @see User#authenticated?
      def authenticated? = false

      # @return [nil]
      def authenticated = nil

      def avatar_data = nil

      def avatar_data=(*); end

      # @!attribute [r] created_at
      # @note An anonymous user's created time is always at the time of the request.
      # @return [ActiveSupport::TimeWithZone]
      def created_at = NOW

      def email = nil

      def email_verified = false

      alias email_verified? email_verified

      def family_name = nil

      def given_name = nil

      def graphql_node_type = ::Types::UserType

      # @see User#has_global_admin_access?
      def has_global_admin_access? = false

      # @see User#has_any_upload_access?
      def has_any_upload_access? = false

      # @!attribute [r] id
      # A static ID to allow {AnonymousUser} to be encoded as a GlobalID.
      # @return ["ANONYMOUS"]
      def id = ID

      alias system_slug_id id
      alias system_slug id

      # @!attribute [r] name
      # @see User#name
      # @return [String]
      def name = "Anonymous User"

      # @return [Class]
      def policy_class = ::UserPolicy

      # {AnonymousUser Anonymous users} are non-blank for purposes of object presence.
      #
      # @note Because of Naught's treatment of predicates, this would return `false`
      #   unless subsequently overridden.
      def present? = true

      def respond_to_missing?(method_name, include_private = false)
        AnonymousUser.empty_user.respond_to?(method_name, include_private) || super
      end

      # @see IdentitiesController#show
      # @return [Hash]
      def to_whoami
        {
          anonymous: true
        }
      end

      # @see RelayNode::IdFromObject
      # @return [String, nil]
      def to_encoded_id = Support::System["relay_node.id_from_object"].(self).value!

      # @!attribute [r] updated_at
      # @return [ActiveSupport::TimeWithZone]
      def updated_at = NOW

      module ClassMethods
        # A simulation of `ApplicationRecord.find` to allow {AnonymousUser} to be decoded from a GlobalID.
        #
        # In effect, `AnonymousUser.find any_id` is equivalent to calling `AnonymousUser.new`.
        #
        # @return [AnonymousUser]
        def find(*) = new

        # @api private
        # @return [User]
        def empty_user
          @empty_user ||= ::User.new
        end

        # @return [Class]
        def policy_class = ::UserPolicy
      end

      class << self
        def included(base)
          base.extend Support::Users::AnonymousInterface::ClassMethods
          base.include GlobalID::Identification
          base.include ImageUploader::Attachment.new(:avatar)
        end
      end
    end
  end
end
