# frozen_string_literal: true

# A helper that gets rid of weird reload bugs with ClosureTree
#
# They're harmless but annoying to see constantly.
module ClosureTreeHierarchy
  extend ActiveSupport::Concern

  included do
    belongs_to :ancestor, class_name: tree_klass_name

    belongs_to :descendant, class_name: tree_klass_name
  end

  def ==(other)
    self.class == other.class && ancestor_id == other.ancestor_id && descendant_id == other.descendant_id
  end

  alias eql? ==

  def hash
    # rubocop:disable-next Security/CompoundHash
    ancestor_id.hash << 31 ^ descendant_id.hash
  end

  module ClassMethods
    def tree_klass_name
      model_name.to_s.sub(/Hierarchy$/, "")
    end
  end
end
