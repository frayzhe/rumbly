require 'active_support/core_ext/string/inflections'
require 'rumbly/model/link'

module Rumbly
  module Model
    module ActiveRecord

      # This class is an +ActiveRecord+-specific implementation of the abstract
      # +Rumbly::Model::Link+ class used to represent declared links between classes in
      # in the currently loaded environment. These links can either be associations
      # (e.g. :has_many, :belongs_to, etc.) subclass declarations (what UML calls
      # generalizations), or realizations, i.e. the link between a class and the
      # pseudo-class named in a polymorphic association. For associations, the
      # +@association+ instance variable stores the underlying +ActiveRecord+ meta-data,
      # and the +source+, +target+, +name+, +type+, etc. are derived from that. For
      # generalizations and realizations, the +source+, +target+, and +type+ fields are
      # set at initialization, and the association is nil.
      class Link < Rumbly::Model::Link
        
        class << self
          
          # Returns an array of +Rumbly::Model::ActiveRecord::Link+ objects that
          # represent both associations and generalizations (i.e. subclasses) in the
          # currently loaded +ActiveRecord+ environment.
          def all_from_active_record (application)
            all_from_assocations(application) + all_from_generalizations(application)
          end

          # Returns an array of +Rumbly::Model::ActiveRecord::Link+ objects that
          # represent declared associations between model classes.
          def all_from_assocations (application)
            all_associations(application).map do |assoc|
              unless assoc.options[:as].nil?
                # for polymorphic has_one or has_many associations, we create two links:
                # one realization from the association's class to the "interface" named
                # in the :as option (e.g. commentable), representing the idea that the
                # class "implements" the interface; and another link from the "interface"
                # to the target of the association (e.g. comment), showing the has_one
                # or has_many association from the "interface" to the target class.
                source = application.klass_by_name(assoc.active_record.name)
                target = application.klass_by_name(assoc.options[:as].to_s.classify)
                realization = new(application, nil, source, target, :realization)
                source = target
                target = application.klass_by_name(assoc.class_name)
                pseudo = new(application, assoc, source, target, :association)
                [realization, pseudo]
              else
                # otherwise, just create a link based on the association
                new(application, assoc)
              end
            end.flatten
          end

          # Returns an array of +Rumbly::Model::ActiveRecord::Link+ objects that
          # represent all subclass declarations between model classes.
          def all_from_generalizations (application)
            classes = application.klasses.map(&:cls).compact
            classes.reject(&:descends_from_active_record?).map do |cls|
              source = application.klass_by_name(cls.superclass.name)
              target = application.klass_by_name(cls.name)
              new(application, nil, source, target, :generalization)
            end
          end

          # Returns an +Array+ of +ActiveRecord+ associations which match the given
          # +macro+ and have the given +option+, e.g. +:belongs_to+ and +:polymorphic+.
          def associations_matching (application, macro, option)
            all_associations(application).select { |a| a.macro == macro }.select do |a|
              a.options.keys.include?(option)
            end
          end
        
          # Returns all +ActiveRecord+ associations for all model classes.
          def all_associations (application)
            application.klasses.map(&:cls).compact.map do |cls|
              cls.reflect_on_all_associations.select { |a| a.active_record == cls }
            end.flatten
          end
        
        end
        
        # Initializes a new +Link+ using the given +ActiveModel+ +association+ (in the
        # case of a non-generalization), or the given +source+, +target+, and +type+ in
        # the case of a generalization or realization.
        def initialize (application, association, source=nil, target=nil, type=nil)
          @application = application
          @association = association
          @source = source
          @target = target
          @type = type
        end

        # Returns the source +Klass+ for this +Link+. Gets the +ActiveRecord+ model
        # class that's the source of the underlying association and looks up the
        # corresponding +Klass+ object in our cache.
        def source
          @source ||= @application.klass_by_name(@association.active_record.name)
        end
        
        # Returns the target +Klass+ for this +Link+. Gets the +ActiveRecord+ model
        # class that's the target of the underlying association and looks up the
        # corresponding +Klass+ object in our cache.
        def target
          @target ||= @application.klass_by_name(@association.class_name)
        end
        
        # Returns the name of this +Link+, which is just the +name+ from the
        # +ActiveRecord+ association (or nil if this +Link+ doesn't have an association,
        # i.e. it is a generalization).
        def name
          @name ||= (@association.name unless @association.nil?)
        end
        
        # Returns the type for this +Link+. For generalizations and realizations, the
        # +type+ is set at initialization time. Otherwise, this method examines the
        # +ActiveRecord+ association for clues that point to the link being a simple
        # +:association+, an +:aggregation+, or the even stronger +:composition+.
        def type
          if @type.nil?
            @type = :association
            if [:has_one, :has_many].include?(@association.macro)
              autosaves = @association.options[:autosave]
              dependent = @association.options[:dependent]
              if autosaves || dependent == :nullify
                @type = :aggregation
              elsif dependent == :destroy || dependent == :delete
                @type = :composition
              end
            end
          end
          @type
        end
        
        # Returns the multiplicity of this +Link+ based on the ind of the +ActiveRecord+
        # association, e.g. +:has_one+, +:has_many+, +:belongs_to+, etc.
        def multiplicity
          set_possibly_nil_attribute(:multiplicity) do
            unless @association.nil?
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
          end
        end
        
        # Returns the "through" class declared as part of the underlying +ActiveRecord+
        # assocatiation, or +nil+ if this +Link+ is a generalization.
        def through
          set_possibly_nil_attribute(:through) do
            unless @association.nil?
              if [:has_one, :has_many].include?(@association.macro)
                through = @association.options[:through]
                unless through.nil?
                  @application.klass_by_name(through.to_s.classify)
                end
              end
            end
          end
        end

        def <=> (other)
          self.sort_key <=> other.sort_key
        end

        def sort_key ()
          @association.nil? ? 10 : LINK_ORDERS[@association.macro]
        end
        
        private

        # Defines a custom sort order for +Links+ based on the underlying association.
        LINK_ORDERS = {
          has_and_belongs_to_many: 0,
          has_many:                1,
          has_one:                 2,
          belongs_to:              3
        }
        
      end
    end
  end
end
