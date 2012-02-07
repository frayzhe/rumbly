require 'rumbly'
require 'rumbly/model/application'
require 'rumbly/diagram/base'

def say(message)
  print message unless Rake.application.options.quiet
end

namespace :rumbly do
  
  # Allows options given via Rake environment to override default options. Nested
  # options are accessed using dot notation, e.g. "diagram.type = graphviz".
  task :options do
    ENV.each do |key, value|
      # if option exists in defaults, do some basic conversions and override
      key.downcase.gsub(/_/,'.')
      if Rumbly::options.has_key?(key)
        value = case value
        when "true", "yes" then true
        when "false", "no" then false
        when /,/ then value.split(/\s*,\s*/).map(&:to_sym)
        else value
        end
        Rumbly::options[key] = value
      end
    end
  end

  # Loads the Ruby on Rails environment and model classes.
  task :load_model do
    say "Loading Rails application environment..."
    Rake::Task[:environment].invoke
    say "done.\n"
    say "Loading Rails application classes..."
    Rails.application.eager_load!
    say "done.\n"
  end

  # Generates a UML diagram based on the given options and the loaded Rails model.
  task generate: [:options, :load_model] do
    say "Generating UML diagram for Rails model..."
    app = Rumbly::Model::Application.create
    Rumbly::Diagram::Base.create(app)
    say "done.\n"
  end
  
end

desc "Generate a UML diagram based on your Rails model classes"
task rumbly: 'rumbly:generate'
