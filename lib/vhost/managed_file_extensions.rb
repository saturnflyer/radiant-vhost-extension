module Vhost::ManagedFileExtensions
 def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix]
    filename = case self.thumbnail
      when "thumb"
        File.join(RAILS_ROOT, file_system_path, current_site.id.to_s, 'thumbs', thumbnail_name_for(true))
      else
        File.join(RAILS_ROOT, file_system_path, current_site.id.to_s, thumbnail_name_for(false))
    end

    if thumbnail
      filename = File.join(RAILS_ROOT, file_system_path, current_site.id.to_s, 'thumbs', thumbnail_name_for(true))
    end
    
    filename
  end

end


