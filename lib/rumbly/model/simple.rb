module Rumbly
  module Model
    module Simple
    
      classes = %w{ application klass attribute operation parameter relationship }
      classes.each { |c| require "rumbly/model/#{c}" }

      def self.define_class(classname)
        parent = Rumbly::Model.const_get(classname)
        cls = Class.new(parent) do
          parent::ATTRIBUTES.keys.each { |a| attr_accessor a }
          def initialize (attrs={})
            (self.class.superclass)::ATTRIBUTES.each_pair do |a,v|
              instance_variable_set("@#{a}", attrs[a] || v)
            end
          end
        end
        const_set(classname, cls)
      end
      
      classes.each { |c| define_class(c.capitalize) }
      
    end
  end
end
