require 'spec_helper'

describe PiPiper::Bcm2835::I2C do
  let(:i2c) { Class.new { extend PiPiper::Bcm2835::I2C } }

  describe '.setup_i2c' do
    it 'should run the :attach_function through ffi' do
      expect(i2c).to receive(:attach_function).exactly(6).times
      i2c.setup_i2c
    end
  end

  describe '.i2c_allowed_clocks' do
    it 'should return the allowed clock rates' do
      expect(i2c.i2c_allowed_clocks).to be_a(Array)
    end
  end

  describe '.i2c_transfer_bytes' do
    it 'should write bytes via i2c' do
      allow(i2c).to receive(:i2c_write)
      i2c.i2c_transfer_bytes([1, 2, 3, 4])
    end
  end

  describe '.i2c_read_bytes' do
    it 'should read the bytes through i2c' do
      allow(i2c).to receive(:i2c_read)
      # read 4 bytes
      expect(i2c.i2c_read_bytes(0x4)).to eq([0, 0, 0, 0])
    end
  end
end
