require 'rumbly/model/abstract'

module Rumbly
  module Model

    # This is an abstract class that represents a single attribute of one class within
    # an MVC application. Object mapper-specific implementations should subclass this
    # class and implement the following methods: +name+, +type+, +visibility+,
    # +multiplicity+, +default+, +properties+, +constraints+, +derived+, and +static+.
    class Attribute

      # Attributes and default values of an Attribute
      ATTRIBUTES = {
        name: '', type: '', visibility: '', multiplicity: '', default: '',
        properties: [], constraints: [], derived: false, static: false
      }

      # For each attribute, create stub accessor methods that raise an exception
      extend Abstract
      stub_required_methods(Attribute, ATTRIBUTES)
      
      # Simple question mark-style wrapper for the +Attribute#derived+ attribute.
      def derived?
        derived
      end

      # Simple question mark-style wrapper for the +Attribute#static+ attribute.
      def static?
        static
      end

      # Compares +Attribute+ objects using the +name+ attribute.
      def <=> (other)
        name <=> other.name
      end

      # Returns a string that fully describes this +Attribute+, including its visibility,
      # name, type, multiplicity, default value, and any properties and/or constraints.
      def label
        label  = "#{symbol_for_visibility} "
        label += "/" if derived?
        label += "#{name}"
        label += " : #{type}" unless type.nil?
        label += "[#{multiplicity}]" unless multiplicity.nil?
        label += " = #{default}" unless default.nil?
        label += " {#{props_and_constraints}}" unless props_and_constraints.empty?
        label
      end

      private
      
      VISIBILITY_SYMBOLS = { public: '+', private: '-', protected: '#', package: '~' }
      def symbol_for_visibility
        VISIBILITY_SYMBOLS[visibility] || '-'
      end
      
      def props_and_constraints
        (properties + constraints).join(', ')
      end
      
    end
  end
end
