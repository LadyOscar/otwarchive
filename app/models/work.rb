class Work < ActiveRecord::Base
  has_many :chapters, :dependent => :destroy
  validates_associated :chapters, :message => nil

  has_one :metadata, :as => :described, :dependent => :destroy
  validates_presence_of :metadata
  validates_associated :metadata, :message => nil

  acts_as_commentable

  attr_reader :pseud 
  
  after_update :save_associated     
  
  #virtual attribute for metadata
  def new_metadata_attributes=(attributes)
    self.metadata = Metadata.new(attributes)
  end  
  
  def existing_metadata_attributes=(attributes)
    self.metadata.attributes = attributes
  end
  
  #virtual attribute for first chapter
  def new_chapter_attributes=(attributes)
    chapters.build(attributes)
  end 
  
  def existing_chapter_attributes=(attributes)
    chapters.first.attributes = attributes
  end 
  
  def save_associated
    self.metadata.save(false)
    chapters.first.save(false)
  end

  def number_of_chapters
     Chapter.maximum(:position, :conditions => ['work_id = ?', self.id])
  end

  # Change the position of multiple chapters when one is deleted or moved
  def adjust_chapters(position, method = "subtract")
    if method == "subtract"
      Chapter.update_all("position = (position - 1)", ["work_id = (?) AND position > (?)", self.id, position])
    elsif method == "add"
      Chapter.update_all("position = (position + 1)", ["work_id = (?) AND position > (?)", self.id, position])
    end
  end  

  # provide an interface to increment major version number
  def inc_major_version
    self.update_attribute(:major_version, self.major_version+1)
  end

  # provide an interface to increment minor version number
  def inc_minor_version
    self.update_attribute(:minor_version, self.minor_version+1)
  end
end
