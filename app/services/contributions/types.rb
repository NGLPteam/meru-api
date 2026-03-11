# frozen_string_literal: true

module Contributions
  module Types
    extend ::Support::Typespace

    Contributable = ModelInstance("Collection") | ModelInstance("Item")

    ContributableKlassName = Coercible::String.enum("Collection", "Item")

    ContributableForeignKey = Coercible::Symbol.enum(:collection_id, :item_id)

    ContributableKey = Coercible::Symbol.enum(:collection, :item)

    ContributablesKey = Coercible::Symbol.enum(:collections, :items)

    Contribution = ModelInstance("CollectionContribution") | ModelInstance("ItemContribution")

    ContributionKlassName = Coercible::String.enum("CollectionContribution", "ItemContribution")

    Contributor = ModelInstance("Contributor")

    Role = ModelInstance("ControlledVocabularyItem")
  end
end
