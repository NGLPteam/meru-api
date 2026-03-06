# frozen_string_literal: true

require "lutaml/model/xml/nokogiri_adapter"
require "shale/adapter/nokogiri"
require "shale/adapter/ox"
require "shale/schema"

Shale.toml_adapter = Tomlib

Shale.xml_adapter = Shale::Adapter::Ox

Lutaml::Model::Config.configure do |config|
  require "lutaml/model/xml/nokogiri_adapter"

  config.xml_adapter = Lutaml::Model::Xml::NokogiriAdapter
end
