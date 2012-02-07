require 'rumbly/model/relationship'

module Rumbly
  module Model
    module ActiveRecord

      # This class is an +ActiveRecord+-specific implementation of the abstract
      # +Rumbly::Model::Relationship+ class used to represent declared relationships
      # (associations) between model classes in the currently loaded environment.
      class Relationship < Rumbly::Model::Relationship
        
        # Returns an array of +Rumbly::Model::ActiveRecord::Relationship+ objects that
        # represent both associations and generalizations (i.e. subclasses) in the
        # currently loaded +ActiveRecord+ environment.
        def self.all_from_active_record (app)
          all_from_assocations(app) + all_from_generalizations(app)
        end

        # Returns an array of +Rumbly::Model::ActiveRecord::Relationship+ objects that
        # represent declared associations between model classes.
        def self.all_from_assocations (app)
          all_associations(app).map { |a| new(app, a) }
        end

        # Returns an array of +Rumbly::Model::ActiveRecord::Relationship+ objects that
        # represent all subclass relationships between model classes.
        def self.all_from_generalizations (app)
          app.klasses.map(&:cls).compact.reject(&:descends_from_active_record?).map do |c|
            source = c.superclass.name
            target = c.name
            new(app, nil, :generalization, source, target)
          end
        end

        # Returns an +Array+ of +ActiveRecord+ associations which match the given +type+
        # and have the given +option+, e.g. +:belongs_to+ and +:polymorphic+.
        def self.associations_matching (app, type, option)
          all_associations(app).select { |a| a.macro == type }.select do |a|
            a.options.keys.include?(option)
          end
        end
        
        # Returns all +ActiveRecord+ associations for all model classes in the currently
        # loaded environment.
        def self.all_associations (app)
          app.klasses.map(&:cls).compact.map(&:reflect_on_all_associations).flatten
        end

        # Initializes a new +Relationship+ using the given +ActiveModel+ +association+
        # (in the case of non-generalizations), or the given +type+, +source+, and
        # +target+ in the case of generalizations.
        def initialize (app, association, type=nil, source=nil, target=nil)
          @app = app
          @association = association
          @type = type
          @source = source
          @target = target
        end

        # Returns the UML relationship type for this +Relationship+. For a relationships
        # that's a generalization (subclass), the +type+ is set upon initialization.
        # Otherwise, this method examines the +ActiveRecord+ association for clues that
        # point to the relationship being a simple +association+, an +aggregation+, or
        # the even stronger +composition+.
        def type
          if @type.nil?
            # relationships are simple associations by default
            @type = :association
            if [:has_one, :has_many].include?(@association.macro)
              autosaves = @association.options[:autosave]
              dependent = @association.options[:dependent]
              # if this association auto-saves or nullifies, assume aggregation
              if autosaves || dependent == :nullify
                @type = :aggregation
              end
              # if this association destroys dependents, assume composition
              if dependent == :destroy || dependent == :delete
                @type = :composition
              end
            end
          end
          return @type
        end

        # Returns the source +Klass+ for this +Relationship+. Gets the +ActiveRecord+
        # model class that's the source of the underlying association and looks up
        # the corresponding +Klass+ object in our cache.
        def source
          @source ||= @app.klass_by_name(@association.active_record.name)
        end
        
        # Returns the target +Klass+ for this +Relationship+. Gets the +ActiveRecord+
        # model class that's the target of the underlying association and looks up
        # the corresponding +Klass+ object in our cache.
        def target
          @target ||= @app.klass_by_name(@association.klass.name)
        end

        # Returns the name of this +Relationship+, which is just the +name+ from the
        # +ActiveRecord+ association (or nil if this +Relationship+ doesn't have an
        # association, i.e. it's a generalization).
        def name
          (type == :generalization) ? nil : (@name ||= @association.name)
        end
        
        # Returns the multiplicity of this +Relationship+ based on the type of the
        # +ActiveRecord+ association, e.g. +:has_one+, +:has_many+, +:belongs_to+, etc.
        def multiplicity
          (type == :generalization) ? nil : (@multiplicity ||= derive_multiplicity)
        end
        
        # Returns the "through" class declared 
        def through
          (type == :generalization) ? nil : (@through ||= find_through_klass)
        end

        # Returns true, since +ActiveRecord+ doesn't have the concept of non-navigable
        # assocations.
        def navigable
          true
        end
        
        private

        # Returns an array of two numbers that represents the multiplicity of this
        # +Relationship+ based on the type of +ActiveRecord+ association it is.
        def derive_multiplicity
          case @association.macro
          when :has_one
            # has_one associations can have zero or one associated object
            [0,1]
          when :has_many, :has_and_belongs_to_many
            # has_many and habtm associations can have zero or more associated objects
            [0,::Rumbly::Model::N]
          when :belongs_to
            # belongs_to associations normally have zero or one related object, but
            # we check for a presence validator to see if the link is required
            validators = source.cls.validators_on(@association.foreign_key.to_sym)
            if validators.select { |v| v.kind == :presence }.any?
              [1,1]
            else
              [0,1]
            end
          end
        end

        # Finds the +Klass+ object corresponding to the "through" class on the has_one
        # or has_many association for this +Relationship+.
        def find_through_klass
          unless @through_checked
            @through_checked = true
            if [:has_one, :has_many].include?(@association.macro)
              through = @association.options[:through]
              unless through.nil?
                return @app.klass_by_name(through)
              end
            end
          end
          return nil
        end
        
      end
      
    end
  end
end
