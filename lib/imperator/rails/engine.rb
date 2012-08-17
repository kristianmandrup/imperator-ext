module Imperator
  module Rails
    class Engine < ::Rails::Engine
      initializer 'Imperator ext setup' do
        config.auto_load_paths += Dir[Rails.root.join('app/commands')]
      end
    end
  end
end