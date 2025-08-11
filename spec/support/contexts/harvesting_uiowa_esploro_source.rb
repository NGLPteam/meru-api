# frozen_string_literal: true

RSpec.shared_context "harvesting uiowa esploro source" do
  let_it_be(:uiowa, refind: true) { FactoryBot.create :community, identifier: "uiowa" }

  let_it_be(:uiowa_iihr_monographs, refind: true) do
    FactoryBot.create(:collection, :series, community: uiowa, identifier: "uiowa-iihr-monographs", title: "IIHR Monographs")
  end

  let_it_be(:uiowa_iwp, refind: true) do
    FactoryBot.create(:collection, :series, community: uiowa, identifier: "uiowa-iwp", title: "International Writing Program")
  end

  let_it_be(:uiowa_iwpar, refind: true) do
    FactoryBot.create(:collection, :series, community: uiowa, identifier: "uiowa-iwpar", title: "International Writing Program Annual Report")
  end

  let_it_be(:uiowa_ofm, refind: true) do
    FactoryBot.create(:collection, :series, community: uiowa, identifier: "uiowa-ofm", title: "Open File Maps")
  end

  let_it_be(:uiowa_tech_info_series, refind: true) do
    FactoryBot.create(:collection, :series, community: uiowa, identifier: "uiowa-tech-info-series", title: "Technical Information Series")
  end

  let_it_be(:uiowa_wrir, refind: true) do
    FactoryBot.create(:collection, :series, community: uiowa, identifier: "uiowa-wrir", title: "Water Resources Investigation Report")
  end

  let_it_be(:uiowa_wsb, refind: true) do
    FactoryBot.create(:collection, :series, community: uiowa, identifier: "uiowa-wsb", title: "Water-Supply Bulletin")
  end

  let_it_be(:target_entity, refind: true) { uiowa }

  let_it_be(:harvest_source, refind: true) { FactoryBot.create :harvest_source, :oai, :esploro, :using_metadata_mappings }

  let_it_be(:harvest_attempt, refind: true) { harvest_source.create_attempt!(target_entity:) }

  let_it_be(:harvest_configuration, refind: true) { harvest_attempt.reload_harvest_configuration }

  let_it_be(:metadata_mapping_definitions) do
    [
      { "identifier" => "uiowa-ofm", "field" => "relation", "pattern" => "^ispartof:[[:space:]]+Open file map series.*" },
      { "identifier" => "uiowa-wrir", "field" => "relation", "pattern" => "^ispartof:[[:space:]]+Water Resources Investigation Report.*" },
      { "identifier" => "uiowa-tech-info-series", "field" => "relation", "pattern" => "^ispartof:[[:space:]]+Technical Information Series.*" },
      { "identifier" => "uiowa-tech-info-series", "field" => "relation", "pattern" => "^ispartof:[[:space:]]+Iowa Geological Survey Technical Information Series.*" },
      { "identifier" => "uiowa-wsb", "field" => "relation", "pattern" => "^ispartof:[[:space:]]+Water-supply bulletin.*" },
      { "identifier" => "uiowa-iihr-monographs", "field" => "identifier", "pattern" => "^iihr_monograph_series.*" },
      { "identifier" => "uiowa-iwp", "field" => "title", "pattern" => "^International Writing Program.*" },
      { "identifier" => "uiowa-iwpar", "field" => "title", "pattern" => "^The International Writing Program at the University of Iowa annual report.*" }
    ]
  end

  let_it_be(:metadata_mappings) do
    harvest_source.assign_metadata_mappings!(metadata_mapping_definitions, base_entity: target_entity)
  end
end
