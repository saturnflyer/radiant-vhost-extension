class VirtualPage < Page
  def virtual?
    true
  end
end

class SitePagesDataset < Dataset::Base
  uses :site_home_pages, :sites
  
  def load
    create_page "Page A", :parent_id => page_id(:home_a), :site_id => site_id(:site_a) do
      create_page_part "body", :content => "PageA Body", :id => 1
    end
    create_page "Page B", :parent_id => page_id(:home_b), :site_id => site_id(:site_b) do
      create_page_part "body", :content => "PageB Body", :id => 2
    end
    
    create_page "Parent", :parent_id => page_id(:home_a), :site_id => site_id(:site_a) do
      create_page "Child", :site_id => site_id(:site_a) do
        create_page "Grandchild", :site_id => site_id(:site_a) do
          create_page "Great Grandchild", :site_id => site_id(:site_a)
        end
      end
      create_page "Child 2", :site_id => site_id(:site_a)
      create_page "Child 3", :site_id => site_id(:site_a)
    end

    end
  
end