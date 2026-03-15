# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path("../Gemfile", __dir__)

Warning[:experimental] = false # Hush.

# Annoying workaround for niso-jats gem in production.
module NisoJats; end

module Niso
  module Jats
    Version = "0.1.1"
  end
end

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
