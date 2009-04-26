class SitesDataset < Dataset::Base
  uses :site_users
  
  def load
    create_record :site, :site_a, {:hostname => "siteA.host"}
    create_record :site, :site_b, {:hostname => "siteB.host"}
  end

end
