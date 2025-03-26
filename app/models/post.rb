class Post < ApplicationRecord
  # Arrays for attachments using JSON serialization
  serialize :attachment_urls, coder: JSON
  serialize :attachment_names, coder: JSON

  # Validations
  validates :title, presence: true
  validates :cid, presence: true, uniqueness: true
  validates :gid, presence: true
  validates :bid, presence: true
  
  # Ensure boolean value for is_notice
  before_save :set_default_values
  
  private
  
  def set_default_values
    self.is_notice = false if is_notice.nil?
    self.scraped_at ||= Time.current
    self.attachment_urls ||= []
    self.attachment_names ||= []
  end
end
