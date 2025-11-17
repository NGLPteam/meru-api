# frozen_string_literal: true

module Types
  # The GraphQL representation of an {OrderingEntry}.
  class OrderingEntryType < Types::AbstractModel
    description "An entry within an ordering, it can refer to an entity or an entity link"

    field :ordering, "Types::OrderingType", null: false, description: "The parent ordering"

    field :ancestors, ["Types::OrderingEntryType", { null: false }], null: false do
      description <<~TEXT
      When the associated `Ordering` is a `TREE`, and the current entry is a leaf, this array can be used
      to get the associated ancestors within the entry that
      TEXT
    end

    field :entry, "Types::OrderingEntryableType", null: false do
      description <<~TEXT
      The actual element being ordered. At present, this will only be a `Community`, `Collection`, or `Item`,
      but future implementations of orderings may include other content, such as presentation elements.
      TEXT
    end

    field :entry_slug, Types::SlugType, null: true do
      description <<~TEXT
      The delegated `slug` from the associated `entry`.

      This can be null because future entries may not implement it.
      TEXT
    end

    field :entry_title, String, null: true do
      description <<~TEXT
      The delegated `title` from the associated `entry`.

      This can be null because future entries may not implement it.
      TEXT
    end

    field :position, Int, null: true do
      description <<~TEXT
      The 1-based position of this entry.
      TEXT
    end

    field :prev_sibling, "Types::OrderingEntryType", null: true do
      description <<~TEXT
      The previous entry in the current ordering, if one exists. This will be null if this entry is the first.
      TEXT
    end

    field :next_sibling, "Types::OrderingEntryType", null: true do
      description <<~TEXT
      The next entry in the current ordering, if one exists. This will be null if this entry is the last.
      TEXT
    end

    field :relative_depth, Integer, null: false do
      description <<~TEXT
      A calculation of the depth of an entry in the hierarchy, relative to the ordering's owning entity.
      TEXT
    end

    field :tree_depth, Integer, null: true do
      description <<~TEXT
      When an ordering's render mode is set to TREE, its entries will have this set.
      It is a normalized depth based on what other entities were accepted into the ordering.
      TEXT
    end

    load_association! :ancestors

    load_association! :entity, as: :entry

    load_association! :next_sibling

    load_association! :ordering

    load_association! :prev_sibling

    # @!group Delegated Entity Methods

    # @return [String, nil]
    def entry_slug
      entry.then { |entity| entity.id if entity.kind_of?(HierarchicalEntity) }
    end

    # @return [String, nil]
    def entry_title
      entry.then { |entity| entity.title if entity.respond_to?(:title) }
    end

    # @!endgroup
  end
end
