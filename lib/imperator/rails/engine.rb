module Imperator
  class Engine < ::Rails::Engine
    initializer 'Imperator ext setup' do
      config.autoload_paths += Dir[::Rails.root.join('app/commands')]
    end
  end
end