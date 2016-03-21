require 'spec_helper'

describe PiPiper::Bcm2835 do
  it 'has a version number' do
    expect(PiPiper::Bcm2835::VERSION).not_to be nil
  end

  describe '#driver' do
    let(:driver) { PiPiper::Bcm2835::Driver }
    it 'should return the Bcm2835 driver' do
      allow_any_instance_of(driver).to receive(:ffi_lib)
      allow_any_instance_of(driver).to receive(:attach_function)

      expect(PiPiper::Bcm2835.driver).to be_a(PiPiper::Bcm2835::Driver)
    end
  end
end
