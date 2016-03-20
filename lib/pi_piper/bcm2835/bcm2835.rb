module PiPiper
  class Bcm2835 < Driver

    def initialize(dev = false)
      bcm2835_set_debug(1) if dev
      @triggered_pins = Set.new
      bcm2835_init
    end

    def close
      pin_clear_trigger_all 
      bcm2835_close == 1 && @triggered_pins.empty?
    end

    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), 'libbcm2835.so')

    GPIO_FSEL_INPT = 0b000
    GPIO_FSEL_OUTP = 0b001
    GPIO_FSEL_ALT0 = 0b100
    GPIO_FSEL_ALT1 = 0b101
    GPIO_FSEL_ALT2 = 0b110
    GPIO_FSEL_ALT3 = 0b111
    GPIO_FSEL_ALT4 = 0b011
    GPIO_FSEL_ALT5 = 0b010
    GPIO_FSEL_MASK = 0b111

  

    attach_function :bcm2835_set_debug, :bcm2835_set_debug, [:uint8], :void
    attach_function :bcm2835_init, :bcm2835_init, [], :uint8
    attach_function :bcm2835_close, :bcm2835_close, [], :uint8

# Support GPIO pins
    
    GPIO_PUD_OFF = 0
    GPIO_PUD_DOWN = 1
    GPIO_PUD_UP = 2

    GPIO_HIGH = 1
    GPIO_LOW  = 0

    # Sets the Function Select register for the given pin, which configures the pin as Input, Output or one of the 6 alternate functions.
    attach_function :gpio_select_function, :bcm2835_gpio_fsel,    [:uint8, :uint8], :void
    attach_function :gpio_set,             :bcm2835_gpio_set,     [:uint8], :void
    attach_function :gpio_clear,           :bcm2835_gpio_clr,     [:uint8], :void
    attach_function :gpio_level,           :bcm2835_gpio_lev,     [:uint8], :uint8
    attach_function :gpio_set_pud,         :bcm2835_gpio_set_pud, [:uint8, :uint8], :void
    

    
    def pin_direction(pin, direction)
      value = case direction
      when :in then GPIO_FSEL_INPT
      when :out then GPIO_FSEL_OUTP 
      else raise ArgumentError, 'direction should be :in or :out' 
      end

      gpio_select_function(pin, value)
    end

    def pin_read(pin)
      gpio_level(pin)# == PinValues::GPIO_HIGH
    end

    def pin_write(pin, value)
      case value
        when GPIO_LOW then gpio_clear(pin)
        when GPIO_HIGH then gpio_set(pin)
        else raise ArgumentError, 'value should be GPIO_LOW (0) or GPIO_HIGH (1)'
      end
      value
    end

    def pin_set_pud(pin, value)
      case value
        when :up   then gpio_set_pud(pin, GPIO_PUD_UP)
        when :down then gpio_set_pud(pin, GPIO_PUD_DOWN)
        when :off, :float then gpio_set_pud(pin, GPIO_PUD_OFF)
        else raise ArgumentError, 'pull should be :up, :down, :float or :off'
      end
    end
    

    # Sets the Function Event register for the given pin.
    attach_function :gpio_event_low,       :bcm2835_gpio_len,    [:uint8], :void
    attach_function :gpio_event_high,      :bcm2835_gpio_hen,    [:uint8], :void
    attach_function :gpio_event_rising,    :bcm2835_gpio_ren,    [:uint8], :void
    attach_function :gpio_event_falling,   :bcm2835_gpio_fen,    [:uint8], :void
    # attach_function :gpio_event_async_rising,   :bcm2835_gpio_aren,    [:uint8], :void
    # attach_function :gpio_event_async_falling,  :bcm2835_gpio_afen,    [:uint8], :void

    attach_function :gpio_event_status,    :bcm2835_gpio_eds,    [:uint8], :uint8
    attach_function :gpio_event_set_status,:bcm2835_gpio_set_eds,[:uint8], :void

    attach_function :gpio_event_clear_low,          :bcm2835_gpio_clr_len, [:uint8], :void
    attach_function :gpio_event_clear_high,         :bcm2835_gpio_clr_hen, [:uint8], :void
    attach_function :gpio_event_clear_rising,       :bcm2835_gpio_clr_ren, [:uint8], :void
    attach_function :gpio_event_clear_falling,      :bcm2835_gpio_clr_fen, [:uint8], :void

    # attach_function :gpio_event_clear_async_rising, :bcm2835_gpio_clr_aren, [:uint8], :void
    # attach_function :gpio_event_clear_async_falling,:bcm2835_gpio_clr_afen, [:uint8], :void


    def pin_set_trigger(pin, trigger)
      pin_clear_trigger(pin)

      case trigger
        when :rising  then gpio_event_rising(pin)
        when :falling then gpio_event_falling(pin)
        when :high    then gpio_event_high(pin)
        when :low     then gpio_event_low(pin)
        
        when :both
          gpio_event_rising(pin)
          gpio_event_falling(pin)
        when :none    then return nil
        else raise ArgumentError, 'trigger should be :none, :rising, :falling, :both, :high or :low'
      end

      @triggered_pins.add pin
    end

    def pin_wait_for(pin)
      loop do
        if gpio_event_status(pin) == GPIO_HIGH
          gpio_event_set_status(pin)
          break
        end 
        sleep 0.1
      end
    end

    def pin_clear_trigger(pin)
      gpio_event_rising(pin)
      gpio_event_falling(pin)
      gpio_event_high(pin)
      gpio_event_low(pin)
      # gpio_event_clear_async_falling(pin)
      # gpio_event_clear_async_rising(pin)

      @triggered_pins.delete pin
    end

    def pin_clear_trigger_all
      @triggered_pins.dup.each { |pin| pin_clear_trigger(pin) }
    end


#Pwm
    PWM_PIN = {
        12 => {:channel => 0, :alt_fun => GPIO_FSEL_ALT0},
        13 => {:channel => 1, :alt_fun => GPIO_FSEL_ALT0},
        18 => {:channel => 0, :alt_fun => GPIO_FSEL_ALT5},
        19 => {:channel => 1, :alt_fun => GPIO_FSEL_ALT5},
        40 => {:channel => 0, :alt_fun => GPIO_FSEL_ALT0},
        41 => {:channel => 1, :alt_fun => GPIO_FSEL_ALT0},
        45 => {:channel => 1, :alt_fun => GPIO_FSEL_ALT0},
        52 => {:channel => 0, :alt_fun => GPIO_FSEL_ALT1},
        53 => {:channel => 1, :alt_fun => GPIO_FSEL_ALT1}
    }

    PWM_MODE = [:balanced, :markspace]

    attach_function :bcm2835_pwm_set_clock,  :bcm2835_pwm_set_clock,  [:uint32], :void
    attach_function :bcm2835_pwm_set_mode,   :bcm2835_pwm_set_mode,   [:uint8, :uint8, :uint8], :void
    attach_function :bcm2835_pwm_set_range,  :bcm2835_pwm_set_range,  [:uint8, :uint32], :void
    attach_function :bcm2835_pwm_set_data,   :bcm2835_pwm_set_data,   [:uint8, :uint32], :void

    def pwm_set_pin(pin)
      raise ArgumentError, "pin should be one of #{PWM_PIN.keys}" unless PWM_PIN[pin]
      gpio_select_function(pin, PWM_PIN[pin][:alt_fun])
    end

# TODO: update PiPiper::Pwm to set the clock and the driver should handle the clock_divider
    def pwm_set_clock(clock_divider)
      # (19.2.megahertz.to_f / clock).to_i
      bcm2835_pwm_set_clock(clock_divider)
    end

    def pwm_set_mode(pin, mode, start = 1)
      raise ArgumentError, "mode should be one of #{PWM_MODE}" unless PWM_MODE.include? mode
      bcm2835_pwm_set_mode(PWM_PIN[pin][:channel], PWM_MODE.index(mode), start)
    end

    def pwm_set_range(pin, range)
      bcm2835_pwm_set_range(PWM_PIN[pin][:channel], range)
    end

    def pwm_set_data(pin, data)
      bcm2835_pwm_set_data(PWM_PIN[pin][:channel], data)
    end

#SPI
    SPI_MODE0 = 0
    SPI_MODE1 = 1
    SPI_MODE2 = 2
    SPI_MODE3 = 3

    attach_function :spi_begin,       :bcm2835_spi_begin,            [], :uint8
    attach_function :spi_end,         :bcm2835_spi_end,              [], :uint8
    attach_function :spi_transfer,    :bcm2835_spi_transfer,         [:uint8], :uint8
    attach_function :spi_transfernb,  :bcm2835_spi_transfernb,       [:pointer, :pointer, :uint], :void
    attach_function :spi_clock,       :bcm2835_spi_setClockDivider,  [:uint8], :void
    attach_function :spi_bit_order,   :bcm2835_spi_setBitOrder,      [:uint8], :void
    attach_function :spi_chip_select, :bcm2835_spi_chipSelect,       [:uint8], :void
    attach_function :spi_set_data_mode, :bcm2835_spi_setDataMode,    [:uint8], :void
    attach_function :spi_chip_select_polarity, 
                    :bcm2835_spi_setChipSelectPolarity,              [:uint8, :uint8], :void

    def spi_transfer_bytes(data)
      data_out = FFI::MemoryPointer.new(data.count)
      data_in = FFI::MemoryPointer.new(data.count)
      (0..data.count-1).each { |i| data_out.put_uint8(i, data[i]) }

      spi_transfernb(data_out, data_in, data.count)

      (0..data.count-1).map { |i| data_in.get_uint8(i) }
    end


#I2C
    I2C_REASON_OK         = 0  #Success
    I2C_REASON_ERROR_NACK = 1  #Received a NACK
    I2C_REASON_ERROR_CLKT = 2  #Received Clock Stretch Timeout
    I2C_REASON_ERROR_DATA = 3  #Not all data is sent / received

    attach_function :i2c_begin,      :bcm2835_i2c_begin,             [], :void
    attach_function :i2c_end,        :bcm2835_i2c_end,               [], :void
    attach_function :i2c_set_address,:bcm2835_i2c_setSlaveAddress,   [:uint8], :void
    attach_function :i2c_set_clock_divider, :bcm2835_i2c_setClockDivider,     [:uint16], :void
    attach_function :i2c_read,       :bcm2835_i2c_read,              [:pointer, :uint], :uint8
    attach_function :i2c_write,      :bcm2835_i2c_write,             [:pointer, :uint], :uint8

    def i2c_allowed_clocks
      [100.kilohertz,
       399.3610.kilohertz,
       1.666.megahertz,
       1.689.megahertz]
    end

    def i2c_transfer_bytes(data)
      data_out = FFI::MemoryPointer.new(data.count)
      (0..data.count-1).each{ |i| data_out.put_uint8(i, data[i]) } 

      i2c_write data_out, data.count
    end

    def i2c_read_bytes(bytes)
      data_in = FFI::MemoryPointer.new(bytes)
      i2c_read(data_in, bytes) #TODO reason codes 

      (0..bytes-1).map { |i| data_in.get_uint8(i) } 
    end
  end

end
