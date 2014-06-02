# Class for controlling actions related to "users" web page views
class UsersController < ApplicationController

  # Method for handling get and post actions for "signin" web page
  def signin
    if request.get?
      session[:current_user_id] = nil
    elsif request.post?
      session[:username] = params[:username]
      username = params[:username].downcase
      user = User.find_by user_name: "#{username}"
      if user && user.authenticate(params[:password])
        flash[:notice] = "Sign in successful."
        session[:current_user_id] = user[:id]
        account_names = AccountsHelper.get_account_names(user[:id])
        if !account_names.nil?
          session[:account_name] = account_names.first
        end
        redirect_to users_welcome_url
      else
        flash[:alert] = "Credentials Invalid. Please try again!"
        session[:current_user_id] = nil
        redirect_to root_url
      end
    end
  end

  # Method for handling get and post actions for "registration" web page
  def registration
  	if request.post?
      user = User.new(user_params)
      if user.valid?
        user.save
        flash[:notice] = "Registration Successful. Please Sign In!"
        redirect_to root_url
      else
        flash[:alert] = user.errors.first[1]
        redirect_to users_registration_url
      end
  	end	
  end

  # Method for handling get and post actions for "welcome" web page
  def welcome
    if request.get? || request.post?
      if !session[:current_user_id].nil?
        user_id = session[:current_user_id]
        @user_name = session[:username]
        @account_names = AccountsHelper.get_account_names user_id
        account_name = get_account_name
        @account_total = 
          AccountsHelper.get_account_total(user_id, account_name)
        @number_of_categories = 
          CategoriesHelper.get_categories(user_id, account_name).size
        @number_of_entries = 
          EntriesHelper.get_number_of_entries(user_id, account_name)
        last_entry = EntriesHelper.get_last_entry(user_id, account_name)
        @last_entry_date = last_entry[0]
        @last_entry_amount = last_entry[1]
        @category_saved_amount_array = EntriesHelper
          .get_category_name_saved_amount_mapping(user_id, account_name)
        if request.post? 
          redirect_to users_welcome_url
        end
      else
        redirect_to users_signin_url
      end
    end
  end
  
  def view
    get_view(request) if request.get?
    post_view(request) if request.post?
  end
  
  def manage
    get_manage(request) if request.get?
    post_manage(request) if request.post?
  end

  private

    # Method for retrieving registration form data via strong parameters
    def user_params
      params.require(:user).permit(:user_name, :password, 
                                   :password_confirmation, :user_email)
    end
    
    # Method for getting the current account name
    def get_account_name
      if session[:account_name].nil? && request.get? && !@account_names.nil?
        account_name = @account_names.first
      elsif request.get?
        account_name = session[:account_name]
      elsif request.post?
        session[:account_name] = params[:account_name]
        account_name = params[:account_name]        
      end
    end
    
    def get_view(request)
      if !session[:current_user_id].nil?
        user_id = session[:current_user_id]
        @account_names = AccountsHelper.get_account_names(user_id)
        if !@account_names.nil?
          @account_name_to_savings_amount_map = 
            UsersHelper.map_account_names_to_savings_amounts(user_id, @account_names)
          @user_accounts_total = 
            UsersHelper.get_user_accounts_total(@account_name_to_savings_amount_map)
          @account_name_id_map = UsersHelper.get_account_name_id_map(user_id, @account_names)
        else
          flash.now[:alert] = "No Accounts for User!"
        end
      else
        redirect_to users_signin_url
      end
    end
    
    def post_view(request)
      if !params[:delete].nil?
        record_destroyed = Account.destroy(params[:delete].keys.first)
        if record_destroyed
          flash[:notice] = "Account Deleted Successfully!"
        end
      end
      redirect_to users_view_url
    end   
    
    def get_manage(request)
      if session[:current_user_id].nil?
        redirect_to users_signin_url
      end
    end
    
    def post_manage(request)
      if !params[:delete].nil?
        username = params[:username].downcase
        user = User.find_by user_name: "#{username}"      
        if user && user[:id] == params[:delete].keys.first.to_i && user.authenticate(params[:password])
          record_destroyed = User.destroy(user[:id]);
          if record_destroyed
            flash[:notice] = "User Account Deleted Successfully!"
          end
          redirect_to users_signin_url
        else
          flash.now[:alert] = "Invalid user credentials.  Unable to delete user account.  Try again."
        end
      end
    end

end
