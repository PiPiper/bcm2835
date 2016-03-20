require 'spec_helper'

describe PiPiper::Bcm2835 do
  it 'has a version number' do
    expect(PiPiper::Bcm2835::VERSION).not_to be nil
  end

  subject { PiPiper::Bcm2835.new(true) }

  context 'init & close' do
    it '#new' do
      expect { PiPiper::Bcm2835.new }.not_to raise_error
      expect(PiPiper::Bcm2835.new).to be_an_instance_of PiPiper::Bcm2835
      # bcm2835_init
    end

    it 'should remove triggers and close the lib on close' do
      expect(subject).to receive(:pin_clear_trigger_all)
      expect(subject).to receive(:bcm2835_close)
      subject.close
    end
  end

  context 'API for Pin' do
    describe '#pin_direction(pin, direction)' do
      it 'should set to :in' do
        expect(subject).to receive(:gpio_select_function).with(4, 0b000)
        subject.pin_direction(4, :in)
      end
      
      it 'should set to :out' do
        expect(subject).to receive(:gpio_select_function).with(4, 0b001)
        subject.pin_direction(4, :out)
      end
      
      it 'should raise error' do
        expect { subject.pin_direction(4, :inout) }.to raise_error ArgumentError, "direction should be :in or :out"
      end
    end

    it '#pin_write(pin, value)' do 
      expect(subject).to receive(:gpio_set).with(4)
      subject.pin_write(4, 1)

      expect(subject).to receive(:gpio_clear).with(5)
      subject.pin_write(5, 0)

      expect { subject.pin_write(4, 2) }.to raise_error ArgumentError, 'value should be GPIO_LOW (0) or GPIO_HIGH (1)'
    end

    it '#pin_read(pin)' do
      expect(subject).to receive(:gpio_level).with(4)
      subject.pin_read(4)
    end

    describe '#pin_set_pud(pin, value)' do
      it 'should set to :off or :float' do
        expect(subject).to receive(:gpio_set_pud).twice.with(4, 0)
        subject.pin_set_pud(4, :off)
        subject.pin_set_pud(4, :float)
      end
    
      it 'should set to :down' do
        expect(subject).to receive(:gpio_set_pud).with(4, 1)
        subject.pin_set_pud(4, :down)
      end
    
      it 'should set to :up' do
        expect(subject).to receive(:gpio_set_pud).with(4, 2)
        subject.pin_set_pud(4, :up)
      end
    
      it 'should raise error' do
        expect { subject.pin_set_pud(4, :updown) }.to raise_error ArgumentError, 'pull should be :up, :down, :float or :off'
      end
    end

    describe '#pin_set_trigger(pin, trigger)' do
      it 'should set to :low' do
        expect(subject).to receive(:gpio_event_low).with(4)
        expect(subject).to receive(:pin_clear_trigger).with(4)
        subject.pin_set_trigger(4, :low)
        expect(subject.instance_variable_get('@triggered_pins')).to include(4)
      end

      it 'should set to :high' do
        expect(subject).to receive(:pin_clear_trigger).with(5)
        expect(subject).to receive(:gpio_event_high).with(5)
        subject.pin_set_trigger(5, :high)
        expect(subject.instance_variable_get('@triggered_pins')).to include(5)
      end
      
      it 'should set to :rising' do
        expect(subject).to receive(:pin_clear_trigger).with(6)
        expect(subject).to receive(:gpio_event_rising).with(6)
        subject.pin_set_trigger(6, :rising)
        expect(subject.instance_variable_get('@triggered_pins')).to include(6)
      end
      
      it 'should set to :falling' do
        expect(subject).to receive(:pin_clear_trigger).with(7)
        expect(subject).to receive(:gpio_event_falling).with(7)
        subject.pin_set_trigger(7, :falling)
        expect(subject.instance_variable_get('@triggered_pins')).to include(7)
      end
      
      it 'should set to :both' do
        expect(subject).to receive(:pin_clear_trigger).with(8)
        expect(subject).to receive(:gpio_event_rising).with(8)
        expect(subject).to receive(:gpio_event_falling).with(8)
        subject.pin_set_trigger(8, :both)
        expect(subject.instance_variable_get('@triggered_pins')).to include(8)
      end
      
      it 'should set to :none' do
        expect(subject).to receive(:pin_clear_trigger).with(4)
        subject.pin_set_trigger(4, :none)
        expect(subject.instance_variable_get('@triggered_pins')).not_to include(4)
      end
      
      it 'should raise error' do
        expect { subject.pin_set_trigger(4, :risingfalling) }.to raise_error ArgumentError, 'trigger should be :none, :rising, :falling, :both, :high or :low'
      end
    end

    it '#pin_wait_for(pin)'
  end

  context 'API for Pwm' do
    it '#pwn_set_pin(pin)' do
      expect(subject).to receive(:gpio_select_function).with(12, 0b100)
      subject.pwm_set_pin(12)
      
      expect { subject.pwm_set_pin(11) }.to raise_error ArgumentError, 'pin should be one of [12, 13, 18, 19, 40, 41, 45, 52, 53]'
    end

    it'#pwm_set_clock(clock_value)' do
        expect(subject).to receive(:bcm2835_pwm_set_clock).with(1)
        subject.pwm_set_clock(1)
    end

    describe '#pwm_set_mode(pin, mode, start = 1)' do
      it 'should set to :balanced' do
        expect(subject).to receive(:bcm2835_pwm_set_mode).with(1, 0, 1)
        subject.pwm_set_mode(53, :balanced)
      end

      it 'should set to :markspace' do
        expect(subject).to receive(:bcm2835_pwm_set_mode).with(1, 1, 1)
        subject.pwm_set_mode(53, :markspace)
      end
      
      it 'should raise error' do
        expect { subject.pwm_set_mode(4, :balancedmarkspace) }.to raise_error ArgumentError, 'mode should be one of [:balanced, :markspace]'
      end

      it 'should start the signal'
      it 'should stop the signal'
    end

    it '#pwm_set_range(pin, range)' do
      expect(subject).to receive(:bcm2835_pwm_set_range).with(1, 100)
      subject.pwm_set_range(53, 100)
    end

    it '#pwm_set_data(pin, data)' do
      expect(subject).to receive(:bcm2835_pwm_set_data).with(1, 100)
      subject.pwm_set_data(53, 100)
    end
  end
  
  context 'API for Spi' do
    it '#spi_set_data_mode(mode)' do
      is_expected.to respond_to(:spi_set_data_mode).with(1).argument
    end

    it '#spi_begin' do
      is_expected.to respond_to(:spi_begin).with(0).argument
    end

    it '#spi_end' do
      is_expected.to respond_to(:spi_end).with(0).argument
    end

    it '#spidev_out(array)' do
      is_expected.to respond_to(:spidev_out).with(1).argument
    end

    it '#spi_clock(clock_divider)' do
      is_expected.to respond_to(:spi_clock).with(1).argument
    end

    it '#spi_bit_order(order)' do
      is_expected.to respond_to(:spi_bit_order).with(1).argument
    end

    it '#spi_chip_select(cs)' do
      is_expected.to respond_to(:spi_chip_select).with(1).argument
    end

    it '#spi_chip_select_polarity(cs, active)' do
      is_expected.to respond_to(:spi_chip_select_polarity).with(2).arguments
    end

    it '#spi_transfer(byte)' do
      is_expected.to respond_to(:spi_transfer).with(1).argument
    end

    it '#spi_transfer_bytes(data)' do
      is_expected.to respond_to(:spi_transfer_bytes).with(1).argument
    end
  end

  context 'API for I2C' do
    it '#i2c_begin' do
      is_expected.to respond_to(:i2c_begin).with(0).argument
    end

    it '#i2c_end' do
      is_expected.to respond_to(:i2c_end).with(0).argument
    end

    it '#i2c_allowed_clocks' do
      is_expected.to respond_to(:i2c_allowed_clocks).with(0).argument
    end

    it '#i2c_set_clock(clock)' do
      is_expected.to respond_to(:i2c_set_clock).with(1).argument
    end

    it '#i2c_set_address(address)' do
      is_expected.to respond_to(:i2c_set_address).with(1).argument
    end

    # it '#i2c_allowed_clocks'
    
    it '#i2c_transfer_bytes(data)' do
      is_expected.to respond_to(:i2c_transfer_bytes).with(1).argument
    end

    it '#i2c_read_bytes(bytes)' do
      is_expected.to respond_to(:i2c_read_bytes).with(1).argument
    end
  end
end
