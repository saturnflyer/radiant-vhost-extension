class SitesDataset < Dataset::Base

  def load
    # Needs to be test.host so the SiteScope works right
    create_model :site, :site_a, :title => "site a"
    create_model :site, :site_b, :title => "site b"
  end

end
