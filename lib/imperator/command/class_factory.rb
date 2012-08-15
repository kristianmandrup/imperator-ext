require 'imperator/command/rest_helper'
require 'imperator/command/rest'

class Imperator::Command
  # http://johnragan.wordpress.com/2010/02/18/ruby-metaprogramming-dynamically-defining-classes-and-methods/
  class ClassFactory
    include Singleton

    module ClassMethods
      def use &block
        yield self
      end
    end

    module Methods
      attr_writer   :default_class, :initial_rest_classes, :initial_rest_class
      attr_accessor :default_rest_classes

      def initial_rest_classes
        @initial_rest_classes ||= {:mongoid => Imperator::Mongoid::Command::Rest}
      end

      def default_class
        @default_class ||= ::Imperator::Command
      end      

      def default_rest_class model = nil
        return initial_rest_class unless model
        return default_rest_classes[:mongoid] if model.ancestors.include?(Mongoid::Document)        
      end

      def initial_rest_class
        @initial_rest_class ||= Imperator::Command::Rest
      end

      def set_default_rest_class model, type = nil
        unless type.nil?
          @default_rest_classes[type.to_sym] = model
          return
        end
        @initial_rest_class = model        
      end

      def reset_rest!
        @default_rest_classes = initial_rest_classes
        @initial_rest_class = Imperator::Command::Rest
      end

      def reset!
        reset_rest!
        default_class = ::Imperator::Command
      end

      attr_writer :default_options

      def default_options
        @default_options ||= {}
      end

      # Usage:
      # Imperator::Command::ClassFactory.create :update, Post, parent: Imperator::Mongoid::Command do
      #   ..
      # end
      def build_command action, model, options = {}, &block
        clazz_name = "#{action.to_s.camelize}#{model.to_s.camelize}Command"
        parent = options[:parent] || default_class
        clazz = parent ? Class.new(parent) : Class.new
        Object.const_set clazz_name, clazz
        context = self.kind_of?(Class) ? self : self.class
        clazz = context.const_get(clazz_name)
        if options[:auto_attributes]
          clazz.instance_eval do
            if respond_to? :attributes_for
              attributes_for(model, :except => options[:except], :only => options[:only]) 
            end
          end
        end
        if block_given?
          clazz.instance_eval &block      
        end
        clazz
      end

      # Usage:
      # Imperator::Command::ClassFactory.create_rest :all, Post, parent: Imperator::Mongoid::Command do
      #   ..
      # end
      def rest_command action, model, options = {}, &block
        options.reverse_merge! default_options
        options[:parent] ||= default_rest_class(model)
        rest_commands_for(model, options, &block) and return if action.to_sym == :all
        if rest_actions.include? action.to_sym        
          action_name = "#{action}_command_for"
          send action_name, model, options, &block
        else
          raise ArgumentError, "Not a supported REST action. Must be one of #{rest_actions}, was #{action}"
        end
      end


      protected

      def rest_actions
        [:create, :update, :delete]
      end

      def create_command_for model, options = {}, &block
        options[:parent] ||= default_rest_class
        c = build_command :create, model, options do
          create_action
        end
        c.class_eval &block if block_given?
      end

      def update_command_for model, options = {}, &block
        options[:parent] ||= default_rest_class
        c = build_command :update, model, options do          
          update_action          
        end
        c.class_eval &block if block_given?
      end

      def delete_command_for model, options = {}, &block
        options[:parent] ||= default_rest_class
        c = build_command :delete, model, options do          
          delete_action
        end
        c.class_eval &block if block_given?
      end

      def rest_commands_for model, options = {}, &block
        rest_actions.each do |action| 
          send "#{action}_command_for", model, options, &block
        end
      end
    end

    extend Methods
    extend ClassMethods

    include Methods
  end
end
