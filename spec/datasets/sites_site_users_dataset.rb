class SitesSiteUsersDataset < Dataset::Base
  uses :site_users, :sites
  
  def load
    sites(:site_a).users << users(:usera)
    sites(:site_b).users << users(:userb)
    sites(:site_a).users << users(:developera)
    sites(:site_b).users << users(:developerb)
    sites(:site_a).users << users(:admina)
    sites(:site_b).users << users(:adminb)
  end

end
