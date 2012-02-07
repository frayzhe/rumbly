require 'rumbly/model/application'
require 'rumbly/model/active_record/klass'
require 'rumbly/model/active_record/relationship'

module Rumbly
  module Model
    module ActiveRecord
      
      # This class is an +ActiveRecord+-specific implementation of the abstract
      # +Rumbly::Model::Application+ class for representing model classes and
      # relationships within the currently loaded environment.
      class Application < Rumbly::Model::Application
        
        attr_reader :name, :klasses, :relationships
        
        # Returns the name of the current +ActiveRecord+ application.
        def name
          @name ||= Rails.application.class.parent.name
        end
        
        # Returns an array of all +Rumbly::Model::ActiveRecord::Klass+ objects for the
        # current loaded +ActiveRecord+ environment.
        def klasses
          if @klasses.nil?
            # build the klass list in two steps to avoid infinite loop in second call
            @klasses  = Klass.all_from_base_descendents(self)
            @klasses += Klass.all_from_polymorphic_associations(self)
          end
          @klasses
        end

        # Returns an array of +Rumbly::Model::ActiveRecord::Relationship+ objects for
        # the currently loaded +ActiveRecord+ environment.
        def relationships
          @relationships ||= Relationship.all_from_active_record(self)
        end
        
      end
      
    end
  end
end
