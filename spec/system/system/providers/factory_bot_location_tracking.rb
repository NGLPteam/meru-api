# frozen_string_literal: true

TestingAPI::TestContainer.register_provider(:factory_bot_location_tracking) do
  start do
    FactoryBot.singleton_class.prepend Testing::Factories::FactoryEnhancement
    FactoryBot::SyntaxRunner.prepend Testing::Factories::FactoryEnhancement

    ActiveSupport.on_load :active_record do
      include Testing::Factories::ModelEnhancement
    end
  end
end
