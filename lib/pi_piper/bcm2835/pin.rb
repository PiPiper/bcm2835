require 'set'

module PiPiper
  module Bcm2835
    module Pin
      def pins
        @pins ||= Set.new
      end

      def pin_input(pin)
        export(pin)
        pin_direction(pin, 'in')
      end

      def pin_set(pin, value)
        File.write("/sys/class/gpio/gpio#{pin}/value", value)
      end

      def pin_output(pin)
        export(pin)
        pin_direction(pin, 'out')
      end

      def pin_read(pin)
        raise ArgumentError, "Pin #{pin} is not exported" if unexported?(pin)
        File.read("/sys/class/gpio/gpio#{pin}/value").to_i
      end

      def unexport(pin)
        raise ArgumentError, "Pin #{pin} not exported" if unexported?(pin)
        File.write('/sys/class/gpio/unexport', pin)
        pins.delete(pin)
      end

      def unexport_all
        pins.dup.each { |pin| unexport(pin) }
      end

      def exported?(pin)
        pins.include?(pin)
      end

      def unexported?(pin)
        !exported?(pin)
      end

      private
      
      def export(pin)
        raise ArgumentError, "Pin #{pin} already exported" if exported?(pin)
        File.write('/sys/class/gpio/export', pin)
        pins << pin
      end

      def pin_direction(pin, direction)      
        File.write("/sys/class/gpio/gpio#{pin}/direction", direction)
      end

    end
  end
end
