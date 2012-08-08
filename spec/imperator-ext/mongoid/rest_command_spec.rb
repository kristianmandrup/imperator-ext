require 'spec_helper'
require 'imperator-ext/shared_ex/rest_helper_ex'

describe Imperator::Mongoid::Command::Rest do
  subject { Imperator::Mongoid::Command::Rest.new }

  it_behaves_like "a rest helper"
end