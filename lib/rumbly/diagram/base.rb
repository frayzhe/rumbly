require 'active_support/core_ext/string/inflections'

module Rumbly
  module Diagram
    
    # This is an abstract class that defines the API for creating UML class diagrams.
    # Implementations for specific formats (e.g. Yumly, Graphviz, text, etc.) should
    # subclass this class and implement the +run+ method.
    class Base
      
      # The valid types of attributes that can be shown
      ATTRIBUTE_TYPES = [ :content, :primary_key, :type, :foreign_key, :timestamp ]
      
      class << self
        
        # Creates a specific subclass of this base diagram class based on the diagram
        # type specific in the global options, then calls its +#build+ method to create
        # and save the UML class diagram.
        def create (application)
          setup_diagram_options
          diagram_type = Rumbly::options.diagram.type
          require "rumbly/diagram/#{diagram_type}"
          Rumbly::Diagram.const_get(diagram_type.to_s.classify).new(application).run
        end
        
        private
        
        def setup_diagram_options
          options = Rumbly::options.diagram.attribute
          case Array(options.types).map(&:to_sym)
          when [:all]
            options.types = Array(ATTRIBUTE_TYPES)
          when [:none]
            options.types = []
          end
        end
        
      end
      
      private
      
      attr_reader :application
      
      def initialize (application)
        @application = application
      end
      
      def filtered_attributes (klass)
        attributes = []
        types = Array(Rumbly::options.diagram.attribute.types)
        ATTRIBUTE_TYPES.each do |type|
          if types.include?(type)
            attrs = klass.attributes.select { |a| a.send("#{type}?".to_sym) }
            attributes.concat(attrs)
          end
        end
        attributes
      end
      
    end
  end
end
