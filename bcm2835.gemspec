# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bcm2835/version'

Gem::Specification.new do |spec|
  spec.name          = 'bcm2835'
  spec.version       = Bcm2835::VERSION
  spec.authors       = ['Zshawn Syed', 'Jason Whitehorn']
  spec.email         = ['zsyed91@gmail.com', 'jason.whitehorn@gmail.com']

  spec.summary       = 'BCM2835 driver library for the Raspberry Pi and' \
                       ' PiPiper library'
  spec.description   = 'BC2835 driver library for the Raspberry Pi and other' \
                       ' boards that use the chipset. Commonly used with the' \
                       ' PiPiper ruby library'
  spec.homepage      = 'https://github.com/pipiper/bcm2835'
  spec.license       = 'BSD'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
