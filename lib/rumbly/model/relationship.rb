require 'rumbly/model/abstract'

module Rumbly
  module Model

    # This is an abstract class that represents a (one-way) relationship between two
    # classes within an MVC application. Object mapper-specific implementations should
    # subclass this class and implement the following methods: +type+, +source+,
    # +target+, +name+, +multiplicity+, +through+, and +navigable+.
    #
    # According to the UML spec, generalizations don't really have a +name+ or a
    # +multiplicity+, so these attributes should should be +nil+ for this +Relationship+
    # type; +navigable+ should always return true for generalizations, and the subclass
    # should be the +source+, whereas the superclass should be the +target+.
    class Relationship

      # Attributes and default values of a Relationship
      ATTRIBUTES = {
        type: :association, source: nil, target: nil, name: '',
        multiplicity: nil, through: nil, navigable: false
      }

      # For each attribute, create stub accessor methods that raise an exception
      extend Abstract
      stub_required_methods(Relationship, ATTRIBUTES)

      # Valid Relationship types
      RELATIONSHIP_TYPES = [
        :dependency, :association, :aggregation, :composition, :generalization
      ]

      # Simple question mark-style wrapper for the +Relationship#navigable+ attribute.
      def navigable?
        navigable
      end
      
      # Compares two +Relationship+ objects by first seeing if their sources or targets
      # differ. If those are the same, then use the name, then type, then through.
      def <=> (other)
        (source <=> other.source).nonzero? || (target <=> other.target).nonzero? ||
        (name <=> other.name).nonzero? || (type <=> other.type).nonzero? ||
        (through <=> other.through)
      end
      
      # Returns a string that fully describes this +Relationship+, including its type,
      # name, source, target, through class, and multiplicity.
      def label
        label  = "#{type.to_s}"
        label += " '#{name}'"
        label += " from #{source.name}"
        label += " to #{target.name}"
        label += " through #{through.name}" unless through.nil?
        label += " #{multiplicity.inspect}"
      end
      
    end
  end
end
