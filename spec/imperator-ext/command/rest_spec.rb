require 'spec_helper'
require 'imperator-ext/shared_ex/rest_helper_ex'

describe Imperator::Command::Rest do
  subject { Imperator::Command::Rest.new }

  it_behaves_like "a rest helper"
end