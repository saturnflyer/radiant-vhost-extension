class SiteHostnamesDataset < Dataset::Base
  uses :site_host_types, :sites
  def load
    create_model :hostname, :site_a_hostname, :domain => "test.host", :site_id => (find_id :site, :site_a) ,:host_type_id => (find_id :host_type, :facebook)
    create_model :hostname, :site_b_hostname, :domain => "siteb.foo42.com", :site_id => (find_id :site, :site_b), :host_type_id => (find_id :host_type, :facebook)
  end
end