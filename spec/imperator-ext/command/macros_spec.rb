require 'spec_helper'
require 'imperator/command/macros'

class Message
end


describe 'Imperator command macros' do  
  describe '.imperator_class_factory' do
    specify { imperator_class_factory.should == Imperator::Command::ClassFactory }
  end

  describe '.build_command' do
    before do
      build_command :update, Message 
    end

    specify do
      UpdateMessageCommand.superclass.should == Imperator::Command
    end
  end

  describe '.build_rest_command' do
    before do
      build_rest_command :delete, Message
    end

    specify do
      DeleteMessageCommand.superclass.should == Imperator::Command::Rest
    end
  end
end