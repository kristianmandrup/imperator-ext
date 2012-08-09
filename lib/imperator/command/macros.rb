# Global macro methods

def imperator_class_factory
  Imperator::Command::ClassFactory
end

def build_command action, model, options = {}, &block
  imperator_class_factory.build_command action, model, options = {}, &block
end

def build_rest_command action, model, options = {}, &block
  imperator_class_factory.rest_command action, model, options = {}, &block
end
