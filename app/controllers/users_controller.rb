# Class for controlling actions related to "users" web page views
class UsersController < ApplicationController

  # Method for handling get and post actions for "users/manage" web page
  def manage
    manage_get if request.get?
    manage_post if request.post?
  end

  # Method for handling get and post actions for "users/registration" web page
  def registration
    registration_get if request.get?
    registration_post if request.post?
  end

  # Method for handling get and post actions for "users/signin" web page
  def signin
    signin_get if request.get?
    signin_post if request.post?
  end

  # Method for handling get and post actions for "users/view" web page
  def view
    view_get if request.get?
    view_post if request.post?
  end

  # Method for handling get and post actions for "users/welcome" web page
  def welcome
    welcome_get if request.get?
    welcome_post if request.post?
  end

  private

    def change_email
      user = find_user
      if user && user[:id] == params["change-email".to_sym].keys.first.to_i &&
                 user.authenticate(params[:password])
        if params[:user_email] == params[:user_email_confirm]
          user[:user_email] = params[:user_email]
          is_saved = user.save
          if is_saved
            flash[:notice] = "Email Changed Successfully!"
          else
            flash[:alert] = user.errors.first[1]
          end
          redirect_to users_manage_url
        else
          flash.now[:alert] = "New Email and Confirmation do not match. Please try again."
        end
      else
        flash.now[:alert] = "Invalid user credentials.  Unable to change email address."
      end
    end

    def change_password
      user = find_user
      if user && user[:id] == params["change-password".to_sym].keys.first.to_i &&
                 user.authenticate(params[:password])
        if params[:new_password] == "" || params[:new_password_confirm] == ""
          flash.now[:alert] = "Password cannot be blank!"
        elsif params[:new_password] == params[:new_password_confirm]
          user.password = params[:new_password]
          user.password_confirmation = params[:new_password_confirm]
          is_saved = user.save
          if is_saved
            flash[:notice] = "Password Changed Successfully!"
          else
            flash[:alert] = user.errors.first[1]
          end
          redirect_to users_manage_url
        else
          flash.now[:alert] = "New Password and Confirmation Must be Identical."
        end
      else
        flash.now[:alert] = "Invalid user credentials.  Unable to change password."
      end
    end

    def delete_account
      record_destroyed = Account.destroy(params[:delete].keys.first)
      if record_destroyed
        account_names = AccountsHelper.get_account_names(session[:current_user_id])
        if !account_names.nil?
          session[:account_name] = account_names.first
        else
          session[:account_name] = nil
        end
        session[:category_name] = nil
        flash[:notice] = "Account Deleted Successfully!"
      end
    end

    def delete_user
      user = find_user
      if user && user[:id] == params[:delete].keys.first.to_i &&
                 user.authenticate(params[:password])
        record_destroyed = User.destroy(user[:id])
        if record_destroyed
          flash[:notice] = "User Account Deleted Successfully!"
        end
        redirect_to users_signin_url
      else
        flash.now[:alert] = "Invalid user credentials.  Unable to delete user account."
      end
    end

    def find_user
      user_name = params[:user_name].downcase
      User.find_by user_name: "#{user_name}"
    end

    def manage_get
      if session[:current_user_id].nil?
        redirect_to users_signin_url
      else
        @user_email = User.find_by(id: session[:current_user_id])[:user_email]
      end
    end

    def manage_post
      if !params["change-password".to_sym].nil?
        change_password
      elsif !params["change-email".to_sym].nil?
        change_email
      elsif !params[:delete].nil?
        delete_user
      end
    end

    def registration_get
      flash[:notice] = nil
    end

    def registration_post
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

    def signin_get
      if !session[:current_user_id].nil? && flash[:notice].nil?
        flash[:notice] = "You have been signed out!"
        flash[:alert] = nil
      elsif !flash[:notice].nil? && flash[:notice] != "Registration Successful. Please Sign In!" &&
            flash[:notice] != "User Account Deleted Successfully!"
        flash[:notice] = nil
      end
      session[:current_user_id] = nil
      session[:account_name] = nil
      session[:category_name] = nil
    end

    def signin_post
      session[:user_name] = params[:user_name]
      user = find_user
      if user && user.authenticate(params[:password])
        flash[:notice] = "Sign in successful."
        session[:current_user_id] = user[:id]
        account_names = AccountsHelper.get_account_names(user[:id])
        if !account_names.nil?
          session[:account_name] = account_names.first
        end
        time_difference = Time.parse(params[:client_time]).utc_offset - Time.now.utc_offset
        session[:time_difference] = time_difference
        redirect_to users_welcome_url
      else
        flash[:alert] = "Credentials Invalid. Please try again!"
        redirect_to root_url
      end
    end

    def update_account
      account_id = params["save-update".to_sym].keys.first
      account = Account.find_by(id: account_id, user_id: session[:current_user_id])
      update_account = false
      flash[:alert] = nil

      if account[:account_name] != params[:account][:account_name]
        if AccountsHelper.get_user_account(session[:current_user_id], params[:account][:account_name]).empty?
          account[:account_name] = params[:account][:account_name]
          update_account = true
        else
          flash[:alert] = "Account Name Already Exists. Account Not Updated!"
        end
      end

      if account.valid?
        if update_account
          account.save
          flash[:notice] = "Account Updated Successfully!"
          session[:account_name] = account[:account_name]
          session[:category_name] = nil
        elsif flash[:alert].nil?
          flash[:alert] = "Account Name Unchanged. Account Not Updated!"
        end
      else
        flash[:alert] = account.errors.first[1]
      end
    end

    # Method for retrieving registration form data via strong parameters
    def user_params
      params.require(:user).permit(:user_name, :password,
                                   :password_confirmation, :user_email)
    end

    def view_get
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

    def view_post
      if !params["save-update".to_sym].nil?
        update_account
      elsif !params[:delete].nil?
        delete_account
      end
      redirect_to users_view_url
    end

    def welcome_get
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
          .get_category_name_saved_amount_mapping(@categories)
      else
        redirect_to users_signin_url
      end
    end

    def welcome_post
      session[:account_name] = params[:account_name]
      session[:category_name] = nil
      redirect_to users_welcome_url
    end

end
