require 'spec_helper'

describe PiPiper::Bcm2835::Pin do
  let(:pin) { Class.new { extend PiPiper::Bcm2835::Pin } }

  before(:each) do
    allow(File).to receive(:write).with('/sys/class/gpio/export', 4)
    allow(File).to receive(:write).with('/sys/class/gpio/gpio4/direction', 'in')
  end

  describe '.pins' do
    it 'should instantiate an empty set' do
      expect(pin.pins).to be_a(Set)
      expect(pin.pins).to be_empty
    end

    it 'should return the exported pins' do
      pin.pin_input(4)
      expect(pin.pins).to contain_exactly(4)
    end
  end

  describe '.pin_input' do    
    it 'should export the pin in the `in` direction' do
      expect(pin).to receive(:export).with(4)      
      pin.pin_input(4)
    end

    it 'should keep state of exported pins' do
      pin.pin_input(4)
      expect(pin.pins).to contain_exactly(4)
    end

    it 'should raise an error if pin is exported already' do
      pin.pin_input(4)
      expect { pin.pin_input(4) }.to raise_error(ArgumentError)
    end
  end

  describe '.pin_set' do
    it 'should set the value of the pin' do
      expect(File).to receive(:write).with('/sys/class/gpio/gpio4/value', '1')
      pin.pin_set(4, '1')
    end
  end

  describe '.pin_output' do
    before(:each) do
      allow(File).to(
        receive(:write).with('/sys/class/gpio/gpio4/direction', 'out'))
    end
    
    it 'should export the pin in the `in` direction' do
      expect(pin).to receive(:export).with(4)      
      pin.pin_output(4)
    end

    it 'should keep state of exported pins' do
      pin.pin_output(4)
      expect(pin.pins).to contain_exactly(4)
    end

    it 'should raise an error if pin is exported already' do
      pin.pin_output(4)
      expect { pin.pin_output(4) }.to raise_error(ArgumentError)
    end
  end

  describe '.pin_read' do
    it 'should return the value of the pin read' do
      pin.pin_input(4)
      expect(File).to(
        receive(:read).with('/sys/class/gpio/gpio4/value').and_return(1))
      expect(pin.pin_read(4)).to eq(1)
    end

    it 'should raise an error if pin is not exported' do
      expect { pin.pin_read(4) }.to raise_error(ArgumentError)
    end
  end

  describe '.unexport' do
    it 'should unexport the pin' do
      expect(File).to receive(:write).with('/sys/class/gpio/unexport', 4)
      pin.pin_input(4)
      pin.unexport(4)
    end

    it 'should raise an error if pin is not exported' do
      expect { pin.unexport(4) }.to raise_error(ArgumentError)
    end
  end

  describe '.unexport_all' do
    it 'should unexport all the export pins' do
      allow(File).to receive(:write).with('/sys/class/gpio/export', 4)
      allow(File).to receive(:write).with('/sys/class/gpio/gpio4/direction', 'in')
      allow(File).to receive(:write).with('/sys/class/gpio/export', 5)
      allow(File).to receive(:write).with('/sys/class/gpio/gpio5/direction', 'in')
      
      expect(File).to receive(:write).with('/sys/class/gpio/unexport', 4)
      expect(File).to receive(:write).with('/sys/class/gpio/unexport', 5)

      pin.pin_input(4)
      pin.pin_input(5)

      pin.unexport_all
      expect(pin.pins).to be_empty
    end
  end

  describe '.exported?' do
    it 'should return true if the pin is exported' do
      pin.pin_input(4)
      expect(pin.exported?(4)).to be(true)
    end

    it 'should return false if the pin is not exported' do
      expect(pin.exported?(4)).to be(false)
    end
  end

  describe '.unexported?' do
    it 'should return true if the pin is not exported' do
      expect(pin.unexported?(4)).to be(true)
    end

    it 'should return false if the pin is exported' do
      pin.pin_input(4)
      expect(pin.unexported?(4)).to be(false)
    end
  end
end
