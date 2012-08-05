module Imperator
  module Mongoid
    module AttributeHelper
      include ActiveSupport::Concern

      module ClassMethods
        def attributes_for clazz, options = {}
          use_attributes = clazz.attribute_names - options[:except].map(&:to_s)

          unless options[:only].blank?
            use_attributes = use_attributes & options[:only].map(&:to_s) # intersection
          end

          clazz.fields.each do |field|
            # skip if this field is excluded for use in command
            continue if use_attributes.include? field.name.to_s
            
            attribute field.name, field.type, :default => field.default_val
          end
        end
      end
    end
  end
end