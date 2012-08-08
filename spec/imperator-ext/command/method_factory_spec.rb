require 'spec_helper'

class Commander
  extend Imperator::Command::MethodFactory
end

class UpdateCommand < Imperator::Command
end

describe Imperator::Command::MethodFactory do
  subject { clazz.new }

  let(:clazz) { Commander }

  describe '.command_method(command)' do
    before do
      clazz.command_method :update
    end    

    its(:update_command) { should be_a(Imperator::Command) }
  end

  describe '.command_method(command, options)' do
    before do
      clazz.command_method :update, object: 'hello'
    end

    its(:update_command) { should be_a(Imperator::Command) }
  end
end