require 'spec_helper'

describe PiPiper::Bcm2835::SPI do
  let(:spi) { Class.new { extend PiPiper::Bcm2835::SPI } }

  describe '.setup_spi' do
    it 'should run the :attach_function through ffi' do
      expect(spi).to receive(:attach_function).exactly(9).times
      spi.setup_spi
    end
  end

  describe '.spidev_out' do
    it 'should write to spidev' do
      expect(File).to receive(:open).with('/dev/spidev0.0', 'wb')
      spi.spidev_out([1, 2, 3])
    end
  end

  describe '.spi_transfer_bytes' do
    it 'should transfer bytes through spi interface' do
      expect(spi).to(
        receive(:spi_transfernb).with(instance_of(FFI::MemoryPointer),
                                      instance_of(FFI::MemoryPointer),
                                      instance_of(Fixnum)))
      spi.spi_transfer_bytes([0x0, 0x1, 0x2])
    end
  end

end
