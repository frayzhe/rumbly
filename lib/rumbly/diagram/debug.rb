require 'rumbly/diagram/base'

module Rumbly
  module Diagram
    class Debug < Base
      
      def run
        puts
        puts
        puts "Application: #{application.name}"
        puts
        puts "Classes: (#{application.klasses.size})"
        puts
        application.klasses.each do |klass|
          puts "  #{klass}"
          filtered_attributes(klass).each do |a|
            puts "    #{a.label}"
          end
          puts
        end
        puts "Relationships: (#{application.relationships.size})"
        puts
        application.relationships.each do |relationship|
          puts "    #{relationship.description}"
          relationship.links.each do |link|
            puts "    - #{link.description}"
          end
        end
        puts
      end
      
    end
  end
end
