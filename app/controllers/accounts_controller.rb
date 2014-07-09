# Class for controlling actions related to "accounts" web page views
class AccountsController < ApplicationController

  # Method for handling get and post actions for accounts "create" web page
  def create
    create_get(request) if request.get?
    create_post(request) if request.post?
  end

  def view
    view_get(request) if request.get?
    view_post(request) if request.post?
  end

  private

    # Method for retrieving accounts creation form data via strong parameters
    def account_params
      params.require(:account).permit(:account_name)
    end

    def create_get(request)
      if session[:current_user_id].nil?
        redirect_to users_signin_url
      end
    end

    def create_post(request)
      user_id = session[:current_user_id]
      account_attributes = account_params
      account_name = account_attributes[:account_name]
      if !AccountsHelper.get_user_account(user_id, account_name).empty?
        flash[:alert] = "Account Name Already Exists!"
      else
        account_attributes[:user_id] = user_id
        account = Account.new(account_attributes)
        if account.valid?
          account.save
          session[:account_name] = account_name
          flash[:notice] = "Account Created Successfully!"
        else
          flash[:alert] = account.errors.first[1]
        end
      end
      redirect_to accounts_create_url
    end

    def view_get(request)
      if !session[:current_user_id].nil?
        user_id = session[:current_user_id]
        @account_names = AccountsHelper.get_account_names user_id
        if !@account_names.nil?
          categories =
            CategoriesHelper.get_categories(user_id, session[:account_name])
          account_name = session[:account_name]
          @category_names = CategoriesHelper.get_category_names(categories)
          if @category_names.size > 0
            @category_name_id_mapping = CategoriesHelper
              .get_category_name_id_mapping(categories)
            @category_name_savings_amount_mapping = CategoriesHelper.
              get_category_name_savings_amount_mapping(@category_names, @category_name_id_mapping)
            @account_total = 0
            @category_name_savings_amount_mapping.each do |key, value|
              @account_total += value
            end
          else
            flash.now[:alert] = "No Categories for Selected Account!"
          end
        else
          flash[:alert] = "No Accounts for User.  Must create at least one account!"
        end
      else
        redirect_to users_signin_url
      end
    end

    def view_post(request)
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
