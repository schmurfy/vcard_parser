# -*- encoding: utf-8 -*-
require File.expand_path('../lib/vcard_parser/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Julien Ammous"]
  gem.email         = ["schmurfy@gmail.com"]
  gem.description   = %q{A vCard parser}
  gem.summary       = %q{A simple vCard parser}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.name          = "vcard_parser"
  gem.require_paths = ["lib"]
  gem.version       = VcardParser::VERSION
end
