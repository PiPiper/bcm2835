require 'ffi'
require 'pi_piper/frequency'

module PiPiper
  module Bcm2835
    module I2C
      I2C_REASON_OK         = 0  # Success
      I2C_REASON_ERROR_NACK = 1  # Received a NACK
      I2C_REASON_ERROR_CLKT = 2  # Received Clock Stretch Timeout
      I2C_REASON_ERROR_DATA = 3  # Not all data is sent / received

      def setup_i2c
        attach_function :i2c_begin,      :bcm2835_i2c_begin,             [], :void
        attach_function :i2c_end,        :bcm2835_i2c_end,               [], :void
        attach_function :i2c_write,      :bcm2835_i2c_write,             [:pointer, :uint], :uint8
        attach_function :i2c_set_address,:bcm2835_i2c_setSlaveAddress,   [:uint8], :void
        attach_function :i2c_set_clock_divider, :bcm2835_i2c_setClockDivider,     [:uint16], :void
        attach_function :i2c_read,       :bcm2835_i2c_read,              [:pointer, :uint], :uint8
      end

      def i2c_allowed_clocks
        [100.kilohertz,
         399.3610.kilohertz,
         1.666.megahertz,
         1.689.megahertz]
      end

      def i2c_transfer_bytes(data)
        data_out = FFI::MemoryPointer.new(data.count)
        (0..data.count - 1).each{ |i| data_out.put_uint8(i, data[i]) }
        i2c_write(data_out, data.count)
      end

      def i2c_read_bytes(bytes)
        data_in = FFI::MemoryPointer.new(bytes)
        i2c_read(data_in, bytes) #TODO reason codes 

        (0..bytes - 1).map { |i| data_in.get_uint8(i) }
      end
    end
  end
end
