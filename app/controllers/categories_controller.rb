# Class for controlling actions related to "categories" web page views
class CategoriesController < ApplicationController

  # Method for handling get and post actions for categories "create" web page
  def create
    create_get(request) if request.get?
    create_post(request) if request.post?
  end

  def view
    view_get(request) if request.get?
    view_post(request) if request.post?
  end

  private

    # Method for retrieving category form data via strong parameters
    def category_params
      params.require(:category).permit(:account_name, :category_name, :savings_goal, :savings_goal_date)
    end

    def create_get(request)
      if !session[:current_user_id].nil?
        user_id = session[:current_user_id]
        @account_names = AccountsHelper.get_account_names user_id
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

    def create_post(request)
      user_id = session[:current_user_id]
      @account_names = AccountsHelper.get_account_names user_id
      category_attributes = category_params
      if category_attributes[:account_name] == session[:account_name]
        account = Account.find_by(account_name: session[:account_name], user_id: user_id )
        date_valid = CategoriesHelper.is_date_valid? category_attributes
        goal_entry_valid = CategoriesHelper.is_goal_entry_valid?(category_attributes, date_valid)

        if CategoriesHelper.does_category_exist?(user_id, account[:id], category_attributes[:category_name])
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
          else
            flash[:alert] = category.errors.first[1]
          end
        elsif date_valid
          session[:category_name_to_add] = category_attributes[:category_name]
          flash[:alert] = "Goal amount required with goal date!"
        end
      else
        session[:account_name] = category_attributes[:account_name]
      end
      redirect_to categories_create_url
    end

    def view_get(request)
      if !session[:current_user_id].nil?
        user_id = session[:current_user_id]
        @account_names = AccountsHelper.get_account_names user_id
        if !@account_names.nil?
          categories = CategoriesHelper.get_categories(user_id, session[:account_name])
          @category_names = CategoriesHelper.get_category_names categories
          if session[:category_name].nil?
            session[:category_name] = @category_names.first
          end
          if @category_names.size > 0
            category_id = CategoriesHelper.get_category_id(user_id, session[:account_name], session[:category_name])
            @category_entries = CategoriesHelper.get_category_entries category_id
            if @category_entries.size == 0
              flash.now[:alert] = "No Entries for Selected Category!"
            else
              @deduction_category_entries_total =
                CategoriesHelper.get_deduction_category_entries_total @category_entries
              @addition_category_entries_total =
                CategoriesHelper.get_addition_category_entries_total @category_entries
              @category_balance = @addition_category_entries_total + @deduction_category_entries_total
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

    def view_post(request)
      if session[:account_name] == params[:account_name] &&
         session[:category_name] == params[:category_name]
        if !params[:delete].nil?
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
      elsif session[:account_name] == params[:account_name]
        session[:category_name] = params[:category_name]
      else
        session[:account_name] = params[:account_name]
        session[:category_name] = nil
      end
      redirect_to categories_view_url
    end

    def flash_no_account_alert
      flash.now[:alert] = "No Accounts for User.  Must create at least one account!"
    end

end
