module Vhost::GalleryItemExtensions
  def self.included(base)
    base.class_eval {
      def full_filename(thumbnail = nil)
        file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:path_prefix].to_s
        gallery_folder = self.gallery ? self.gallery.id.to_s : self.parent.gallery.id.to_s
        site_folder = self.gallery && self.gallery.current_site ? self.gallery.current_site.id.to_s : nil
        File.join(RAILS_ROOT, file_system_path, site_folder, gallery_folder, *partitioned_path(thumbnail_name_for(thumbnail)))
      end

      has_attachment :storage => :file_system,
        :path_prefix => Radiant::Config["gallery.path_prefix"],
        :processor => Radiant::Config["gallery.processor"],
        :partition => false
    }
  end
end


