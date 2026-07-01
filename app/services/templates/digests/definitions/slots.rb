# frozen_string_literal: true

module Templates
  module Digests
    module Definitions
      Slots = StoreModel.one_of do |json|
        template_kind = json.fetch("template_kind")

        template = ::Template.find(template_kind)

        template.slot_definition_mapping_klass
      rescue FrozenRecord::RecordNotFound, KeyError
        # simplecov:disable
        Templates::SlotMappings::AbstractInstanceSlots
        # simplecov:enable
      end
    end
  end
end
