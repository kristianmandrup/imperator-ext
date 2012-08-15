## Imperator extensions

This gem includes some extensions and integrations for the [imperator](https://github.com/Agowan/imperator) gem.

The current integrations are for:

* [mongoid](https://github.com/mongoid/mongoid)

The gem is designed to simplify designing commands for REST actions and includes some useful macros to facilitate common patterns.

## Mongoid imperator

The Mongoid integration provides the class method `#attributes_for`, 
which can be used to define Command attributes that match the fields of the Mongoid object that the command is designed to operate on.

`attributes_for Post`

Will create Command attributes for all fields defined by the Post class (model).
You can finetune the Command attributes to be created by using the `:except` and `:only options`.

```ruby
class UpdatePostCommand < Imperator::Mongoid::Command
  attributes_for Post, only: [:subject, :body]

  # OR
  attributes_for Post, except: [:state]
end
```

In addition this gem extends the `Imperator::Command` class with the attributes 
`object` and `initiator`. The initiator is meant to be set to the object that initiates the command, typically a Controller instance. The `initiator` can then be used to define delegation methods to the controller etc. 

## Rest Commands

If you inherit from the `Imperator::Command::Rest` class, you gain access to the
REST convenience methods: `update`, `delete` and `create_new` which creates action methods with some default appropriate REST logic for the particular action.
See the code for more info on how to use this for your own needs.

```ruby
class UpdatePostCommand < Imperator::Command::Rest
  attribute :some_object_id
  attribute :some_value

  validates_presence_of :some_object_id

  update do
    puts "updated OK"
  end
end
```

## Mongoid integration

Imperator also comes with a little Mongodi adaptor class, which provides the `attributes_for` method in order to easily redefine Mongoid model fields as Command attributes. Similar adaptors could be created for other ORMs such as Active Record etc.

```ruby
class UpdatePostCommand < Imperator::Mongoid::Command::Rest

  attributes_for Post, except: [:status, :rating]

  validates :name, presence: true

  update do    
    puts "#{object} was updated"
  end

  on_error do
    puts "The Post could not be updated: #{object}"
  end
end
```

## Class Factory

The `Imperator::Command::ClassFactory` can be used to easily create Command wrappers for your model classes.

```ruby
Imperator::Command::ClassFactory.create :publish, Post do
  action do
    find_object.publish!
  end
end
```

It is especially handy for creating Rest Command wrappers. Here we include the `macros` to simplify the code.

```ruby
require 'imperator/command/macros'

imperator_command_factory.use do |factory|
  # put common/shared logic in this REST base class
  factory.default_rest_class = Imperator::Mongoid::Command::Rest

  factory.create_rest :all, Post do
    on_error do
      puts "Oops! There was an error!"
    end
  end

  factory.create_rest :update, Article do
    attributes_for Article, only: [:title, :body] 

    on_error do
      puts "Oops! There was an error!"
    end
  end

  # Same using :auto_attributes option
  factory.create_rest :update, Article, auto_attributes: true, except: [:status] do
    on_error do
      puts "Oops! There was an error!"
    end
  end
end
```

## ClassFactory macros

If you include the macros, the following macros are exposed:

* `#create_command` 
* `#create_rest_command`
* `#imperator_class_factory

Usage example:

```ruby
# ensure all attributes of model are reflected in Command (if adaptor makes it possible)
Imperator::Command::ClassFactory.default_options = {auto_attributes: true}

module PostController
  class Update < Action

    command do
      @command ||= create_rest_command(:update, Post).new object_hash
    end
  end
end
```
## Command Method Factory

By including the `Imperator::Command::MethodFactory` you get access to the `#command_method`and `#command_methods` macros, which let you easily define Imperator Command methods.
These macros are typically used in a Controller like in the example below.
Note: The options passed in will be used to initialize the command

```ruby
class ServicesController
  include Imperator::Command::MethodFactory

  command_method  :pay, service: 'paypal'

  command_methods :sign_in, :sign_out
end
```

Focused Controller usage example:

```ruby
module ServicesController

  class SignIn < Action
    include Imperator::Command::MethodFactory

    def run
      sign_in.perform
    end

    command_method :sign_in
  end
end
```

Often you will want commands namespace scoped however. This is supported via the `:ns` option.

```ruby
module ServicesController

  class SignIn < Action
    include Imperator::Command::MethodFactory

    def run
      sign_in.perform
    end

    command_method :sign_in, ns: self.parent
  end
end
```

Creates a `#sign_in_command` with namespaced scoping:

```ruby
module ServicesController
  class SignIn < Action
    def sign_in_command
      @sign_in_command ||= Services::SignInCommand.new initiator: self
    end
  end
end
```

This is the recommended pattern for linking Focused Controller actions to Imperator commands.

## Rest Commands

The class `Imperator::Command::Rest` can be used as a base class for REST CUD commands (Create, Update, Delete). This class includes the module `Imperator::Command::RestHelper` which includes a number of useful methods for defining typical REST action behavior for an Imperator Command.

Usage example:

```ruby
class UpdatePostCommand < Imperator::Command::Rest
  update_action do
    notify :updated
  end
end
```

Mongoid example:

```ruby
class UpdatePostCommand < Imperator::Mongoid::Command::Rest
  update_action do
    notify :updated
  end
end
```

## Controllers, Actions and Commands

An analysis of the current MVC design pattern in Rails, in particular how the Controllers
are designed and can be improved by employing different Design Patterns to ensure better
decoupling, single responsibility and how to aovid the typical Rails anti-pattern of flat classes, bloated with methods.

## Using Imperator Commands in the current Controller pattern

Demonstrates just how ugly the current Controller convention is!!!

```ruby
class PostController < ApplicationController
  def update    
    update_command.valid? ? update_valid : update_invalid
  end

  protected

  def update_valid
    update_command.perform and redirect_to(root_url)
  end

  def update_invalid
    render edit_post_path(command.object)
  end

  def update_command
    @update_command ||= UpdatePostCommand.new(params[:post])
  end
end
```

## Using Imperator Commands with Focused Controllers

Much nicer encapsulated logic using FocusedController :)

```ruby
module PostController
  class Update < Action
    invalid_path do
      root_url
    end

    # generated by naming convention
    # command { @command ||= UpdatePostCommand.new post_hash }
  end
end
```

Demonstrating some customization of Controller logic

```ruby
module PostController
  class Update < Action
    valid do
      command.perform
      redirect_to root_url
    end

    def invalid
      flash_msg "#{command.object} was invalid!", :error
      super
    end

    command { @command ||= command_class.new object_hash.merge(:status => :complete) }
  end
end
```

And more...

```ruby
module PostController
  class Update < Action
    valid do
      flash_msg "#{command.object} was valid!"
      command.perform
      puts "#{command} was performed!"
      valid_redirect
    end

    valid_redirect_path do
      root_url
    end

    def invalid
      flash_msg "#{command.object} was invalid!", :error
      super
    end

    command do
      @command ||= begin
        c = UpdatePostCommand.new post_hash
        c.complete_it!
      end
    end
  end
end
```

## Contributing to imperator-ext
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Kristian Mandrup. See LICENSE.txt for
further details.

