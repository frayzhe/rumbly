module Rumbly
  module Base
    # Sets and returns the given +attr+ which may be nil. Sets an instance variable in
    # the current object to indicate that the given +attr+ has been calculated (so an
    # expensive calculation won't happen more than once even if it returns nil).
    def set_possibly_nil_attribute (attr)
      if instance_variable_get("@#{attr}").nil?
        unless instance_variable_get("@#{attr}_set")
          instance_variable_set("@#{attr}", yield)
          instance_variable_set("@#{attr}_set", true)
        end
      end
      instance_variable_get("@#{attr}")
    end
  end
end
