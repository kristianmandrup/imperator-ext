require 'spec_helper'

class Commander
  extend Imperator::Command::MethodFactory
end

class UpdateCommand < Imperator::Command
end

class ShowCommand < Imperator::Command
end

module Landlord
  module Account
    class PayCommand < Imperator::Command
    end
  end
end

module Landlord
  module AccountController
    class Action # imperator action
    end

    class Pay < Action # imperator action
      extend Imperator::Command::MethodFactory

      command_method :pay, object: 'hello', ns: self.parent    
    end    
  end
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
      clazz.command_method :create, object: 'hello'
    end

    its(:update_command) { should be_a(Imperator::Command) }
  end

  describe '.command_methods' do
    describe 'with name args' do
      before do
        clazz.command_methods :update, :show
      end    

      its(:update_command) { should be_a(Imperator::Command) }
      its(:show_command) { should be_a(Imperator::Command) }
    end

    describe 'with names and options' do
      before do
        clazz.command_methods :update, :show, id: 7
      end    

      its(:update_command) { should be_a(Imperator::Command) }
      its(:show_command) { should be_a(Imperator::Command) }
    end
  end

  describe 'with namespace :ns option' do
    before do
      clazz.command_method :pay, object: 'hello', ns: Landlord::Account
    end

    specify { subject.pay_command.class.to_s.should == 'Landlord::Account::PayCommand' }
  end

  describe 'with namespace :ns option as self.parent' do
    subject { Landlord::AccountController::Pay }

    specify { subject.new.pay_command.class.to_s.should == 'Landlord::Account::PayCommand' }
  end
end