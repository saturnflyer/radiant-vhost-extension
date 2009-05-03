require File.dirname(__FILE__) + '/../spec_helper'

describe Page, "site scope" do
  dataset :site_pages, :sites, :site_users
  test_helper :validations

  before :each do
    @page = @model = Page.new(page_params)
  end

  it 'should validate uniqueness of' do
    @page.parent = pages(:parent)
    # Need to manually set the site_id since we're not going through the controller stack
    @page.site_id = site_id(:site_a)
    @page.valid?
    @page.save
    puts "ERRORS: "+@page.errors.length.to_s
    assert_invalid :slug, 'slug already in use for child of parent', 'child', 'child-2', 'child-3'
    assert_valid :slug, 'child-4'
  end

end
