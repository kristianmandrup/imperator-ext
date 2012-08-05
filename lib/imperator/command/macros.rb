# Global macro methods

def imperator_class_factory
  Imperator::Command::ClassFactory
end

def create_command action, model, options = {}, &block
  Imperator::Command::ClassFactory.create action, model, options = {}, &block
end

def create_rest_command action, model, options = {}, &block
  Imperator::Command::ClassFactory.create_rest action, model, options = {}, &block
end
