require 'active_support/core_ext/enumerable'
require 'rumbly/diagram/base'
require 'graphviz'

module Rumbly
  module Diagram
    class Graphviz < Base

      def run
        
        g = GraphViz.new(@application.name, type: :digraph)
        
        # set graph defaults
        g[:rankdir] = 'TB'
        g[:splines] = false
        g[:nodesep] = 0.6
        
        # set node defaults
        g.node[:shape] = :record
        g.node[:fontsize] = 8
        g.node[:fontname] = 'Arial'
        
        # set edge defaults
        g.edge[:fontsize]   = 6
        g.edge[:fontname]   = 'Arial'
        
        # create sub-graphs for any trees of generalized classes
        application.klasses.group_by { |klass| klass.root }.each do |root, klasses|
          if klasses.size > 1
            g.add_graph("cluster#{root.name}", color: 'gray') do |sub|
              klasses.group_by { |k| k.depth }.each do |depth, subklasses|
                sub.add_graph("#{root.name}(#{depth})", rank: 'same') do |subsub|
                  subklasses.each { |k| add_node_for_klass(subsub, k) }
                end
              end
            end
          else
            add_node_for_klass(g, klasses.first)
          end
        end
        
        # create edges for all relationships
        application.relationships.each do |relationship|
          links = relationship.links
          link = relationship.links.first
          attrs = case
          when link.type == :generalization
            { dir: 'back', arrowtail: 'empty' }
          when link.type == :realization
            { arrowhead: 'empty', style: 'dotted' }
          else
            {
              arrowhead: 'none',
              arrowtail: 'none',
              headlabel: links.first.label,
              taillabel: (links.size > 1 ? links.last.label : "")
            }
          end
          g.add_edges(link.source.name, link.target.name, attrs)
        end
        
        # write it
        d = Rumbly::options.diagram
        g.output(d.format => "#{d.file}.#{d.format}")
        
      end
      
      private
      
      def add_node_for_klass (graph, klass)
        attributes = filtered_attributes(klass).map { |a| a.label }.join('\n')
        graph.add_nodes(klass.name, label: "{#{klass}|#{attributes}}")
      end
      
    end
  end
end
