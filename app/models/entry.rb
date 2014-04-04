class Entry < ActiveRecord::Base

  belongs_to :category

  validates :entry_amount, numericality: true

end
