require 'imperator/command/rest_helper'

class Imperator::Command
  class Rest < Imperator::Command
    include Imperator::Command::RestHelper
  end
end
