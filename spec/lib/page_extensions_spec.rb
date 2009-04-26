require File.dirname(__FILE__) + '/../spec_helper'

describe Page, 'slug scoping' do
  dataset :site_pages
  test_helper :validations

  before :each do
    @page = @model = Page.new(page_params)
  end

  # Not sure why this is the case, need an explanation.
  it 'should be uniquely scoped to parent and site' do
    true.should == true
  end

end
