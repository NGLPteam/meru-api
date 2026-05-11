# frozen_string_literal: true

Dry::Logic::Predicates.predicate :rails_blank? do |input|
  input.blank?
end

Dry::Logic::Predicates.predicate :rails_present? do |input|
  input.present?
end

Dry::Logic::Predicates.predicate :anonymous_user? do |input|
  type?(Support::Users::AnonymousInterface, input) && input.anonymous?
end

Dry::Logic::Predicates.predicate :email? do |input|
  format? URI::MailTo::EMAIL_REGEXP, input
end

gid_uri = URI::DEFAULT_PARSER.make_regexp("gid")

Dry::Logic::Predicates.predicate :global_id_uri? do |input|
  str?(input) && format?(gid_uri, input)
end

Dry::Logic::Predicates.predicate :global_id? do |input|
  return false if rails_blank?(input) || !(global_id_uri?(input) || type?(::GlobalID, input))

  gid = GlobalID.parse input

  return false if gid.blank?

  begin
    gid.model_class.present?
  rescue NameError
    false
  end
end

http_pattern = URI::DEFAULT_PARSER.make_regexp(/https?/)

Dry::Logic::Predicates.predicate :http_uri? do |input|
  str?(input) && format?(http_pattern, input)
end

https_pattern = URI::DEFAULT_PARSER.make_regexp("https")

Dry::Logic::Predicates.predicate :https_uri? do |input|
  str?(input) && format?(https_pattern, input)
end

Dry::Logic::Predicates.predicate :inherits? do |parent, input|
  type?(Class, input) && input < parent
end

Dry::Logic::Predicates.predicate :model? do |input|
  type?(ActiveRecord::Base, input)
end

Dry::Logic::Predicates.predicate :model_list? do |input|
  array?(input) && input.all? { |elm| model? elm }
end

Dry::Logic::Predicates.predicate :model_class? do |input|
  inherits?(ActiveRecord::Base, input)
end

Dry::Logic::Predicates.predicate :model_class_list? do |input|
  array?(input) && input.all? { |elm| model_class?(input) }
end

Dry::Logic::Predicates.predicate :has_model_name? do |input|
  attr?(:model_name, input) && !none?(input.model_name) && type?(ActiveModel::Name, input.model_name)
end

Dry::Logic::Predicates.predicate :relation? do |input|
  type?(ActiveRecord::Relation, input)
end

Dry::Logic::Predicates.predicate :relation_for? do |model_klass, input|
  relation?(input) && (
    (model_class?(model_klass) && input.model <= model_klass) ||
      (model_klass.kind_of?(Dry::Types::Type) && model_klass.valid?(input.model))
  )
end

Dry::Logic::Predicates.predicate :specific_model? do |model_name, input|
  has_model_name?(input) && input.model_name == model_name
end

Dry::Logic::Predicates.predicate :dry_type? do |input|
  type?(Dry::Types::Type, input)
end

Dry::Logic::Predicates.predicate :gql_typing? do |input|
  dry_type?(input) && input.has_gql_typing?
end

Dry::Logic::Predicates.predicate :opaque_id? do |input|
  return false unless str?(input) && Support::System[:node_verifier].valid_message?(input)

  Support::System["relay_node.decode"].call(input).success?
end

Dry::Logic::Predicates.predicate :iso_639_3? do |input|
  str?(input) && input.in?(Support::Vendor::ISO_639_3_CODES)
end
