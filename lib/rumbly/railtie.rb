module Rumbly
  # If Ruby on Rails is running, adds a set of rake tasks to make it easy to generate UML
  # class diagrams for whatever object mapper you're using in your Rails application.
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'rumbly/tasks.rake'
    end
  end
end
