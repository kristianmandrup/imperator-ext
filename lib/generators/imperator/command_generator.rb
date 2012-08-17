module Imperator
  module Generators
    class CommandGenerator < ::Rails::Generators::NamedBase
      desc 'Generates an Imperator Command'

      class_option :orm, type: :string, default: nil, desc: 'Speficic ORM adapter to use'
      
      def main_flow
        empty_directory "app/commands"
        inside "app/commands" do
          template "command.tt", "#{file_path}_command.rb"
        end
      end

      protected

      def orm
        options[:orm]
      end

      def parent_class
        raise ArgumentError, "Invalid ORM: #{orm}, must be one of #{valid_orms}" unless valid_orm? orm
        orm ? "::Imperator::#{orm.camelize}::Command" : "::Imperator::Command"
      end

      def valid_orm? orm
        valid_orms.include? orm.to_s
      end

      def valid_orms
        %w{mongoid}
      end
    end
  end
end