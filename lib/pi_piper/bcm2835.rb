require 'ffi'
require "pi_piper/bcm2835/version"
require "pi_piper/bcm2835/bcm2835"

module PiPiper
  self.driver= PiPiper::Bcm2835
end
