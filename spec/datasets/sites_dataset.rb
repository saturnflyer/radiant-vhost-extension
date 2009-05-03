class SitesDataset < Dataset::Base
  uses :site_users
  
  def load
    # Needs to be test.host so the SiteScope works right
    create_record :site, :site_a, {:hostname => "test.host"}
    create_record :site, :site_b, {:hostname => "siteB.host"}
  end

end
