require 'rumbly/base'
require 'rumbly/model/abstract'

module Rumbly
  module Model

    # This is an abstract class that represents one parameter of an operation from a
    # class within an MVC application. Object mapper-specific implementations should
    # subclass this class and implement the following methods: +name+ and +type+.
    class Parameter

      # Attributes and default values of a Parameter
      ATTRIBUTES = { name: '', type: '' }

      # Include some useful common methods
      include ::Rumbly::Base

      # For each attribute, create stub accessor methods that raise an exception
      extend Abstract
      stub_required_methods(Parameter, ATTRIBUTES)

      # Uses the +name+ of this +Parameter+ when converting it to a +String+.
      def to_s
        name
      end

      # Compares +Parameter+ objects using the +name+ attribute.
      def <=> (other)
        name <=> other.name
      end

    end
  end
end
