class Imperator::Command
  module MethodFactory
    def command_method command, options = {}, &block
      namespace = (options[:ns] || '').to_s
      namespace.sub! /Controller$/, ''
      define_method "#{command}_command" do
        instance_var = "@#{command}_command"
        unless instance_variable_get(instance_var)
          clazz = [namespace, "#{command.to_s.camelize}Command"].join('::').constantize
          opts = options.merge(initiator: self)
          opts.merge!(instance_eval &block) if block_given?
          clazz_inst = clazz.new(opts)
          instance_variable_set instance_var, clazz_inst
        end
      end
    end

    def command_methods *args, &block
      options = args.extract_options!
      args.flatten.each { |meth| command_method meth, options, &block }
    end    

    extend self
  end
end