require 'spec_helper'

describe PiPiper::Bcm2835::Driver do
  let(:driver) { PiPiper::Bcm2835::Driver }
  describe '#initialize' do
    it 'should run the setup attach_functions' do
      allow_any_instance_of(driver).to receive(:ffi_lib)
      allow_any_instance_of(driver).to receive(:attach_function)
      expect_any_instance_of(driver).to receive(:attach_function)

      driver.new
    end
  end
end
