# frozen_string_literal: true

module Templates
  module Digests
    module Instances
      Slots = StoreModel.one_of do |json|
        template_kind = json.fetch("template_kind")

        template = ::Template.find(template_kind)

        template.slot_instance_mapping_klass
      rescue FrozenRecord::RecordNotFound, KeyError
        # :nocov:
        Templates::SlotMappings::AbstractInstanceSlots
        # :nocov:
      end
    end
  end
end
