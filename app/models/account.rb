class Account < ActiveRecord::Base

  belongs_to :user
  has_many :categories, dependent: :destroy

  validates :account_name, 
    presence:   { message: "Account Name is Required!" },
    length:     { maximum: 25, too_long: "Account name too long.
                  Maximum %{count} characters allowed!" }

end
