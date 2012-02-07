require 'active_support/core_ext/string/inflections'

module Rumbly
  module Diagram
    
    # This is an abstract class that defines the API for creating UML class diagrams.
    # Implementations for specific formats (e.g. Yumly, Graphviz, text, etc.) should
    # subclass this class and implement the following methods: +setup+,
    # +process_klass+, +middle+, +process_relationship+, and +finish+.
    class Base
      
      class << self
        
        # Creates a specific subclass of this base diagram class based on the diagram
        # type specific in the global options, then calls its +#build+ method to create
        # and save the UML class diagram.
        def create (application)
          diagram_type = Rumbly::options.diagram.type
          require "rumbly/diagram/#{diagram_type}"
          Rumbly::Diagram.const_get(diagram_type.to_s.classify).new(application).build
        end
        
      end
      
      attr_reader :application
      
      def initialize (application)
        @application = application
      end

      # Builds a UML class diagram via the callbacks defined for this base class.
      def build
        setup
        @application.klasses.each do |klass|
          process_klass(klass)
        end
        middle
        @application.relationships.each do |relationship|
          process_relationship(relationship)
        end
        finish
      end
    
    end
    
  end
end
