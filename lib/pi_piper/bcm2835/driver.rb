require 'ffi'

module PiPiper
  module Bcm2835
    # The Bcm2835 module is not intended to be directly called.
    # It serves as an FFI library for PiPiper::SPI and PiPiper::I2C
    class Driver
      extend PiPiper::Bcm2835::Pin
      extend PiPiper::Bcm2835::SPI
      extend PiPiper::Bcm2835::I2C
      extend FFI::Library

      def instantiate
        ffi_lib File.expand_path('../../../../bin/libbcm2835.so', __FILE__)
        setup_gpio
        setup_pwm
        setup_spi
        setup_i2c
      end

      def setup_gpio
        attach_function :init, :bcm2835_init, [], :uint8
        attach_function :close, :bcm2835_close, [], :uint8
        
        # Sets the Function Select register for the given pin, which configures the
        # pin as Input, Output or one of the 6 alternate functions.
        attach_function :gpio_select_function, :bcm2835_gpio_fsel,    [:uint8, :uint8], :void
        # attach_function :gpio_set,             :bcm2835_gpio_set,     [:uint8], :void
        # attach_function :gpio_clear,           :bcm2835_gpio_clr,     [:uint8], :void
        # attach_function :gpio_level,           :bcm2835_gpio_lev,     [:uint8], :uint8

        # pin support...
        attach_function :pin_set_pud, :bcm2835_gpio_set_pud, [:uint8, :uint8], :void
      end

      def setup_pwm
        # PWM support...
        attach_function :pwm_clock,     :bcm2835_pwm_set_clock,  [:uint32], :void
        attach_function :pwm_mode,      :bcm2835_pwm_set_mode,   [:uint8, :uint8, :uint8], :void
        attach_function :pwm_range,     :bcm2835_pwm_set_range,  [:uint8, :uint32], :void
        attach_function :pwm_data,      :bcm2835_pwm_set_data,   [:uint8, :uint32], :void
      end


    end
  end
end
