require 'spec_helper'

class UpdateRestCommand < Imperator::Command::Rest
end
class CreateRestCommand < Imperator::Command::Rest
end
class DeleteRestCommand < Imperator::Command::Rest
end

class Post
end

class Article
end

class Account
end

class User
end

class Foo
end

class Payment
end

describe Imperator::Command::ClassFactory do
  subject { Imperator::Command::ClassFactory }

  describe '.rest_command' do
    context 'update' do
      before :all do
        subject.default_rest_class = Imperator::Command::Rest
        subject.rest_command :update, Article, :parent => UpdateRestCommand, :auto_attributes => true do
          def hello
            "hello"
          end
        end
      end

      context 'UpdateArticleCommand created' do
        let(:command) { UpdateArticleCommand.new }

        specify { UpdateArticleCommand.superclass.should == UpdateRestCommand }
        specify { command.hello.should == "hello" }
      end
    end 

    context 'create' do
      before :all do
        subject.default_rest_class = Imperator::Command::Rest
        subject.rest_command :create, Article, :parent => CreateRestCommand, :auto_attributes => true do
          def hello
            "hello"
          end
        end
      end

      context 'CreateArticleCommand created' do
        let(:command) { CreateArticleCommand.new }

        specify { CreateArticleCommand.superclass.should == CreateRestCommand }
        specify { command.hello.should == "hello" }
      end
    end 

    context 'delete' do
      before :all do
        subject.default_rest_class = Imperator::Command::Rest
        subject.rest_command :delete, Article, :parent => DeleteRestCommand, :auto_attributes => true do
          def hello
            "hello"
          end
        end
      end

      context 'DeleteArticleCommand created' do
        let(:command) { DeleteArticleCommand.new }

        specify { DeleteArticleCommand.superclass.should == DeleteRestCommand }
        specify { command.hello.should == "hello" }
      end
    end 
  end
end

describe Imperator::Command::ClassFactory do

  subject { Imperator::Command::ClassFactory }

  describe '.build_command' do
    before :all do
      subject.build_command :show, Post
    end    

    its(:get_default_parent) { should == Imperator::Command }
    specify { ShowPostCommand.superclass.should == Imperator::Command }
  end

  describe '.rest_command' do
    before :all do
      subject.rest_command :update, Payment
    end

    specify { UpdatePaymentCommand.superclass.should == Imperator::Command::Rest }

    describe ':all' do
      before :all do
        subject.rest_command :all, Foo
      end

      specify { CreateFooCommand.superclass.should == Imperator::Command::Rest }
      specify { UpdateFooCommand.superclass.should == Imperator::Command::Rest }
      specify { DeleteFooCommand.superclass.should == Imperator::Command::Rest }
    end
  end

  describe '.default_rest_class' do
    describe 'default class' do
      its(:default_rest_class) { should == Imperator::Command::Rest }
    end

    describe 'set default_rest_class to UpdateRestCommand' do
      before :all do
        subject.default_rest_class = UpdateRestCommand
      end

      its(:default_rest_class) { should == UpdateRestCommand }     
    end
  end

  describe '.default_options' do
    before do
      subject.default_options = {hi: 'hello' }
    end

    its(:default_options) { should == {hi: 'hello' } }
  end
end

describe 'private methods' do
  describe Imperator::Command::ClassFactory do
    subject { Imperator::Command::ClassFactory }

    describe 'rest command builders' do
      describe '.create_command_for' do
        before do
          subject.reset_rest_class
          subject.send :create_command_for, Post
        end

        specify { CreatePostCommand.superclass.should == Imperator::Command::Rest }
      end      

      describe '.update_command_for' do
        before do
          subject.default_rest_class = UpdateRestCommand
          subject.send :update_command_for, Account
        end

        specify { UpdateAccountCommand.superclass.should == UpdateRestCommand }
      end      

      describe '.delete_command_for' do
        before do
          subject.reset_rest_class
          subject.send :delete_command_for, Account
        end

        specify { DeleteAccountCommand.superclass.should == Imperator::Command::Rest }
      end      

      describe '.rest_commands_for' do
        before :all do
          subject.send :rest_commands_for, User
        end

        specify { CreateUserCommand.superclass.should == Imperator::Command::Rest }
        specify { UpdateUserCommand.superclass.should == Imperator::Command::Rest }
        specify { DeleteUserCommand.superclass.should == Imperator::Command::Rest }
      end      
    end
  end
end

