Host multiple separate websites on the same Radiant installation each with their 
own users, pages, snippets and layouts (soon to be supporting other extensions).  
Administer users and sites from any domain using your administrative accounts 
and manage website content by logging into each domain.

## IMPORTANT NOTES ABOUT VHOST

* Not compatible with the multi_site extension
* Uses the scoped_access plugin, make sure none of your extensions have a 
  conflicting version of the plugin.
* Hooks into the Radiant 'bootstrap' functionality and currently overwrites the
  standard templates with a modified version of the Simple Blog (i.e. no Styled
  Blog or Coffee template)

## INSTALL INSTRUCTIONS

 The New way:

    gem install radiant-vhost-extension
    # add the following line to your config/environment.rb: config.gem 'radiant-vhost-extension', :lib => false
    rake radiant:extensions:update_all
    rake radiant:extensions:vhost:install

 The old way:

    git clone git://github.com/saturnflyer/radiant-vhost-extension.git vendor/extensions/vhost
    rake radiant:extensions:vhost:update
    rake radiant:extensions:vhost:migrate

## GETTING UP AND RUNNING QUICKLY

    rake radiant:extensions:vhost:apply_site_scoping
    rake radiant:extensions:vhost:add_default_site
    
  This scopes Page, Layout, and Snippet by default under a Site with a Hostname of "*".  
  
  User scoping is not performed.  The first user with 'admin' set is set to be a site_admin for the default site.

## VHOST SUPPORT FOR OTHER EXTENSIONS

Vhost support for other extensions is enabled by creating a /config/vhost.yml
file containing the names of the models that should be scoped down per site. If
site scoping for an extension cannot be specified through the model (i.e. it
uses the file system to present data or otherwise doesn't use an ActiveRecord)
then currently you cannot enable site scoping.

Example vhost.yml:

    models:
     # Class name
     ManagedFile: 
       # Property requiring definition of validates_uniqueness_of
       filename: 
         # Parameters to pass to validates_uniqueness_of
         scope: 
           - site_id
         message:
           'file name is already in use'
       # Any classes used in Single Table Inheritance(STI)
       sti_classes:
         - OneClass
         - TwoClass
