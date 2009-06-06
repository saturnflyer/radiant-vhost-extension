module Vhost::ManagedFileExtensions
 def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix]
    case self.thumbnail
      when "thumb"
        File.join(RAILS_ROOT, file_system_path, current_site.id.to_s, 'thumbs', self.filename)
      else
        File.join(RAILS_ROOT, file_system_path, current_site.id.to_s, self.filename)
    end
  end
end


