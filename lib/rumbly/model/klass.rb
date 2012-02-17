require 'rumbly/base'
require 'rumbly/model/abstract'

module Rumbly
  module Model

    # This is an abstract class that represents a single model class within an MVC
    # application. Object mapper-specific implementations should subclass this class and
    # implement the following methods: +name+, +root+, +attributes+, +operations+,
    # +is_abstract+, and +is_virtual+.
    class Klass

      # Attributes and default values of a Klass
      ATTRIBUTES = {
        name: '', root: nil, attributes: [], operations: [],
        is_abstract: false, is_virtual: false
      }
      
      # Include some useful common methods
      include ::Rumbly::Base

      # For each attribute, create stub accessor methods that raise an exception
      extend Abstract
      stub_required_methods(Klass, ATTRIBUTES)
      
      # Simple question mark-style wrapper for the +Klass#is_abstract+ attribute.
      def abstract?
        is_abstract
      end
      
      # Simple question mark-style wrapper for the +Klass#is_virtual+ attribute.
      def virtual?
        is_virtual
      end
      
      # Returns the label for this +Klass+, i.e. the +name+.
      def label
        name
      end
      
      # Uses the name of the +Klass+ when converting it to a +String+.
      def to_s
        name
      end

      # Compares +Klass+ objects using the +name+ attribute.
      def <=> (other)
        name <=> other.name
      end
      
    end    
  end
end
