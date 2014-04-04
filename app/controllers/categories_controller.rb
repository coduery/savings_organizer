# Class for controlling actions related to "categories" web page views
class CategoriesController < ApplicationController

  # Method for handling get and post actions for categories "create" web page
  def create
    if request.get?
      if !session[:current_user_id].nil?
        user_id = session[:current_user_id]
        @account_names = AccountsHelper.get_account_names user_id
        if @account_names.index("No Accounts")
          flash_no_account_alert
        else
          @category_name = nil
        end
      else
        redirect_to users_signin_url
      end
    elsif request.post?
      user_id = session[:current_user_id]
      @account_names = AccountsHelper.get_account_names user_id
      category_attributes = category_params
      if category_attributes[:account_name] == session[:account_name]
        account = Account.find_by(account_name: session[:account_name], user_id: user_id )
        date_valid = CategoriesHelper.is_date_valid? category_attributes
        goal_entry_valid = CategoriesHelper.is_goal_entry_valid?(category_attributes, date_valid)

        if !account
          flash.now[:alert] = "Savings account must be created prior to adding a category!"
        elsif CategoriesHelper.does_category_exist?(user_id, session[:account_name], category_attributes[:category_name])
          flash.now[:alert] = "Category Name Already Exists!"
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
            flash.now[:notice] = "Category Created Successfully!"
          else
            flash.now[:alert] = category.errors.first[1]
          end
        elsif date_valid
          @category_name = category_attributes[:category_name]
          flash.now[:alert] = "Goal amount required with goal date!"
        end
      else
        session[:account_name] = category_attributes[:account_name]
      end
    end    
  end

  private

    # Method for retrieving category form data via strong parameters
    def category_params
      params.require(:category).permit(:account_name, :category_name, :savings_goal, :savings_goal_date)
    end

    def flash_no_account_alert
      flash.now[:alert] = "No Accounts for User.  Must create at least one account!"
    end

end
