module VhostTags
  include Radiant::Taggable

  class TagError < StandardError; end

  desc %{
    Renders the title of the current site.
  }    
  tag 'site' do |tag|
    current_site.title
  end
  
end
