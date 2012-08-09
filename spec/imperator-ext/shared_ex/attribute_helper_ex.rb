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


shared_examples "an attribute helper" do
  describe 'includes all Mongoid model fields' do
    subject { UpdatePersonCommand.attribute_set }

    its(:sym_names) { should include(:name, :title, :age) }
  end

  describe 'includes all Mongoid model fields :except age' do
    subject { ShowPersonCommand.attribute_set }

    its(:sym_names) { should include(:name, :title) }
    its(:sym_names) { should_not include(:age) }
  end  
end