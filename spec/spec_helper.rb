require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
#require 'pi_piper/bcm2835'
require 'pi_piper/bcm2835/version'
require 'pi_piper/bcm2835/pin'
