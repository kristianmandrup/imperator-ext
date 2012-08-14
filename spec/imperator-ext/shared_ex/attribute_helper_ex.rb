# require 'imperator/command/macros'

class Person
  include Mongoid::Document

  field :name
  field :title
  field :age, type: Integer
end

class UpdatePersonCommand < Imperator::Mongoid::Command
  attributes_for Person
end

class ShowPersonCommand < Imperator::Mongoid::Command
  attributes_for Person, except: :age
end

shared_examples 'a mongoid rest command' do
  context 'update' do
    before :all do
      Imperator::Command::ClassFactory.use do |factory|
        # factory.default_rest_class = Imperator::Mongoid::Command::Rest
        factory.rest_command :create, Person, :auto_attributes => true do
          def hello
            "hello"
          end
        end
      end
    end

    context 'CreatePersonCommand created' do
      let(:command) { CreatePersonCommand.new }

      specify { CreatePersonCommand.superclass.should == Imperator::Mongoid::Command::Rest }
      specify { command.hello.should == "hello" }
    end
  end 
end

shared_examples "an attribute helper" do
  describe 'includes all Mongoid model fields' do
    subject { UpdatePersonCommand.attribute_set }

    its(:names) { should include :name, :title, :age }
  end

  describe 'includes all Mongoid model fields :except age' do
    subject { ShowPersonCommand.attribute_set }

    its(:names) { should include :name, :title }
    its(:names) { should_not include :age }
  end  
end