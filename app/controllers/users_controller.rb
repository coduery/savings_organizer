# Class for controlling actions related to "users" web page views
class UsersController < ApplicationController

  # Method for handling get and post actions for "users/manage" web page    
  def manage
    manage_get(request) if request.get?
    manage_post(request) if request.post?
  end
  
  # Method for handling get and post actions for "users/registration" web page
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
  
  # Method for handling get and post actions for "users/signin" web page
  def signin
    signin_get(request) if request.get?
    signin_post(request) if request.post?
  end

  # Method for handling get and post actions for "users/view" web page
  def view
    view_get(request) if request.get?
    view_post(request) if request.post?
  end
  
  # Method for handling get and post actions for "users/welcome" web page
  def welcome
    welcome_get(request) if request.get?
    welcome_post(request) if request.post?    
  end 

  private

    def find_user
      user_name = params[:user_name].downcase
      User.find_by user_name: "#{user_name}" 
    end
    
    def manage_get(request)
      if session[:current_user_id].nil?
        redirect_to users_signin_url
      end
    end
    
    def manage_post(request)
      if !params[:delete].nil?
        user = find_user     
        if user && user[:id] == params[:delete].keys.first.to_i && 
                   user.authenticate(params[:password])
          record_destroyed = User.destroy(user[:id])
          if record_destroyed
            flash[:notice] = "User Account Deleted Successfully!"
          end
          redirect_to users_signin_url
        else
          flash.now[:alert] = "Invalid user credentials.  Unable to delete user account.  Try again."
        end
      end
    end
    
    def signin_get(request)
      if !session[:current_user_id].nil? && flash[:notice].nil?
        flash[:notice] = "You have been signed out!"
      end
      session[:current_user_id] = nil
    end
    
    def signin_post(request)
      session[:user_name] = params[:user_name]
      user = find_user
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
        redirect_to root_url
      end
    end

    # Method for retrieving registration form data via strong parameters
    def user_params
      params.require(:user).permit(:user_name, :password, 
                                   :password_confirmation, :user_email)
    end
    
    def view_get(request)
      if !session[:current_user_id].nil?
        user_id = session[:current_user_id]
        @account_names = AccountsHelper.get_account_names(user_id)
        if !@account_names.nil?
          @account_name_to_savings_amount_map = UsersHelper
            .get_account_names_to_savings_amounts_map(user_id, @account_names)
          @user_accounts_total = UsersHelper
            .get_user_accounts_total(@account_name_to_savings_amount_map)
          @account_name_id_map = UsersHelper
            .get_account_name_id_map(user_id, @account_names)
        else
          flash.now[:alert] = "No Accounts for User!"
        end
      else
        redirect_to users_signin_url
      end
    end
    
    def view_post(request)
      if !params[:delete].nil?
        record_destroyed = Account.destroy(params[:delete].keys.first)
        if record_destroyed
          flash[:notice] = "Account Deleted Successfully!"
        end
      end
      redirect_to users_view_url
    end
    
    def welcome_get(request)
      if !session[:current_user_id].nil?
        user_id = session[:current_user_id]
        @user_name = session[:user_name]
        @account_names = AccountsHelper.get_account_names(user_id)

        if session[:account_name].nil? && !@account_names.nil?
          account_name = @account_names.first
        else
          account_name = session[:account_name]
        end

        @categories = CategoriesHelper.get_categories(user_id, account_name)
        @account_total = AccountsHelper.get_account_total(@categories)
        @number_of_account_entries =
          EntriesHelper.get_number_of_account_entries(@categories)
        @last_entry = EntriesHelper.get_last_entry(@categories)

        @category_saved_amount_map = EntriesHelper
          .get_category_name_saved_amount_mapping(user_id, account_name)
      else
        redirect_to users_signin_url
      end
    end 
    
    def welcome_post(request)
      session[:account_name] = params[:account_name]
      redirect_to users_welcome_url
    end     

end
