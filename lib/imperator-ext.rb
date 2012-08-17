require 'imperator'
require 'imperator/factory'
require 'imperator/command-ext'

require 'imperator/mongoid' if defined?(Mongoid)

require 'imperator/rails/engine' if defined?(::Rails::Engine)

module Commands
  Command = ::Imperator::Command
  MongoidCommand = ::Imperator::Mongoid::Command
end