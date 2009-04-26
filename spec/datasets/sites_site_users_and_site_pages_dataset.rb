class SitesSiteUsersAndSitePagesDataset < Dataset::Base
  uses :site_pages, :sites_site_users
  
  def load
    Page.update_all "created_by_id = #{user_id(:user_a)}, updated_by_id = #{user_id(:user_a)}", "id = '#{page_id(:page_a)}'"
    Page.update_all "created_by_id = #{user_id(:user_b)}, updated_by_id = #{user_id(:user_b)}", "id = '#{page_id(:page_b)}'"
  end
end