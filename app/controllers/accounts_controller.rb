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

  private

    # Method for retrieving accounts creation form data via strong parameters
    def account_params
      params.require(:account).permit(:account_name)
    end

end
