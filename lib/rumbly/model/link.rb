require 'rumbly/base'
require 'rumbly/model/abstract'

module Rumbly
  module Model

    # This is an abstract class that represents a one-way link between two classes within
    # an MVC application (e.g. an +ActiveRecord+ assocation or what +Mongoid+ calls a
    # relation). Object mapper-specific implementations should subclass this class and
    # implement the following methods: +source+ and +target+ (both instances of +Klass+),
    # +name+, +multiplicity+ (an array of two Numerics), and +through+ (also a +Klass+).
    #
    # According to the UML spec, generalizations (subclass links) don't really have a
    # +name+ or +multiplicity+, so these attributes should should be +nil+ for this
    # type of +Link+. Also, purely by convention, the superclass should be the +source+
    # and the subclass the +target+.
    class Link

      # Attributes and default values of a Link
      ATTRIBUTES = {
        source: nil, target: nil, name: '', type: nil, multiplicity: nil, through: nil
      }

      # Include some useful common methods
      include ::Rumbly::Base

      # For each attribute, create stub accessor methods that raise an exception
      extend Abstract
      stub_required_methods(Link, ATTRIBUTES)
      
      # Valid types of UML links between classes
      UML_LINK_TYPES = [
        :association, :aggregation, :composition, :generalization, :realization
      ]
      
      def label
        label  = ""
        label += multiplicity_label unless multiplicity.nil?
        label += " #{name}" unless name.blank?
        return label
      end
      
      def description
        desc  = "#{type} from #{source} to #{target}"
        desc += " (#{name})" unless name.blank?
        desc += " through #{through}" unless through.nil?
        desc += " #{multiplicity.inspect}" unless multiplicity.nil?
        return desc
      end
      
      private
      
      def multiplicity_label
        min, max = *(multiplicity.map(&:to_s))
        max = '*' if max == 'Infinity'
        min == max ? min : "#{min}..#{max}"
      end

    end
  end
end
