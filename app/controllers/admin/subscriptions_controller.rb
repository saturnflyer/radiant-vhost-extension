class Admin::SubscriptionsController < ApplicationController
  skip_before_filter :authenticate, :authorize, :verify_authenticity_token, :only => :signup

  def signup
    resp = Hash.new

    if request.post?
      @subdomain = params[:subdomain]
      @name = params[:name]
      @emailpre = params[:emailpre]
      @emailpost = params[:emailpost]
      password = params[:password]
      email = "#{@emailpre}@#{@emailpost}"
      
      user = User.new(:login => @name, :email => email, :name => @name, :password => password, :password_confirmation => password, :admin => true)
      site =  Site.new(:title => @subdomain)
      hostname = Hostname.new(:domain => "#{@subdomain}.#{request.domain}")

      if user.valid? && hostname.valid? && site.valid?
        user.save!
        site.save!
        hostname.site = site
        hostname.save!

        site.users << user

        self.current_user = user
      elsif user.errors.length > 0
        resp[:error] = "Please check #{user.errors.first[0]}, #{user.errors.first[1]}"
      elsif hostname.errors.length > 0
        resp[:error] = "Please check #{hostname.errors.first[0]}, #{hostname.errors.first[1]}"        
      elsif site.errors.length > 0
        resp[:error] = "Please check #{site.errors.first[0]}, #{site.errors.first[1]}"
      else
        resp[:error] = "Unable to save your information, please try again"
      end
    end

    if self.current_user
      resp[:function] = "redirectUrl"
      resp[:url] = switch_to_admin_site_url(self.current_user.sites.first || current_site)
      render :xml => resp.to_xml(:root => "response")
    else
      resp[:function] = "displayError"
      render :xml => resp.to_xml(:root => "response")
    end
  end

end
