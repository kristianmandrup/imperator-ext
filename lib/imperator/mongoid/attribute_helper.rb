module Imperator
  module Mongoid
    module AttributeHelper
      extend ActiveSupport::Concern

      module ClassMethods        
        def attributes_for clazz, options = {}
          use_attributes = clazz.attribute_names

          unless options[:except].blank?
            use_attributes = use_attributes - [options[:except]].flatten.map(&:to_s)
          end
          unless options[:only].blank?
            use_attributes = use_attributes & [options[:only]].flatten.map(&:to_s) # intersection
          end

          clazz.fields.each do |key, field|
            name = key
            type = field.type
            # skip if this field is excluded for use in command
            next unless use_attributes.include? name.to_s
            
            attribute field.name, field.type, :default => field.default_val
          end
        end
      end
    end
  end
end