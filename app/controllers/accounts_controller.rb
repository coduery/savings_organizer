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

    def delete_category(request)
      record_destroyed = Category.destroy params[:delete].keys.first
      if record_destroyed
        categories = CategoriesHelper.get_categories(session[:current_user_id], session[:account_name])
        if categories.size > 0
          session[:category_name] = categories.first[:category_name]
        else
          session[:category_name] = nil
        end
        flash[:notice] = "Category Deleted Successfully!"
      end
    end

    def update_category(request)
      category_id = params["save-update".to_sym].keys.first
      category = CategoriesHelper.get_category_with_id category_id
      update_category = false
      flash[:alert] = nil

      if category[:category_name] != params[:category][:category_name]
        account = Account.find_by(account_name: session[:account_name], user_id: session[:current_user_id])
        if !CategoriesHelper.does_category_exist?(session[:current_user_id], account[:id], params[:category][:category_name])
          category[:category_name] = params[:category][:category_name]
          update_category = true
        else
          flash[:alert] = "Category Name Already Exists. Category Not Updated!"
        end
      end

      if params[:category][:savings_goal].empty?
        params[:category][:savings_goal] = nil
      end
      if params[:category][:savings_goal_date].empty?
        params[:category][:savings_goal_date] = nil
      end

      if flash[:alert].nil? && category[:savings_goal] != params[:category][:savings_goal]
        category[:savings_goal] = params[:category][:savings_goal]
        update_category = true
      end

      if flash[:alert].nil? && category[:savings_goal_date] != params[:category][:savings_goal_date]
        if !category[:savings_goal].nil?
          if !params[:category][:savings_goal_date].nil?
            begin
              date_array = params[:category][:savings_goal_date].split('/')
              goal_date = Date.civil(date_array[2].to_i, date_array[0].to_i, date_array[1].to_i)
            rescue ArgumentError
              goal_date = nil
              flash[:alert] = "Invalid Target Date Entered!"
            end
          else
            goal_date = nil
          end
          category[:savings_goal_date] = goal_date
        elsif params[:category][:savings_goal_date].nil?
          category[:savings_goal_date] = nil
        else
          flash[:alert] = "Savings Goal Date cannot be set without a Savings Goal!"
        end
        if flash[:alert].nil?
          update_category = true
        else
          update_category = false
        end
      end

      if category.valid?
        if update_category
          category.save
          flash[:notice] = "Category Updated Successfully!"
          session[:category_name] = category[:category_name]
        elsif flash[:alert].nil?
          flash[:alert] = "Category Parameters Unchanged. Category Not Updated!"
        end
      else
        flash[:alert] = category.errors.first[1]
      end
    end

    def view_get(request)
      if !session[:current_user_id].nil?
        user_id = session[:current_user_id]
        @account_names = AccountsHelper.get_account_names user_id
        if !@account_names.nil?
          @categories =
            CategoriesHelper.get_categories(user_id, session[:account_name])
          category_names = CategoriesHelper.get_category_names(@categories)
          if category_names.size > 0
            @category_name_id_mapping = CategoriesHelper
              .get_category_name_id_mapping(@categories)
            @category_name_savings_amount_mapping = CategoriesHelper.
              get_category_name_savings_amount_mapping(category_names, @category_name_id_mapping)
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
      #if session[:account_name] != params[:account_name]
      if !params[:account_name].nil? && session[:account_name] != params[:account_name]
        session[:account_name] = params[:account_name]
      elsif !params["save-update".to_sym].nil?
        update_category request
      elsif !params[:delete].nil?
        delete_category request
      end
      redirect_to accounts_view_url
    end

end
