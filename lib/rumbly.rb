require 'rumbly/options_hash'
require 'rumbly/railtie' if defined?(Rails)

module Rumbly

  class << self
    attr_accessor :options
  end

  # setup default options
  self.options = OptionsHash.new
  
  # general options
  self.options.messages = :verbose
  
  # model options
  self.options.model.type = :auto
  
  # diagram options
  self.options.diagram.type   = :graphviz
  self.options.diagram.file   = 'classes'
  self.options.diagram.format = :pdf

end
