module Vhost::FckeditorExtensions
  module Controller
    # Overwriting this method will tell all fckeditor instances exactly which
    # site they should scope down to.
    def current_directory_path
      # @todo this needs to be turned into the current_site.hostname but protect against the * hostname
      # or something else
      site_dir = "#{FckeditorController::UPLOADED_ROOT}/#{current_site.id}"
      Dir.mkdir(site_dir,0775) unless File.exists?(site_dir)
      base_dir = "#{FckeditorController::UPLOADED_ROOT}/#{current_site.id}/#{params[:Type]}"
      Dir.mkdir(base_dir,0775) unless File.exists?(base_dir)
      check_path("#{base_dir}#{params[:CurrentFolder]}")
    end
    def upload_directory_path
      uploaded = ActionController::Base.relative_url_root.to_s+"#{FckeditorController::UPLOADED}/#{current_site.id}/#{params[:Type]}" 
      "#{uploaded}#{params[:CurrentFolder]}"
    end
  end
end

