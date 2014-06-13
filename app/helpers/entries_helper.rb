module EntriesHelper

  def self.get_number_of_account_entries(categories)
    number_of_account_entries = 0
    categories.each do |category|
      number_of_account_entries +=
        CategoriesHelper.get_number_of_category_entries(category[:id])
    end
    number_of_account_entries
  end

  def self.get_last_entry(categories)
    category_entries = get_entries(categories)
    if !category_entries.empty?
      last_entry_date = category_entries.first[:entry_date]
      last_updated_date = category_entries.first[:updated_at].to_i
      last_entry_amount = 0
      category_entries.each do |entry|
        if entry[:entry_date] == last_entry_date && (entry[:updated_at].to_i ==
          last_updated_date || entry[:updated_at].to_i == last_updated_date - 1)
          last_entry_amount += entry[:entry_amount]
        else
          break;
        end
      end
      last_entry_date = last_entry_date.strftime("%B %-d, %Y")
    else
      last_entry_date = "No Entries"
      last_entry_amount = 0
    end
    [ last_entry_date, last_entry_amount ]
  end

  def self.get_entries(account_categories)
    category_ids = Array.new
    account_categories.each do |category|
      category_ids.push(category[:id])
    end
    category_entries = Entry.where("category_id IN (?)" , category_ids).order("entry_date DESC, updated_at DESC")
  end

  def self.get_consolidated_entries(user_id, account_name)
    account_categories = CategoriesHelper.get_categories(user_id, account_name) # TODO: need to get rid of duplication of get_entries above
    category_ids = Array.new
    account_categories.each do |category|
      category_ids.push(category[:id])
    end
    category_entries = Entry.where("category_id IN (?)" , category_ids).order("entry_date DESC, updated_at DESC")

    category_entries_date_set = Array.new
    consolidated_date_entries = Array.new

    category_name_id_mapping = CategoriesHelper.get_category_name_id_mapping(account_categories).sort

    for i in 0..(category_entries.size - 1)
      category_entries_date_set.push(category_entries[i])
      if i < category_entries.size - 1 && category_entries[i + 1][:entry_date] == category_entries[i][:entry_date] &&
        (category_entries[i + 1][:updated_at].to_i == category_entries[i][:updated_at].to_i ||
         category_entries[i + 1][:updated_at].to_i == category_entries[i][:updated_at].to_i + 1 ||
         category_entries[i + 1][:updated_at].to_i == category_entries[i][:updated_at].to_i - 1)
        next
      else
        compiled_date_entry = Array.new(category_ids.size + 2)
        j = nil
        category_entries_date_set.each do |entry|
          if j.nil?
            compiled_date_entry[0] = entry[:entry_date].strftime("%-m/%-d/%Y")
            j = !nil
          end
          category_id = entry[:category_id]
          for k in 0..(category_ids.size - 1)
            if category_id == category_name_id_mapping[k][1]
              compiled_date_entry[k + 1] = entry[:entry_amount]
            end
          end
        end
        consolidated_date_entries.push(compiled_date_entry)
        category_entries_date_set = Array.new
      end
    end

    consolidated_date_entries.each do |date_entry|
      date_entries_total = 0
      for i in 1..(category_ids.size)
        if !date_entry[i].nil?
          date_entries_total += date_entry[i]
        end
      end
      date_entry[category_ids.size + 1] = date_entries_total
    end

    consolidated_date_entries
  end

  def self.get_category_name_saved_amount_mapping(account_categories)
    category_name_saved_amount_map = {}
    account_categories.each do |category|
      category_name_saved_amount_map[category[:category_name]] =
        CategoriesHelper.get_category_entries_total(category[:id])
    end
    category_name_saved_amount_map.sort
  end

end
