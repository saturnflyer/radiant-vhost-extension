class Admin::PlansController < ApplicationController
  no_login_required
  skip_before_filter :verify_authenticity_token

  def gopro
    if request.post?
      
    end
    
  end

  def signup
    if request.post?
      @subdomain = params[:subdomain]
      @login = params[:login]
      password = params[:password]
      confirm = params[:password_confirmation]
      
      user = User.new(:login => @login, :name => @login, :password => password, :password_confirmation => confirm, :admin => true)
      site =  Site.new(:title => @subdomain)
      hostname = Hostname.new(:domain => "#{@subdomain}.kuviat.com")

      if user.valid? && site.valid? && hostname.valid?
        user.save!
        site.save!
        hostname.site = site
        hostname.save!

        site.users << user
        site.build_template!

        current_user = user
        redirect_to switch_to_admin_site_url(site)
      elsif user.errors.length > 0
        flash.now[:error] = "Please check #{user.errors.first[0]}, #{user.errors.first[1]}"
      elsif hostname.errors.length > 0
        flash.now[:error] = "Please check #{hostname.errors.first[0]}, #{hostname.errors.first[1]}"        
      elsif site.errors.length > 0
        flash.now[:error] = "Please check #{site.errors.first[0]}, #{site.errors.first[1]}"
      else
        flash.new[:error] = "Unable to save your information, please try again"
      end
    end
  end

end
