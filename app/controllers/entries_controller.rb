# Class for controlling actions related to "entries" web page views
class EntriesController < ApplicationController

  # Method for handling get and post actions for entries "add" web page
  def add
    add_get if request.get?
    add_post if request.post?
  end

  # Method for handling get and post actions for entries "deduct" web page
  def deduct
    deduct_get if request.get?
    deduct_post if request.post?
  end

  # Method for handling get and post actions for entries "view" web page
  def view
    view_get if request.get?
    view_post if request.post?
  end

  private

    def add_get
      if !session[:current_user_id].nil?
        @account_names = AccountsHelper.get_account_names session[:current_user_id]
        @category_names = get_category_names
        if @account_names.nil?
          flash_no_account_alert
        elsif @category_names.empty?
          flash_no_category_alert
        elsif session[:category_name].nil?
          session[:category_name] = @category_names.first
        end
      else
        redirect_to users_signin_url
      end
    end

    def add_post
      @category_names = get_category_names
      entry_attributes = entry_params
      if entry_attributes[:account_name] == session[:account_name]
        if !@category_names.empty?
          entries = Array.new

          @category_names.each do |category_name|
            category_entry_amount = (category_name.gsub(" ", "_") << "_entry_amount").to_sym
            if !entry_attributes[category_entry_amount].blank? &&
                entry_attributes[category_entry_amount].to_f > 0
              entry = create_entry(entry_attributes, category_name, entry_attributes[category_entry_amount])
              if entry.valid?
                entries.push entry
              end
            end
          end

          if !entries.empty?
            entries.each do |entry|
              entry.save
            end
            flash[:notice] = "Entries Added Successfully!"
          elsif flash[:alert].nil?
            flash[:alert] = "Entry must be greater than zero!"
          end
        end
      else
        session[:account_name] = entry_attributes[:account_name]
        session[:category_name] = nil
      end
      redirect_to entries_add_url
    end

    def create_entry(entry_attributes, category_name, category_entry_amount)
      category = CategoriesHelper.get_category(session[:current_user_id],
                 entry_attributes[:account_name], category_name)
      @category_id = category[:id]
      @entry_date = Date.civil(entry_attributes["entry_date(1i)"].to_i,
                               entry_attributes["entry_date(2i)"].to_i,
                               entry_attributes["entry_date(3i)"].to_i)
      Entry.new(:entry_date => @entry_date,
                :entry_amount => category_entry_amount,
                :category_id  => @category_id)
    end

    # Method for handling "deduct" web page get requests
    def deduct_get
      if !session[:current_user_id].nil?
        @account_names = AccountsHelper.get_account_names session[:current_user_id]
        @category_names = get_category_names
        if @account_names.nil?
          flash_no_account_alert
        elsif @category_names.empty?
          flash_no_category_alert
        else
           if session[:category_name].nil?
             session[:category_name] = @category_names.first
           end
           @category_balance = get_category_balance session[:category_name]
        end
      else
        redirect_to users_signin_url
      end
    end

    # Method for handling "deduct" web page post requests
    def deduct_post
      @category_names = get_category_names
      if !session[:category_name].nil?
        category_balance = get_category_balance session[:category_name]
      end
      entry_attributes = entry_params
      if session[:account_name] == entry_attributes[:account_name] &&
         session[:category_name] == entry_attributes[:category_name]
        category_entry_amount = (entry_attributes[:category_name].gsub(" ", "_") << "_entry_amount").to_sym
        if !@category_names.empty? && entry_attributes[category_entry_amount].to_f <= category_balance
          if !entry_attributes[:category_name].blank? && entry_attributes[category_entry_amount].to_f > 0
            entry = create_entry(entry_attributes, session[:category_name], -(entry_attributes[category_entry_amount].to_f))
          end
          if !entry.nil?
            category_entries = CategoriesHelper.get_category_entries @category_id
            category_entries_prior_balance =
              CategoriesHelper.get_category_entries_prior_balance(category_entries, @entry_date)
            if category_entries_prior_balance >= entry_attributes[category_entry_amount].to_f &&
               !CategoriesHelper.will_result_in_negative_future_balances?(category_entries, entry)
              entry.save
              flash[:notice] = "Entry Deducted Successfully!"
            else
              flash[:alert] = "Invalid deduction amount for specified date!<br>
                              Deduction would result in a negative balance in
                              savings history.".html_safe
            end
          elsif flash[:alert].nil?
            flash[:alert] = "Deduction amount cannot be blank and must be positive!"
          end
        elsif entry_attributes[category_entry_amount].to_f > category_balance
          flash[:alert] = "Invalid deduction amount.  Amount exceeds category balance!"
        end
      elsif session[:account_name] == entry_attributes[:account_name]
        session[:category_name] = entry_attributes[:category_name]
      else
        session[:account_name] = entry_attributes[:account_name]
        session[:category_name] = nil
      end
      redirect_to entries_deduct_url
    end

    # Method for retrieving entry form data via strong parameters
    def entry_params
      params_allowed = [:account_name, :entry_date, :category_name]
      if !@category_names.nil?
        @category_names.each do |category_name|
          category_entry = category_name.gsub(" ", "_") << "_entry_amount"
          params_allowed.push category_entry.to_sym
        end
      end
      params.require(:entry).permit params_allowed
    end

    def flash_no_account_alert
      flash.now[:alert] = "No Accounts for User.  Must create at least one account!"
    end

    def flash_no_category_alert
      flash.now[:alert] = "No Categories for Savings Account.  Must create at least one category!"
    end

    # Method for getting the dollar balance for a savings account category
    def get_category_balance(category_name)
      category = CategoriesHelper.get_category(session[:current_user_id],
                    session[:account_name], category_name)
      CategoriesHelper.get_category_entries_total category[:id]
    end

    def get_category_names
      if !session[:current_user_id].nil?
        categories = CategoriesHelper.get_categories(session[:current_user_id], session[:account_name])
        CategoriesHelper.get_category_names categories
      end
    end

    def view_get
      if !session[:current_user_id].nil?
        user_id = session[:current_user_id]
        @account_names = AccountsHelper.get_account_names user_id
        categories = CategoriesHelper.get_categories(user_id, session[:account_name])
        @category_names = CategoriesHelper.get_category_names categories
        if @account_names.nil?
          flash_no_account_alert
        elsif @category_names.empty?
          flash_no_category_alert
        else
          if session[:category_name].nil?
            session[:category_name] = @category_names.first
          end
          @consolidated_entries = EntriesHelper.get_consolidated_entries(user_id, session[:account_name])
          if @consolidated_entries.empty?
            flash.now[:alert] = "No Entries have been added to account categories!"
          else
            categories = CategoriesHelper.get_categories(user_id, session[:account_name])
            @account_total = AccountsHelper.get_account_total categories
          end
        end
      else
        redirect_to users_signin_url
      end
    end

    def view_post
      if !session[:current_user_id].nil?
        session[:account_name] = params[:account_name]
        session[:category_name] = nil
        redirect_to entries_view_url
      end
    end

end
