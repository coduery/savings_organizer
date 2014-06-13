module AccountsHelper

  def self.get_account_id(user_id, account_name)
    user_account = get_user_account(user_id, account_name)
    if !user_account.empty?
      account = user_account.first
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

  def self.get_account_total(categories)
    account_total = 0
    categories.each do |category|
      account_total += CategoriesHelper.get_category_entries_total(category[:id])
    end
    account_total
  end

  def self.get_user_account(user_id, account_name)
    Account.where("user_id = ? AND account_name = ?", user_id, account_name)
  end

end
