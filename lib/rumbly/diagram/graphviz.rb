require 'rumbly/diagram/base'
require 'active_support/core_ext/module/delegation'
require 'graphviz'

module Rumbly
  module Diagram
    
    class Graphviz < Base

      attr_reader :graph
      
      delegate :add_nodes, :add_edges, :get_node, :output, to: :graph
      
      def setup
        @graph = GraphViz.digraph(@application.name)
        @graph.node[:shape] = :record
        @graph.node[:fontsize] = 10
        @graph.node[:fontname] = 'Arial'
      end
      
      def process_klass (k)
        add_nodes(k.name)
      end
      
      def middle
      end
      
      def process_relationship (r)
        add_edges(find(r.source), find(r.target))
      end
      
      def find (klass)
        get_node(klass.name)
      end
      
      def finish
        d = Rumbly::options.diagram
        output(d.format => "#{d.file}.#{d.format}")
      end
      
    end
    
  end
end
