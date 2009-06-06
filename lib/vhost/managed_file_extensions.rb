module Vhost::ManagedFileExtensions
 def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix]
    filename = case self.thumbnail
      when "thumb"
        File.join(RAILS_ROOT, file_system_path, current_site.id.to_s, 'thumbs', thumbnail_name_for)
      else
        File.join(RAILS_ROOT, file_system_path, current_site.id.to_s, thumbnail_name_for)
    end

    if thumbnail
      filename = File.join(RAILS_ROOT, file_system_path, current_site.id.to_s, 'thumbs', thumbnail_name_for)
    end
    
    filename
  end

  def thumbnail_name_for(thumbnail = nil, asset = nil)
    return self.filename;
  end

end


