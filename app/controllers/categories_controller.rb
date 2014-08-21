# Class for controlling actions related to "categories" web page views
class CategoriesController < ApplicationController

  # Method for handling get and post actions for categories "create" web page
  def create
    create_get if request.get?
    create_post if request.post?
  end

  def view
    view_get if request.get?
    view_post if request.post?
  end

  private

    # Method for retrieving category form data via strong parameters
    def category_params
      params.require(:category).permit(:account_name, :category_name, :savings_goal, :savings_goal_date)
    end

    def create_get
      if !session[:current_user_id].nil?
        @account_names = AccountsHelper.get_account_names session[:current_user_id]
        if @account_names.nil?
          flash_no_account_alert
        else
          @category_name = session[:category_name_to_add]
          session[:category_name_to_add] = nil
        end
      else
        redirect_to users_signin_url
      end
    end

    def create_post
      category_attributes = category_params
      if category_attributes[:account_name] == session[:account_name]
        account = Account.find_by(account_name: session[:account_name], user_id: session[:current_user_id] )
        date_valid = CategoriesHelper.is_date_valid? category_attributes
        goal_entry_valid = CategoriesHelper.is_goal_entry_valid?(category_attributes, date_valid)

        if CategoriesHelper.does_category_exist?(session[:current_user_id], account[:id], category_attributes[:category_name])
          flash[:alert] = "Category Name Already Exists!"
        elsif goal_entry_valid
          if date_valid
            savings_goal_date = Date.civil(category_attributes["savings_goal_date(1i)"].to_i,
                                           category_attributes["savings_goal_date(2i)"].to_i,
                                           category_attributes["savings_goal_date(3i)"].to_i)
          end
          category = Category.new(:category_name     => category_attributes[:category_name],
                                  :savings_goal      => category_attributes[:savings_goal],
                                  :savings_goal_date => savings_goal_date,
                                  :account_id        => account[:id])
          if category.valid?
            category.save
            flash[:notice] = "Category Created Successfully!"
            session[:category_name] = category_attributes[:category_name]
          else
            flash[:alert] = category.errors.first[1]
          end
        elsif date_valid
          session[:category_name_to_add] = category_attributes[:category_name]
          flash[:alert] = "Goal amount required with goal date!"
        end
      else
        session[:account_name] = category_attributes[:account_name]
        session[:category_name] = nil
      end
      redirect_to categories_create_url
    end

    def delete_entry
      entry_to_delete = Entry.find(params[:delete].keys.first)
      category_id = entry_to_delete[:category_id]
      valid_deletion = CategoriesHelper.are_revised_balances_valid?(category_id, entry_to_delete)
      if valid_deletion
        rows_deleted = Entry.delete(params[:delete].keys.first)
        if rows_deleted == 1
          flash[:notice] = "Entry deleted successfully!"
        end
      else
        flash[:alert] = "Invalid entry deletion!<br>
                        Deletion would result in a negative
                        balance in savings history.".html_safe
      end
    end

    def flash_no_account_alert
      flash.now[:alert] = "No Accounts for User.  Must create at least one account!"
    end

    def invalid_update_alert
      flash[:alert] = "Invalid updated amount for specified date!<br>
                      Amount would result in a negative balance in
                      savings history.".html_safe
    end

    def update_entry # TODO: This is a really long and complicated method that needs to be broken up into smaller methods
      entry_id = params["save-update".to_sym].keys.first.to_i
      entry = EntriesHelper.get_entry_with_id entry_id
      original_entry_date = entry[:entry_date]
      original_entry_amount = entry[:entry_amount]
      update_entry_date = false
      update_deduction_entry = false
      update_addition_entry = false
      updated_entry_ok = false

      if !params[:entry][:entry_date].nil? && entry[:entry_date].strftime("%-m/%-d/%Y") != params[:entry][:entry_date]
        begin
          date_array = params[:entry][:entry_date].split('/')
          entry_date = Date.civil(date_array[2].to_i, date_array[0].to_i,
                                  date_array[1].to_i)
        rescue ArgumentError # TODO: replace with date validator, see validates_timeliness gem
          entry_date = nil
          flash[:alert] = "Invalid Entry Date Entered!"
        end
        if flash[:alert].nil?
          entry[:entry_date] = entry_date
          update_entry_date = true
        end
      end

      if entry[:entry_amount] < 0 && params[:entry][:entry_amount].to_f <= 0
        flash[:alert] = "Deduction amount cannot be blank and must be a positive number!"
      elsif entry[:entry_amount] < 0 && entry[:entry_amount] != -params[:entry][:entry_amount].to_f
        entry[:entry_amount] = -params[:entry][:entry_amount].to_f
        update_deduction_entry = true
      elsif entry[:entry_amount] > 0 && params[:entry][:entry_amount].to_f <= 0
        flash[:alert] = "Addition amount cannot be blank and must be a positive number!"
      elsif entry[:entry_amount] > 0 && entry[:entry_amount] != params[:entry][:entry_amount].to_f
        entry[:entry_amount] = params[:entry][:entry_amount].to_f
        update_addition_entry = true
      end

      if flash[:alert].nil?
        if update_entry_date || update_deduction_entry || update_addition_entry
          category_entries = CategoriesHelper.get_category_entries entry[:category_id]
          if original_entry_amount < 0
            if !update_entry_date && update_deduction_entry
              if params[:entry][:entry_amount].to_f > -original_entry_amount
                category_entries_prior_balance =
                  CategoriesHelper.get_category_entries_prior_balance(category_entries, entry[:entry_date])
                  difference_entry =
                    Entry.new(:entry_date => entry[:entry_date],
                              :entry_amount => -(params[:entry][:entry_amount].to_f + original_entry_amount))
                if category_entries_prior_balance - original_entry_amount >= params[:entry][:entry_amount].to_f &&
                  !CategoriesHelper.will_result_in_negative_future_balances?(category_entries, difference_entry)
                  updated_entry_ok = true
                else
                  invalid_update_alert
                end
              else
                updated_entry_ok = true
              end
            elsif update_entry_date && !update_deduction_entry
              if params[:entry][:entry_date] < original_entry_date.strftime("%-m/%-d/%Y")
                category_entries_prior_balance =
                  CategoriesHelper.get_category_entries_prior_balance(category_entries, entry[:entry_date])
                if category_entries_prior_balance + entry[:entry_amount] >= 0
                  updated_entry_ok = true
                else
                  invalid_update_alert
                end
              else
                updated_entry_ok = true
              end
            elsif update_entry_date && update_deduction_entry
              if params[:entry][:entry_date] < original_entry_date.strftime("%-m/%-d/%Y")
                category_entries_prior_balance =
                  CategoriesHelper.get_category_entries_prior_balance(category_entries, entry[:entry_date])
                deduction_new_date_amount_valid = CategoriesHelper.is_entry_new_date_amount_valid?(category_entries, entry_id, entry)
                if category_entries_prior_balance + entry[:entry_amount] >= 0 && deduction_new_date_amount_valid
                  updated_entry_ok = true
                else
                  invalid_update_alert
                end
              elsif params[:entry][:entry_date] > original_entry_date.strftime("%-m/%-d/%Y")
                category_entries_prior_balance =
                  CategoriesHelper.get_category_entries_prior_balance(category_entries, entry[:entry_date])
                  deduction_new_date_amount_valid = CategoriesHelper.is_entry_new_date_amount_valid?(category_entries, entry_id, entry)
                if category_entries_prior_balance  - original_entry_amount + entry[:entry_amount] >= 0 && deduction_new_date_amount_valid
                  updated_entry_ok = true
                else
                  invalid_update_alert
                end
              end
            end
          elsif original_entry_amount > 0
            if !update_entry_date && update_addition_entry
              if params[:entry][:entry_amount].to_f < original_entry_amount
                difference_entry =
                  Entry.new(:entry_date => entry[:entry_date],
                            :entry_amount => params[:entry][:entry_amount].to_f - original_entry_amount)
                if !CategoriesHelper.will_result_in_negative_future_balances?(category_entries, difference_entry)
                  updated_entry_ok = true
                else
                  invalid_update_alert
                end
              else
                updated_entry_ok = true
              end
            elsif update_entry_date && !update_addition_entry
              if params[:entry][:entry_date] > original_entry_date.strftime("%-m/%-d/%Y")
                category_entries_prior_balance =
                  CategoriesHelper.get_category_entries_prior_balance(category_entries, entry[:entry_date])
                if category_entries_prior_balance - original_entry_amount < 0
                  invalid_update_alert
                else
                  updated_entry_ok = true
                end
              else
                updated_entry_ok = true
              end
            elsif update_entry_date && update_addition_entry
              if params[:entry][:entry_date] < original_entry_date.strftime("%-m/%-d/%Y")
                if params[:entry][:entry_amount].to_f < original_entry_amount
                  addition_new_date_amount_valid = CategoriesHelper.is_entry_new_date_amount_valid?(category_entries, entry_id, entry)
                  if addition_new_date_amount_valid
                    updated_entry_ok = true
                  else
                    invalid_update_alert
                  end
                else
                  updated_entry_ok = true
                end
              elsif params[:entry][:entry_date] > original_entry_date.strftime("%-m/%-d/%Y")
                if params[:entry][:entry_amount].to_f < original_entry_amount
                  addition_new_date_amount_valid = CategoriesHelper.is_entry_new_date_amount_valid?(category_entries, entry_id, entry)
                  if CategoriesHelper.is_previous_entry_history_still_valid?(category_entries, entry_id, entry) && addition_new_date_amount_valid
                    updated_entry_ok = true
                  else
                    invalid_update_alert
                  end
                elsif params[:entry][:entry_amount].to_f > original_entry_amount
                  if CategoriesHelper.is_previous_entry_history_still_valid?(category_entries, entry_id, entry)
                    updated_entry_ok = true
                  else
                    invalid_update_alert
                  end
                end
              end
            end
          end

          if updated_entry_ok
            entry.save
            flash[:notice] = "Entry Updated Successfully!"
          end
        else
          flash[:alert] = "Entry Parameters Unchanged. Entry Not Updated!"
        end
      end
    end

    def view_get
      if !session[:current_user_id].nil?
        @account_names = AccountsHelper.get_account_names session[:current_user_id]
        if !@account_names.nil?
          categories = CategoriesHelper.get_categories(session[:current_user_id], session[:account_name])
          @category_names = CategoriesHelper.get_category_names categories
          if session[:category_name].nil?
            session[:category_name] = @category_names.first
          end
          if @category_names.size > 0
            @category = CategoriesHelper.get_category(session[:current_user_id], session[:account_name], session[:category_name])
            @category_entries = CategoriesHelper.get_category_entries @category[:id]
            if @category_entries.size == 0
              flash.now[:alert] = "No Entries for Selected Category!"
            else
              @category_entry_ids = CategoriesHelper.get_category_entry_ids @category_entries
              @deduction_category_entries_total =
                CategoriesHelper.get_deduction_category_entries_total @category_entries
              @addition_category_entries_total =
                CategoriesHelper.get_addition_category_entries_total @category_entries
              @category_balance = @addition_category_entries_total + @deduction_category_entries_total
              @category_entries_dates_cumulative_amounts =
                CategoriesHelper.get_category_entries_dates_cumulative_amounts @category_entries
              if !@category[:savings_goal].nil?
                @goal_percentage = (@category_balance / @category[:savings_goal]) * 100
              end
            end
          else
            flash.now[:alert] = "No Categories for Selected Account!"
          end
        else
          flash_no_account_alert
        end
      else
        redirect_to users_signin_url
      end
    end

    def view_post
      if !params[:account_name].nil? && session[:account_name] != params[:account_name]
        session[:account_name] = params[:account_name]
        session[:category_name] = nil
      elsif !params[:category_name].nil? && session[:category_name] != params[:category_name]
        session[:category_name] = params[:category_name]
      elsif !params["save-update".to_sym].nil?
        update_entry
      elsif !params[:delete].nil?
        delete_entry
      end
      redirect_to categories_view_url
    end

end
