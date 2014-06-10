# Class for controlling actions related to "accounts" web page views
class AccountsController < ApplicationController
  
  # Method for handling get and post actions for accounts "create" web page
  def create
    if request.get? 
      if session[:current_user_id].nil?
        redirect_to users_signin_url
      end
    elsif request.post?
      user_id = session[:current_user_id]
      account_attributes = account_params
      if AccountsHelper.does_account_exist?(user_id, account_attributes[:account_name])
        flash[:alert] = "Account Name Already Exists!"
      else
        account_attributes[:user_id] = user_id
        account = Account.new(account_attributes)
        if account.valid?
          account.save
          session[:account_name] = account_attributes[:account_name]
          flash[:notice] = "Account Created Successfully!"
        else
          flash[:alert] = account.errors.first[1]
        end
      end
      redirect_to accounts_create_url
    end
  end
  
  def view
    if request.get?
      if !session[:current_user_id].nil?
        user_id = session[:current_user_id]
        @account_names = AccountsHelper.get_account_names user_id
        if !@account_names.nil?
          categories = CategoriesHelper.get_categories(user_id, session[:account_name])
          @account_total = 
            AccountsHelper.get_account_total(categories)           
          account_name = session[:account_name]
          @category_names = 
            CategoriesHelper.get_category_names user_id, account_name
          if @category_names.size > 0
            @category_name_id_mapping = CategoriesHelper.get_category_name_id_mapping user_id, account_name
            @category_name_savings_amount_mapping = Hash.new
            @category_names.each do |category_name|
              @category_name_savings_amount_mapping[category_name.to_sym] = 
                CategoriesHelper.get_category_entries_total @category_name_id_mapping[category_name]
            end
          else
            flash.now[:alert] = "No Categories for Selected Account!"
          end
        end
      end
    else request.post?
      if session[:account_name] != params[:account_name]
        session[:account_name] = params[:account_name]
      else
        if !params[:delete].nil?
          record_destroyed = Category.destroy params[:delete].keys.first
          if record_destroyed
            flash[:notice] = "Category Deleted Successfully!"
          end
        end
      end
      redirect_to accounts_view_url
    end
  end

  private

    # Method for retrieving accounts creation form data via strong parameters
    def account_params
      params.require(:account).permit(:account_name)
    end

end
