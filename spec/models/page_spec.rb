# frozen_string_literal: true

RSpec.describe Page, type: :model do
  include_context "with related entities"

  it_behaves_like "a model that invalidates its parent entity"
end
