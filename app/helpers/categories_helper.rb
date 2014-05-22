module CategoriesHelper

  def self.is_date_valid?(params)
    !(params["savings_goal_date(1i)"]).blank? &&
    !(params["savings_goal_date(2i)"]).blank? &&
    !(params["savings_goal_date(3i)"]).blank?
  end

  def self.is_goal_entry_valid?(params, date_valid)
    (params[:savings_goal].blank? && !date_valid) ||
    (!params[:savings_goal].blank? && date_valid) ||
    (!params[:savings_goal].blank? && !date_valid)
  end

  def self.does_category_exist?(user_id, account_name, category_name)
    account_id = AccountsHelper.get_account_id(user_id, account_name)
    if !account_id.nil?
      account_categories = Category.where("account_id = ? AND category_name = ?",
                                          account_id, category_name)
    else
      account_categories = []
    end
    !account_categories.empty?
  end

  def self.get_categories(user_id, account_name)
    account_id = AccountsHelper.get_account_id(user_id, account_name)
    if !account_id.nil?
      account_categories = Category.where("account_id = ?", account_id)
    else
      account_categories = []
    end
    account_categories.sort!
  end

  def self.get_category_names(user_id, account_name)
    account_id = AccountsHelper.get_account_id(user_id, account_name)
    category_names = Array.new
    if !account_id.nil?
      account_categories = Category.where("account_id = ?", account_id)
      account_categories.each do |category|
        category_names.push(category[:category_name])
      end
    end
    category_names.sort!
  end

  def self.get_category_id(user_id, account_name, category_name)
    account_id = AccountsHelper.get_account_id(user_id, account_name)
    account_categories = Category.where("account_id = ? AND category_name = ?",
                                         account_id, category_name)
    category_id = nil
    if !account_categories.empty?
      account_category = account_categories.first
      category_id = account_category[:id]
    end
    category_id
  end

  def self.get_category_entries_total(category_id)
    category_entries = get_category_entries category_id
    category_entries_total = 0
    category_entries.each do |category_entry|
      category_entries_total += category_entry[:entry_amount]
    end
    category_entries_total
  end

  def self.get_number_of_entries(category_id)
    category_entries = get_category_entries category_id
    category_entries.size
  end
  
  def self.get_category_entries(category_id)
    category_entries = Entry.where("category_id = ?", category_id).order("entry_date DESC, created_at DESC")
  end

end
