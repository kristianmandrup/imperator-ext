class Tenant
  include Mongoid::Document

  field :name
  field :title
  field :age, type: Integer
end

class UpdateTenantCommand < Imperator::Command::Rest
  create_action do
  end
end

shared_examples "a rest helper" do
end