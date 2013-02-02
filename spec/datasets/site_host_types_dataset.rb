class SiteHostTypesDataset < Dataset::Base
  def load
    create_model :host_type, :facebook, :host_type => "facebook",:unique => true
    create_model :host_type, :alias, :host_type => "alias",:unique => false
    create_model :host_type, :canonical, :host_type => "canonical",:unique => true
  end
end