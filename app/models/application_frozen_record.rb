# frozen_string_literal: true

# @abstract
class ApplicationFrozenRecord < ::Support::FrozenRecordHelpers::AbstractRecord
  self.abstract_class = true

  type_registry ::Shared::TypeRegistry
end
