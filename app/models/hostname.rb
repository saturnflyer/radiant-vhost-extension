class Hostname < ActiveRecord::Base
  belongs_to :site

  validates_each :domain do |record, attr, value|
    good_so_far = !value.nil?
    if good_so_far && value != "*"
      value.split('.').each do |addr|
        good_so_far = addr =~ /^[a-z0-9-]+$/i
        break unless good_so_far
      end    
    end
    record.errors.add attr, 'this is not a valid domain name' unless good_so_far
  end

  validates_presence_of :domain
  validates_uniqueness_of :domain

  def domain_wildcard?
    domain == "*"
  end
end
