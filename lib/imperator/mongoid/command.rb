require 'imperator/mongoid/attribute_helper'

# Usage

# class UpdatePostCommand < Imperator::Mongoid::Command
#   attributes_for Post, except: [:state]
#   attributes :title, :author

#   validates_presence_of :object

#   action do
#     object = SomeObject.find(id)
#     object.authored_by(author)
#   end
# end

module Imperator::Mongoid
  class Command < Imperator::Command
    include Imperator::Mongoid::AttributeHelper
  end
end
