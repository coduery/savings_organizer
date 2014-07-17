module CategoriesHelper

  def self.are_revised_balances_valid?(category_id, entry_to_delete)
    category_entries = get_category_entries category_id
    category_running_total = 0
    category_entries.reverse.each do |category_entry|
      if category_entry != entry_to_delete
        category_running_total += category_entry[:entry_amount]
      end
      if entry_to_delete[:entry_amount] > 0 &&
         (category_entry[:entry_date] > entry_to_delete[:entry_date] ||
         (category_entry[:entry_date] == entry_to_delete[:entry_date] &&
         category_entry[:updated_at] > entry_to_delete[:updated_at])) &&
         category_running_total < 0
        return false
      end
    end
    return true
  end

  def self.does_category_exist?(user_id, account_id, category_name)
    if !account_id.nil?
      account_categories = Category.where("account_id = ? AND category_name = ?",
                                          account_id, category_name)
    else
      account_categories = []
    end
    !account_categories.empty?
  end

  def self.get_addition_category_entries_total(category_entries)
    addition_category_entries_total = 0
    category_entries.each do |category_entry|
      if category_entry[:entry_amount] > 0
        addition_category_entries_total += category_entry[:entry_amount]
      end
    end
    addition_category_entries_total
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

  def self.get_category_entries(category_id)
    category_entries = Entry.where("category_id = ?", category_id).order("entry_date DESC, updated_at DESC")
  end

  def self.get_category_entries_dates_cumulative_amounts(category_entries)
    category_entries = category_entries.reverse
    category_entries_date_cumulative_amounts = []
    category_entries_date_cumulative_amounts << ["Date", "Cumulative Amount"]
    cumulative_amount = 0
    category_entries.each do |entry|
      cumulative_amount += entry[:entry_amount]
      category_entries_date_cumulative_amounts << [entry[:entry_date].strftime("%-m/%-d/%Y"), cumulative_amount.round(2)]
    end
    category_entries_date_cumulative_amounts
  end

  def self.get_category_entries_prior_balance(category_entries, entry_date)
    category_entries_prior_balance = 0
    category_entries.each do |category_entry|
      if category_entry[:entry_date] <= entry_date
        category_entries_prior_balance += category_entry[:entry_amount]
      end
    end
    category_entries_prior_balance
  end

  def self.get_category_entries_total(category_id)
    category_entries = get_category_entries category_id
    category_entries_total = 0
    category_entries.each do |category_entry|
      category_entries_total += category_entry[:entry_amount]
    end
    category_entries_total.round(2)
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

  def self.get_category_name_id_mapping(account_categories)
    category_name_id_map = {}
    account_categories.each do |category|
      category_name_id_map[category[:category_name]] = category[:id]
    end
    category_name_id_map
  end

  def self.get_category_name_savings_amount_mapping(category_names, category_name_id_mapping)
    category_name_savings_amount_mapping = Hash.new
    category_names.each do |category_name|
      category_name_savings_amount_mapping[category_name.to_sym] =
        CategoriesHelper.get_category_entries_total(category_name_id_mapping[category_name])
    end
    category_name_savings_amount_mapping
  end

  def self.get_category_names(account_categories)
    category_names = Array.new
    account_categories.each do |category|
      category_names.push(category[:category_name])
    end
    category_names.sort!
  end

  def self.get_deduction_category_entries_total(category_entries)
    deduction_category_entries_total = 0
    category_entries.each do |category_entry|
      if category_entry[:entry_amount] < 0
        deduction_category_entries_total += category_entry[:entry_amount]
      end
    end
    deduction_category_entries_total
  end

  def self.get_number_of_category_entries(category_id)
    category_entries = get_category_entries(category_id)
    category_entries.size
  end

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

  def self.will_result_in_negative_future_balances?(category_entries, entry_to_deduct)
    category_running_total = 0
    category_entries.reverse.each do |category_entry|
      category_running_total += category_entry[:entry_amount]
      if entry_to_deduct[:entry_date] < category_entry[:entry_date] &&
         category_running_total + entry_to_deduct[:entry_amount] < 0
          return true
      end
    end
    return false
  end
end
