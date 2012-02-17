module Rumbly

  # An +OptionsHash+ is a subclass of +Hash+ class that adds the following functionality:
  # - all keys are converted to symbols when storing or retrieving
  # - values can be accessed using methods named after keys (ala Structs)
  # - nested values can be accessed using chained method calls or dotted key values
  # - keys are implicitly created if an unknown method is called
  # - the +has_key?+ method is enhanced to test for nested key paths
  class OptionsHash < ::Hash
    
    # Converts +key+ to a +Symbol+ before calling the normal +Hash#[]+ method. If the
    # key is a dotted list of keys, digs down into any nested hashes to find the value.
    # Returns +nil+ if any of the sub-hashes are not present.
    def [] (key)
      unless key =~ /.\../
        super(key.to_sym)
      else
        k, *r = *split_key(key)
        if (sub = self[k]).nil?
          nil
        else
          self[k][join_keys(r)]
        end
      end
    end
      
    # Converts +key+ to a +Symbol+ before calling the normal +Hash#[]=+ method. If the
    # key is a dotted list of keys, digs down into any nested hashes (creating them if
    # necessary) to store the value.
    def []= (key, value)
      unless key =~ /.\../
        super(key.to_sym, value)
      else
        k, *r = *split_key(key)
        sub = get_or_create_value(k)
        sub[join_keys(r)] = value
      end
    end
    
    # Returns +true+ if this +OptionsHash+ has a value stored under the given +key+.
    # In the case of a compound key (multiple keys separated by dots), digs down into
    # any nested hashes to find a value. Returns +false+ if any of the sub-hashes or
    # values are nil.
    def has_key? (key)
      unless key =~ /.\../
        super(key.to_sym)
      else
        k, *r = *split_key(key)
        return false if (sub = self[k]).nil?
        return sub.has_key?(join_keys(r))
      end
    end
    
    # Allows values to be stored and retrieved using methods named for the keys. If
    # an attempt is made to access a key that doesn't exist, a nested +OptionsHash+
    # will be created as the value stored for the given key. This allows for setting
    # a nested option without having to explicitly create each nested hash.
    def method_missing (name, *args, &blk)
      unless respond_to?(name)
        if reader?(name, args, blk)
          get_or_create_value(name)
        elsif writer?(name, args, blk)
          store_value(chop_sym(name), args[0])
        end
      end
    end
    
    private
    
    def split_key (path)
      path.to_s.split('.').map(&:to_sym)
    end
    
    def join_keys (a)
      a.join('.')
    end

    def reader? (name, args, blk)
      blk.nil? && args.empty?
    end
  
    def writer? (name, args, blk)
      blk.nil? && args.size == 1 && name =~ /=$/
    end
    
    def chop_sym (sym)
      sym.to_s.chop.to_sym
    end
    
    def get_or_create_value (key)
      self[key] ||= OptionsHash.new
    end

    def store_value (key, value)
      get_or_create_value(key)
      store(key, value)
    end      
  
  end

end
