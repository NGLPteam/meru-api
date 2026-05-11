# frozen_string_literal: true

RSpec.describe Users::FetchAuthor, type: :operation do
  let_it_be(:user, refind: true) { FactoryBot.create :user }

  let_it_be(:contributor, refind: true) do
    FactoryBot.create :contributor, :person
  end

  context "when the user has an associated author" do
    before do
      user.link_contributor!(contributor)
    end

    it "returns the associated contributor" do
      expect do
        expect_calling_with(user).to succeed.with(contributor)
      end.to keep_the_same(ContributorUserLink, :count)
        .and keep_the_same(Contributor, :count)

      expect(user.primary_contributor).to eq(contributor)
    end
  end

  context "when the user does not have an associated author" do
    it "creates and returns a default author" do
      expect do
        expect_calling_with(user).to succeed.with a_kind_of(::Contributor)
      end.to change(Contributor, :count).by(1)
        .and change(ContributorUserLink, :count).by(1)

      expect(user.primary_contributor).to be_a_kind_of(::Contributor)
    end
  end
end
