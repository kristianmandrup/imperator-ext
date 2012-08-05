require 'imperator/command/rest'

class Imperator::Command
  class Rest < Imperator::Command
    include Imperator::Command::RestHelper
  end
end
