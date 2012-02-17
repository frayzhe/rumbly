require 'rumbly/base'
require 'rumbly/model/abstract'

module Rumbly
  module Model

    # This is an abstract class that represents a single operation from one class within
    # an MVC application. Object mapper-specific implementations should subclass this
    # class and implement the following methods: +name+, +parameters+, and +type+.
    class Operation

      # Attributes and default values of a Operation
      ATTRIBUTES = { name: '', parameters: [], type: 'void' }
      
      # Include some useful common methods
      include ::Rumbly::Base

      # For each attribute, create stub accessor methods that raise an exception
      extend Abstract
      stub_required_methods(Operation, ATTRIBUTES)
      
      # Uses the +name+ of this +Operation+ when converting it to a +String+.
      def to_s
        name
      end

      # Compares +Operation+ objects using the +name+ attribute.
      def <=> (other)
        name <=> other.name
      end

    end
  end
end
