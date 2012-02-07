require 'rumbly/model/abstract'

module Rumbly
  module Model

    # This is an abstract class that represents a single model class within an MVC
    # application. Object mapper-specific implementations should subclass this class and
    # implement the following methods: +name+, +attributes+, +operations+, +abstract+,
    # and +virtual+.
    class Klass

      # Attributes and default values of a Klass
      ATTRIBUTES = {
        name: '', attributes: [], operations: [], abstract: false, virtual: false
      }
      
      # For each attribute, create stub accessor methods that raise an exception
      extend Abstract
      stub_required_methods(Klass, ATTRIBUTES)
      
      # Simple question mark-style wrapper for the +Klass#abstract+ attribute.
      def abstract?
        abstract
      end
      
      # Simple question mark-style wrapper for the +Klass#virtual+ attribute.
      def virtual?
        virtual
      end

      # Compares +Klass+ objects using the +name+ attribute.
      def <=> (other)
        name <=> other.name
      end
      
    end    
  end
end
