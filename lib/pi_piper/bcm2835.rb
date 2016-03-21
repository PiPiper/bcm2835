require 'pi_piper/bcm2835/version'
require 'pi_piper/bcm2835/pin'
require 'pi_piper/bcm2835/driver'

module PiPiper
  module Bcm2835
    class << self
      def driver
        @driver ||= PiPiper::Bcm2835::Driver.new
      end
    end
  end
end
