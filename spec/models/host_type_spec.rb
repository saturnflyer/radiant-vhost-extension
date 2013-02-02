require File.dirname(__FILE__) + '/../spec_helper'

describe HostType do
  before(:each) do
    @host_type = HostType.new
  end

  it "should be valid" do
    @host_type.should be_valid
  end
end
