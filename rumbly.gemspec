Gem::Specification.new do |s|
  s.name          = "rumbly"
  s.version       = "0.2.0"
  s.platform      = Gem::Platform::RUBY
  s.date          = Date.today
  s.summary       = "UML class diagram generator"
  s.description   = "Generates UML class diagrams from a variety of different object mappers"
  s.authors       = ["Dustin Frazier"]
  s.email         = "ruby@frayzhe.net"
  s.homepage      = "http://github.com/frayzhe/rumbly"
  
  s.add_runtime_dependency "activesupport", ["~> 3.0"]
  s.add_runtime_dependency "ruby-graphviz", ["~> 1.0"]  
  
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end
