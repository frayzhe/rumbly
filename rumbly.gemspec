Gem::Specification.new do |s|
  s.name          = 'rumbly'
  s.version       = '0.1.0'
  s.platform      = Gem::Platform::RUBY
  s.date          = '2010-02-06'
  s.summary       = "Let's get ready to rumble"
  s.description   = "More detailed description coming soon..."
  s.authors       = ["Dustin Frazier"]
  s.email         = "ruby@frayzhe.net"
  s.homepage      = "http://github.com/frayzhe/rumbly"
  s.files         = Dir["lib/**/*.rb"] + Dir["lib/**/*.rake"]
  
  s.add_runtime_dependency "activesupport", ["~> 3.0"]
  s.add_runtime_dependency "ruby-graphviz", ["~> 1.0"]  
  
  s.require_paths = ["lib"]
end
