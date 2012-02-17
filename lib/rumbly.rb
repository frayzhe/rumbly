require 'rumbly/options_hash'
require 'rumbly/railtie' if defined?(Rails)

module Rumbly

  class << self
    attr_accessor :options
  end

  # setup default options
  self.options = o = OptionsHash.new
  
  # general options
  o.messages = :verbose
  
  # model options
  o.model.type        = :auto
  
  # diagram general options
  o.diagram.type        = :graphviz
  o.diagram.file        = 'classes'
  o.diagram.format      = :pdf
  
  # diagram attribute options
  o.diagram.attribute.types = :content
  
  # diagram relationship options
  o.diagram.relationship.labels = true

end
