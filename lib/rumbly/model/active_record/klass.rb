require 'active_support/core_ext/string/inflections'
require 'active_record'
require 'rumbly/model/klass'
require 'rumbly/model/active_record/attribute'
require 'rumbly/model/active_record/link'

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
          def all_from_base_descendents (application)
            ::ActiveRecord::Base.descendants.select do
              |cls| class_valid?(cls) 
            end.map { |cls| new(application, cls) }
          end
        
          # Returns an array of +Klass+ objects representing "virtual" classes that are
          # named as part of any polymorphic associations. These virtual classes are more
          # like interfaces, but we model them as +Klasses+ for the purposes of showing
          # them in a UML class diagram.
          def all_from_polymorphic_associations (application)
            Link.associations_matching(application, :belongs_to, :polymorphic).map do |a|
              new(application, nil, a.name.to_s.classify)
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
        def initialize (application, cls, name=nil)
          @application = application
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

        # Returns the +Klass+ representing the ancenstor of this +ActiveRecord+ class
        # which is a direct child of +ActiveRecord::Base+. For a virtual +Klass+, just
        # returns itself.
        def root
          @root ||= if self.is_virtual
            @depth = 0
            self
          else
            s = @cls
            @depth = -1
            until s == ::ActiveRecord::Base
              k, s = s, s.superclass
              @depth += 1
            end
            @application.klass_by_name(k.name)
          end
        end
        
        def depth
          self.root
          @depth
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
        def is_abstract
          @is_abstract ||= (@cls.nil? ? false : @cls.abstract_class?)
        end
        
        # Returns +true+ if this +Rumbly::Model::ActiveRecord::Klass+ is a "virtual"
        # class, i.e. one stemming from a polymorphic association (more like an interface).
        def is_virtual
          @is_virtual ||= @cls.nil?
        end
        
      end
    end
  end
end
