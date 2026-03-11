# frozen_string_literal: true

module Contributors
  module Types
    extend ::Support::Typespace

    ORCID_FORMAT = %r,\Ahttps://orcid.org/(?<identifier>\d{4}(?:-\d{4}){3})\z,

    ORCID = String.constrained(format: ORCID_FORMAT)

    Kind = Coercible::Symbol.enum(:organization, :person)

    # @see Types::ContributorLookupFieldType
    LookupField = Symbol.enum(:email, :name, :orcid)

    # @see Types::SimpleOrderType
    LookupOrder = String.enum("RECENT", "OLDEST").fallback("RECENT").default("RECENT")

    PresentString = Coercible::String.constrained(rails_present: true)

    StrippedPresentString = String.constructor do |value|
      PresentString.try(value).to_monad.fmap(&:strip).value_or(value)
    end

    OrganizationName = StrippedPresentString

    PersonalName = Nominal(Namae::Name).constructor do |value|
      case value
      when PresentString
        string = PresentString[value]

        MeruAPI::Container["utility.parse_name"].(string).value_or(string)
      else
        value
      end
    end.constrained(type: Namae::Name)

    AnyName = PersonalName | OrganizationName
  end
end
