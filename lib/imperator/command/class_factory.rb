require 'imperator/command/rest_helper'
require 'imperator/command/rest'

class Imperator::Command
  # http://johnragan.wordpress.com/2010/02/18/ruby-metaprogramming-dynamically-defining-classes-and-methods/
  class ClassFactory
    class << self
      def use &block
        yield self
      end

      def default_parent clazz
        @default_parent ||= clazz
      end

      def get_default_parent
        @default_parent ||= ::Imperator::Command
      end

      # Usage:
      # Imperator::Command::ClassFactory.create :update, Post, parent: Imperator::Mongoid::Command do
      #   ..
      # end
      def build_command action, model, options = {}, &block
        clazz_name = "#{action.to_s.camelize}#{model.to_s.camelize}Command"
        parent = options[:parent] || get_default_parent
        clazz = parent ? Class.new(parent) : Class.new
        Object.const_set clazz_name, clazz
        clazz = self.const_get(clazz_name)
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
        options[:parent] ||= get_default_rest_class(model)
        rest_commands_for(model, options, &block) and return if action.to_sym == :all
        if rest_actions.include? action.to_sym        
          action_name = "#{action}_command_for"
          send action_name, model, options, &block
        else
          raise ArgumentError, "Not a supported REST action. Must be one of #{rest_actions}, was #{action}"
        end
      end

      attr_writer :default_rest_class

      def get_default_rest_class model
        model.ancestors.include?(Mongoid::Document) ? default_mongoid_rest_class : default_rest_class
      end

      def default_rest_class
        @default_rest_class ||= Imperator::Command::Rest
      end

      def default_mongoid_rest_class
        @default_mongoid_rest_class ||= Imperator::Mongoid::Command::Rest
      end

      def reset_rest_class
        @default_rest_class = Imperator::Command::Rest
      end

      attr_writer :default_options

      def default_options
        @default_options ||= {}
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
  end
end
