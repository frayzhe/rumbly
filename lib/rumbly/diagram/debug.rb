require 'rumbly/diagram/base'

module Rumbly
  module Diagram
    
    class Debug < Base
      
      def setup
        puts "Application: #{application.name}"
        puts
        puts "Classes:"
        puts
      end
      
      def process_klass (klass)
        puts "  #{klass.name}"
        klass.attributes.each { |a| puts "    #{a.label}" }
        puts
      end
      
      def middle
        puts "Relationships:"
        puts
      end
      
      def process_relationship (relationship)
        puts "    #{relationship.label}"
      end
      
      def finish
        puts
      end
      
    end
    
  end
end
