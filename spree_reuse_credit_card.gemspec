# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_reuse_credit_card'
  s.version     = '1.3.0'
  s.summary     = 'Enables view enhancements for managing multiple previously-used credit cards for Spree'
  s.description = 'Enables view enhancements for managing multiple previously-used credit cards for Spree'
  s.required_ruby_version = '>= 1.9.2'

  s.author            = 'Jeff Squires'
  s.email             = 'jeff.squires@gmail.com'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 1.3.1'
end

