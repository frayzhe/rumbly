module Rumbly
  module Model
    
    # The +Abstract+ module is extended (not included) by abstract subclasses that
    # declare their public attributes and wish to have stub methods for these attributes
    # generated automatically. The stub methods raise an exception with the abstract
    # class name so implementers know that they need to implement the given method(s) in
    # their concrete subclass(es).
    module Abstract
      
      # Creates stub accesor methods for each of the given +attributes+. Each method
      # raises a +RuntimeError+, since the extending class is meant to be abstract.
      def stub_required_methods (cls, attributes)
        attributes.keys.each do |a|
          message = "Method '%s' called on abstract '#{cls.name}' class"
          define_method(a) { raise (message % a) }
          define_method("#{a}=") { |x| raise (message % "#{a}=") }
        end
      end
      
    end
  end
end
