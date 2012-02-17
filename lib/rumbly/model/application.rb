require 'active_support/core_ext/string/inflections'
require 'rumbly/base'
require 'rumbly/model/abstract'

module Rumbly
  module Model
    
    N = Infinity = 1.0/0

    # This is an abstract class that represents the full model of a MVC application,
    # including all classes and relationships. Object mapper-specific implementations
    # should subclass this class and implement the following methods: +name+,
    # +klasses+, and +relationships+.
    class Application
      
      # Attributes and default values of an Application
      ATTRIBUTES = { name: '', klasses: [], relationships: [] }
      
      # Include some useful common methods
      include ::Rumbly::Base

      # For each attribute, create stub accessor methods that raise an exception
      extend Abstract
      stub_required_methods(Application, ATTRIBUTES)
      
      class << self
        
        # Creates a new subclass of +Rumbly::Model::Application+ based on the options
        # set in the main +Rumbly+ module (via rake, command line, etc.). If the
        # model_type+ option is set to +auto+, the current object mapper library is
        # auto-detected.
        def create
          model_type = auto_detect_model_type
          require "rumbly/model/#{model_type}/application"
          Rumbly::Model.const_get(model_type.to_s.classify)::Application.new
        end
        
        private
        
        OBJECT_MAPPERS = [ :active_record, :data_mapper, :mongoid, :mongo_mapper ]
        
        # Auto-detects the current object mapper gem/library if one isn't specified in
        # the global +Rumbly::options+ hash.
        def auto_detect_model_type
          model_type = Rumbly::options.model.type
          if model_type == :auto
            model_type = OBJECT_MAPPERS.detect do |mapper|
              Class.const_defined?(mapper.to_s.classify)
            end
            raise "Couldn't auto-detect object mapper gem/library" if model_type.nil?
          end
          model_type.to_s
        end
        
      end
      
      # Returns a +Klass+ object from our cache indexed by +name+.
      def klass_by_name (name)
        klass_cache[name]
      end
      
      private
      
      def klass_cache
        @klass_cache ||= {}.tap do |cache|
          klasses.each do |klass|
            cache[klass.name] = klass
          end
        end
      end

    end
  end
end
