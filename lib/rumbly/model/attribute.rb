require 'rumbly/base'
require 'rumbly/model/abstract'

module Rumbly
  module Model

    # This is an abstract class that represents a single attribute of one class within
    # an MVC application. Object mapper-specific implementations should subclass this
    # class and implement the following methods: +name+, +type+, +visibility+,
    # +multiplicity+, +default+, +properties+, +constraints+, +is_primary-key+,
    # +is_foreign_key+, +is_type+, +is_timestamp+, +is_derived+, and +is_static+.
    class Attribute

      # Attributes and default values of an Attribute
      ATTRIBUTES = {
        name: '', type: '', visibility: '', multiplicity: '', default: '',
        properties: [], constraints: [], is_primary_key: false, is_foreign_key: false,
        is_type: false, is_timestamp: false, is_derived: false, is_static: false
      }

      # Include some useful common methods
      include ::Rumbly::Base

      # For each attribute, create stub accessor methods that raise an exception
      extend Abstract
      stub_required_methods(Attribute, ATTRIBUTES)

      # DLF
      def content?
        !(primary_key? || foreign_key? || type? || timestamp?)
      end
      
      # Simple question mark-style wrapper for the +Attribute#is_primary_key+ attribute.
      def primary_key?
        is_primary_key
      end

      # Simple question mark-style wrapper for the +Attribute#is_foreign_key+ attribute.
      def foreign_key?
        is_foreign_key
      end

      # Simple question mark-style wrapper for the +Attribute#is_type+ attribute.
      def type?
        is_type
      end

      # Simple question mark-style wrapper for the +Attribute#is_timestamp+ attribute.
      def timestamp?
        is_timestamp
      end

      # Simple question mark-style wrapper for the +Attribute#is_derived+ attribute.
      def derived?
        is_derived
      end

      # Simple question mark-style wrapper for the +Attribute#is_static+ attribute.
      def static?
        is_static
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
        return label
      end

      # Uses the +name+ of this +Attribute+ when converting it to a +String+.
      def to_s
        name
      end

      # Compares +Attribute+ objects using the +name+ attribute.
      def <=> (other)
        name <=> other.name
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
