require 'active_record'
require 'rumbly/model/klass'
require 'rumbly/model/active_record/attribute'

module Rumbly
  module Model
    module ActiveRecord

      # This class is an +ActiveRecord+-specific implementation of the abstract
      # +Rumbly::Model::Klass+ class used to represent model classes within the currently
      # loaded environment. All model class, both persistent and abstract, are modeled
      # as +Klass+ objects. Also, "virtual" classes (more like interfaces) that are named
      # as part of any polymorphic associations are also modeled as +Klass+es. These
      # objects have a name but no underlying +ActiveRecord+ model class.
      class Klass < Rumbly::Model::Klass
        
        class << self

          # Returns an array of +Klass+ objects representing +ActiveRecord+ model classes
          # (be they persistent or abstract) in the currently loaded environment.
          def all_from_base_descendents (app)
            ::ActiveRecord::Base.descendants.select do
              |cls| class_valid?(cls) 
            end.map { |cls| new(app, cls) }
          end
        
          # Returns an array of +Klass+ objects representing "virtual" classes that are
          # named as part of any polymorphic associations. These virtual classes are more
          # like interfaces, but we model them as +Klasses+ for the purposes of showing
          # them in a UML class diagram.
          def all_from_polymorphic_associations (app)
            Relationship.associations_matching(app, :belongs_to, :polymorphic).map do |a|
              new(app, nil, a.name)
            end
          end

          private

          # A class is valid if it is abstract or concrete with a corresponding table.
          def class_valid? (cls)
            cls.abstract_class? || cls.table_exists?
          end
        
        end
        
        # Initializes a new +Klass+ from the given +ActiveModel+ model class. Keeps
        # a back pointer to the top-level +Application+ object. For "virtual" classes
        # (see above), the +cls+ will be nil and the +name+ will be explicitly given.
        def initialize (app, cls, name=nil)
          @app = app
          @cls = cls
          @name = name
        end
        
        # Returns the +ActiveRecord+ model class associated with this +Klass+. Should
        # only be used by other +Rumbly::Model::ActiveRecord+ classes (but no way in
        # Ruby to enforce that). May be nil if this is a "virtual" class (see above).
        def cls
          @cls
        end
        
        # Returns the name of this +Rumbly::Model::ActiveRecord::Klass+.
        def name
          @name ||= @cls.name
        end
        
        # Returns an array of +Rumbly::Model::ActiveRecord::Attributes+, each of which
        # describes an attribute of the +ActiveRecord+ class for this +Klass+. Don't
        # bother to lookup attributes if this +Klass+ represents an abstract model class
        # or is a "virtual" class (interface) stemming from a polymorphic association.
        def attributes
          @attributes ||= if @cls.nil? or self.abstract?
            []
          else
            Attribute.all_from_klass(self)
          end
        end
        
        # Returns nil, since +ActiveRecord+ models don't declare their operations.
        def operations
          nil
        end
        
        # Returns +true+ if this +Rumbly::Model::ActiveRecord::Klass+ is abstract.
        def abstract
          @abstract ||= (@cls.nil? ? false : @cls.abstract_class?)
        end
        
        # Returns +true+ if this +Rumbly::Model::ActiveRecord::Klass+ is a "virtual"
        # class, i.e. one stemming from a polymorphic association (more like an interface).
        def virtual
          @virtual ||= @cls.nil?
        end
        
      end
      
    end
  end
end
