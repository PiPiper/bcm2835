# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pi_piper/bcm2835/version'

Gem::Specification.new do |spec|
  spec.name          = "pi_piper-bcm2835"
  spec.version       = PiPiper::Bcm2835::VERSION
  spec.authors       = ['Zshawn Syed', 'Jason Whitehorn', 'Marc-Antoine Brenac']
  spec.email         = ['zsyed91@gmail.com', 'jason.whitehorn@gmail.com', 'elmatou@gmail.com']

  spec.summary       = %q{BCM2835 driver library for the Raspberry Pi and PiPiper, based on libbcm2835 by Mike McCauley}
  spec.description   = 'BC2835 driver library for the Raspberry Pi and other' \
                       ' boards that use the chipset. Commonly used with the' \
                       ' PiPiper ruby library. it implements Pin (with events' \
                       ' and pull up/down), Spi, I2C, Pwm, by reading driectly to /dev/mem.'

  spec.homepage      = "https://github.com/PiPiper/bcm2835"
  spec.license       = "BSD"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib/pi_piper"]

  spec.add_runtime_dependency 'pi_piper', ">= 2.0.0"
  spec.add_runtime_dependency 'ffi'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'
end
