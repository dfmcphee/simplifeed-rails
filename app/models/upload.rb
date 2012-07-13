class Upload < ActiveRecord::Base
  belongs_to :post
  attr_accessible :picture_content_type, :picture_file_name, :picture_file_size, :picture_update_at
  
  has_attached_file :image,
    :styles => {
      :thumb=> "100x100#",
      :small  => "300x300>",
      :large => "600x600>"
    }
  
  validates_attachment_presence :picture
  validates_attachment_size :picture, :less_than => 5.megabytes
  validates_attachment_content_type :picture, :content_type => [ 'image/jpeg', 'image/png', 'image/pjpeg' ]
end
