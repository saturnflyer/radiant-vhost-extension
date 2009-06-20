module Vhost::PodcastEpisodeExtensions
 def full_filename(thumbnail = nil)
    file_system_path = self.attachment_options[:path_prefix]
    File.join(RAILS_ROOT, file_system_path, current_site.id.to_s, podcast.id.to_s, thumbnail_name_for)
  end
end
