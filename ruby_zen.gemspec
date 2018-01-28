
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ruby_zen/version"

Gem::Specification.new do |spec|
  spec.name          = "ruby_zen"
  spec.version       = RubyZen::VERSION
  spec.authors       = ["Nguyễn Quang Minh"]
  spec.email         = ["nguyenquangminh0711@gmail.com"]

  spec.summary       = %q{Autocomplete engine for Ruby that actually works.}
  spec.description   = %q{In the world of Ruby, autocomplete is considered impossible. This system was born to prove that idea is wrong. It provides context-awared autocomplete engine that acts as a backend for many editor plugins}
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency 'yarv_generator', '~> 0.2.0'
end
