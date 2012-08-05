require 'imperator/mongoid/command'

module Imperator::Mongoid
  class Command < Imperator::Command
    class Rest < Command
      include Imperator::Command::RestHelper
    end
  end
end
