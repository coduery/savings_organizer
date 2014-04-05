module AccountsHelper

  def self.get_account_id(user_id, account_name)
    user_accounts = Account.where("user_id = ? AND account_name = ?", 
                                   user_id, account_name)
    if !user_accounts.empty?
      account = user_accounts.first
      account_id = account[:id]
    else
      account_id = nil
    end
  end

  def self.get_account_names(user_id)
    account_names = Array.new
    user_accounts = Account.where("user_id = ?", user_id)

    if !user_accounts.empty?
      user_accounts.each do |account|
        account_names.push(account[:account_name])
      end       
      account_names.sort!
    end
  end

  def self.does_account_exist?(user_id, account_name)
    user_accounts = Account.where("user_id = ? AND account_name = ?", 
                                   user_id, account_name)
    !user_accounts.empty?
  end

  def self.get_account_total(user_id, account_name)
    account_categories = CategoriesHelper.get_categories(user_id, account_name)
    account_total = 0
    account_id = get_account_id(user_id, account_name)
    account_categories.each do |category|
      account_total += CategoriesHelper.get_category_entries_total(category[:id])
    end
    account_total
  end

end
