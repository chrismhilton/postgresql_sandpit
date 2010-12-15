class Client < ActiveRecord::Base
  has_many :users
  
  accepts_nested_attributes_for :users
  
  validates_presence_of :subdomain
  
  validates_format_of :subdomain, 
                      :with => /^[A-Za-z0-9-]+$/, 
                      :message => ' can only contain alphanumeric characters and dashes.', 
                      :allow_blank => true

  validates_exclusion_of :subdomain, 
                         :in => %w( support blog www billing help api mail ), 
                         :message => " <strong>{{value}}</strong> is reserved and unavailable."
  
  validates_uniqueness_of :subdomain, :case_sensitive => false

  before_validation :downcase_subdomain
  
  private

  def downcase_subdomain
    self.subdomain.downcase! if attribute_present?("subdomain")
  end
end
