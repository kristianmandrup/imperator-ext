require 'spec_helper'
require 'imperator-ext/shared_ex/attribute_helper_ex'

describe Imperator::Mongoid::Command do
  subject { clazz }
  let(:clazz) { Imperator::Mongoid::Command }

  it_behaves_like 'an attribute helper'
  it_behaves_like 'a mongoid rest command'
end