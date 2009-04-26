class SiteHomePagesDataset < Dataset::Base
  uses :sites

  def load
    create_page "Home A", :site_id => site_id(:site_a),
                        :slug => "/", :parent_id => nil,
                        :description => "The homepage A", 
                        :keywords => "Home, Page" do
      create_page_part "body", :content => "Hello A"
      create_page_part "sidebar", :content => "<r:title /> sidebar."
      create_page_part "extended", :content => "Just a test."
      create_page_part "titles", :content => "<r:title /> <r:page:title />"
    end
    create_page "Home B", :site_id => site_id(:site_b),
                        :slug => "/", :parent_id => nil,
                        :description => "The homepage B", 
                        :keywords => "Home, Page" do
      create_page_part "body", :content => "Hello B"
      create_page_part "sidebar", :content => "<r:title /> sidebar."
      create_page_part "extended", :content => "Just a test."
      create_page_part "titles", :content => "<r:title /> <r:page:title />"
    end
  end
  
  helpers do
    def create_page(name, attributes={})
      attributes = page_params(attributes.reverse_merge(:title => name))
      body = attributes.delete(:body) || name
      symbol = name.symbolize
      create_record :page, symbol, attributes
      if block_given?
        old_page_id = @current_page_id
        @current_page_id = page_id(symbol)
        yield
        @current_page_id = old_page_id
      end
      if pages(symbol).parts.empty?
        create_page_part "#{name}_body".symbolize, :name => "body", :content => body + ' body.', :page_id => page_id(symbol)
      end
    end
    def page_params(attributes={})
      title = attributes[:title] || unique_page_title
      attributes = {
        :title => title,
        :breadcrumb => title,
        :slug => title.symbolize.to_s.gsub("_", "-"),
        :class_name => nil,
        :status_id => Status[:published].id,
        :published_at => Time.now.to_s(:db)
      }.update(attributes)
      attributes[:parent_id] = @current_page_id unless attributes.has_key?(:parent_id)
      attributes
    end
    
    def create_page_part(name, attributes={})
      attributes = page_part_params(attributes.reverse_merge(:name => name))
      # Need to include the page_id here so we're creating new records for all sub-parts
      create_record :page_part, name.symbolize.to_s+@current_page_id.to_s, attributes
    end
    def page_part_params(attributes={})
      name = attributes[:name] || "unnamed"
      attributes = {
        :name => name,
        :content => name,
        :page_id => @current_page_id
      }.update(attributes)
    end
    
    private
      @@unique_page_title_call_count = 0
      def unique_page_title
        @@unique_page_title_call_count += 1
        "Page #{@@unique_page_title_call_count}"
      end
  end
end
