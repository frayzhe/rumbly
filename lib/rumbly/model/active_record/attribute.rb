require 'rumbly/model/attribute'

module Rumbly
  module Model
    module ActiveRecord
      
      # This class is an +ActiveRecord+-specific implementation of the abstract
      # +Rumbly::Model::Attribute+ class use dto represent declared attributes (columns)
      # on model classes in the currently loaded environment.
      class Attribute < Rumbly::Model::Attribute

        # Returns an array of +Rumbly::Model::ActiveRecord::Attribute+ objects, each
        # of which wraps a field (column) from the given +ActiveRecord+ model class.
        def self.all_from_klass (klass)
          klass.cls.columns.map do |column|
            new(klass, column)
          end
        end

        def initialize (klass, column)
          @klass = klass
          @cls = klass.cls
          @column = column
        end
        
        # Returns the name of this +ActiveRecord+ attribute based on the column
        # definition.
        def name
          @name ||= @column.name
        end

        # Returns the type of this +ActiveRecord+ attribute based on the column
        # definition.
        def type
          @type ||= begin
            type = @column.type.to_s
            unless @column.limit.nil?
              type += "(#{@column.limit})"
            end
            unless @column.precision.nil? || @column.scale.nil?
              type += "(#{@column.precision},#{@column.scale})"
            end
            type
          end
        end

        # Returns +nil+ since +ActiveRecord+ doesn't declare attribute visibility.
        def visibility
          nil
        end
        
        # Returns +nil+ since +ActiveRecord+ doesn't allow for non-intrinsic attributes.
        def multiplicity
          nil
        end
        
        # Returns this attribute's default value based on +ActiveRecord+ column definition.
        def default
          @default ||= @column.default
        end
        
        # Returns +nil+ since +ActiveRecord+ doesn't support any of the standard UML
        # attribute properties (e.g. read-only, union, composite, etc.).
        def properties
          []
        end

        # Returns an +Array+ of +String+ values representing constraints placed on this
        # attribute via +ActiveModel+ validations. Only simple, declarative validations
        # will be reflected as constraints (i.e. not conditional or custom
        # validations). Also, some parameters or conditions on simple validations will
        # not be shown, e.g. scope or case-sensitivity on a uniqueness validation.
        # Currently, the following +ActiveModel+ validations are ignored: +inclusion+,
        # +exclusion+, +format+, and any conditional validations.
        def constraints
          @constraints ||= begin
            constraints = []
            constraints << 'required' if required?
            constraints << 'unique' if unique?
            append_numeric_constraints(constraints)
            append_length_constraints(constraints)
            constraints
          end
        end

        # Returns +nil+ since +ActiveRecord+ doesn't declare derived attributes.
        def derived
          nil
        end

        # Returns +nil+ since +ActiveRecord+ doesn't declare static (class) attributes.
        def static
          nil
        end
        
        private
        
        def required?
          @cls.validators_on(name).map(&:kind).include?(:presence)
        end
        
        def unique?
          @cls.validators_on(name).map(&:kind).include?(:uniqueness)
        end
        
        NUMERIC_VALIDATORS = [
          [ :integer_only,             'integer' ],
          [ :odd,                      'odd'     ],
          [ :even,                     'even'    ],
          [ :greater_than,             '> %{x}'  ],
          [ :greater_than_or_equal_to, '>= %{x}' ],
          [ :equal_to,                 '= %{x}'  ],
          [ :less_than,                '< %{x}'  ],
          [ :less_than_or_equal_to,    '<= %{x}' ],
        ]
        
        # Appends any numeric constraints on this +ActiveRecord+ attribute via one or
        # more +numericality+ validations.
        def append_numeric_constraints (constraints)
          validators = @cls.validators_on(name).select { |v| v.kind == :numericality }
          unless validators.nil? || validators.empty?
            options = validators.map { |v| v.options }.inject { |all,v| all.merge(v) }
            NUMERIC_VALIDATORS.each do |validator|
              key, str = validator
              if options.has_key?(key)
                constraints << str.gsub(/x/,key.to_s) % options
              end
            end
          end
        end

        # Appends any length constraints put on this +ActiveRecord+ attribute via one
        # or more +length+ validations.
        def append_length_constraints (constraints)
          validators = @cls.validators_on(name).select { |v| v.kind == :length }
          unless validators.nil? || validators.empty?
            options = validators.map { |v| v.options }.inject { |all,v| all.merge(v) }
            constraints << case
            when options.has_key?(:is)
              "length = #{options[:is]}"
            when options.has_key?(:in)
              "length in (#{options[:in]})"
            when options.has_key?(:minimum) && options.has_key?(:maximum)
              "#{options[:minimum]} <= length <= #{options[:maximum]}"
            when options.has_key?(:minimum)
              "length >= #{options[:minimum]}"
            when options.has_key?(:maximum)
              "length <= #{options[:maximum]}"
            end
          end
        end
        
      end
      
    end
  end
end
