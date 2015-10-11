$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name           = 'sidekiq_single'
  s.version        = '0.0.1'
  s.date           = '2015-10-11'
  s.summary        = "Allows single thread to consum a dedicated queue across many processes"
  s.description    = "This gem enables you to set only single thread to consume a queue across many processes, 
  it is helpful in a many callback enviroment"
  s.authors        = ["Raphael Fraiman"]
  s.email          = 'raphael.fraiman@gmail.com'
  s.require_paths  = ["lib"]
  s.homepage       = 'http://rubygems.org/gems/sidekiq_single'
  s.license        = 'BSD-2-Clause'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end
