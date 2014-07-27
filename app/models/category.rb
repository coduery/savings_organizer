class Category < ActiveRecord::Base

  belongs_to :account
  has_many :entries, dependent: :destroy

  validates :category_name,
    presence: { message: "Category Name is Required!" },
    length:     { maximum: 25, too_long: "Category name too long.
                  Maximum %{count} characters allowed!" }

  SAVINGS_GOAL_REGEX_VALIDATION_PATTERN = /\A\d+\.?\d{0,2}\z/

  validates :savings_goal, allow_blank: true, numericality: { greater_than: 0,
    message: "Invalid dollar amount! Dollar amount must be greater than zero!" },
    format:  { with: SAVINGS_GOAL_REGEX_VALIDATION_PATTERN, message: "Number Entry Invalid. Cannot be more than 2 decimal points!" }

  validates :account_id, presence: true

end
