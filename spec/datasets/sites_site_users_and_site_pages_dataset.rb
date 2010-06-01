class SitesSiteUsersAndSitePagesDataset < Dataset::Base
  uses :site_pages, :sites_site_users
  
  def load
    Page.update_all "created_by_id = #{user_id(:usera)}, updated_by_id = #{user_id(:usera)}", "id = '#{page_id(:page_a)}'"
    Page.update_all "created_by_id = #{user_id(:userb)}, updated_by_id = #{user_id(:userb)}", "id = '#{page_id(:page_b)}'"
  end
end