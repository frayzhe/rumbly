require 'active_support/core_ext/enumerable'
require 'rumbly/base'

module Rumbly
  module Model

    # This class manage a single +Links+ or a pair of +Links+ between two +Klasses+,
    # corresponding to one edge on a UML class diagram. Unlike the other model classes,
    # this class is not abstract, since all of it's functionality and handling of +Links+
    # is (so far) independent of the object mapper in use.
    class Relationship
      
      class << self

        # Returns an array of +Relationship+ objects by first grouping all of the given
        # +Links+ by their source and target, then creating instances of this class with
        # a single or a pair of related +Links+.
        def all_from_links (links)
          links.group_by { |link| Set[link.source, link.target] }.map do |_, links|
            new(links.sort)
          end
        end
        
      end
      
      # Include some useful common methods
      include ::Rumbly::Base

      attr_reader :type, :links, :through
      
      # Creates a new +Relationship+ object from the given +links+. The +type+ and
      # +through+ klass for multiple links should always be the same, so we just mirror
      # those from the first link.
      def initialize (links)
        @links = links
        @type = links.first.type
        @through = links.first.through
      end

      def description
        source = links.first.source.name
        target = links.first.target.name
        if type == :generalization
          return "#{type} from #{source} to #{target}"
        else
          desc  = "#{type} between #{source} and #{target}"
          desc += " through #{through.name}" unless through.nil?
          return desc
        end
      end

    end
  end
end
