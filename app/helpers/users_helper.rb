module UsersHelper
  
  def self.get_user_accounts_total(account_name_to_savings_amount_map)
    user_accounts_total = 0
    account_name_to_savings_amount_map.each do |account_name, savings_amount|
      user_accounts_total += savings_amount
    end
    user_accounts_total
  end
  
  def self.get_account_names_to_savings_amounts_map(user_id, account_names)
    account_names_to_savings_amounts = Hash.new
    account_names.each do |account_name|
      categories = CategoriesHelper.get_categories(user_id, account_name)
      account_names_to_savings_amounts[account_name.to_sym] = 
        AccountsHelper.get_account_total(categories)      
    end
    account_names_to_savings_amounts
  end
  
  def self.get_account_name_id_map(user_id, account_names)
    account_name_id_mapping = Hash.new
    account_names.each do |account_name|
      account_name_id_mapping[account_name] = 
        AccountsHelper.get_account_id(user_id, account_name)
    end
    account_name_id_mapping
  end
  
end
