class SitesSiteUsersDataset < Dataset::Base
  uses :site_users, :sites
  
  def load
    sites(:site_a).users << users(:user_a)
    sites(:site_b).users << users(:user_b)
    sites(:site_a).users << users(:developer_a)
    sites(:site_b).users << users(:developer_b)
    sites(:site_a).users << users(:admin_a)
    sites(:site_b).users << users(:admin_b)
  end

end
