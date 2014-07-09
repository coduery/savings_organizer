require 'spec_helper'

describe CategoriesController do

  # create method examples
  it { should respond_to :create }

  describe "GET create" do
    describe "when user_id is not nil" do
      before do
        @user = User.new(user_name: "testuser", password: "testpw",
          password_confirmation: "testpw", user_email: "test@test.come")
        @user.save
        session[:current_user_id] = @user[:id]
      end

      it "renders categories/create view" do
        get :create
        expect(response).to render_template("create")
      end

      describe "if @account_names is nil" do
        before do
          get :create
        end

        it "assigns @account_names nil" do
          expect(assigns[:account_names]).to be nil
        end

        it "flashes no accounts alert" do
          flash[:alert].should eql "No Accounts for User.  Must create at least one account!"
        end
      end

      describe "if @account_names is not nil" do
        before do
          @account = Account.new(account_name: "testaccount", user_id: @user[:id])
          @account.save
        end

        it "assigns @account_names not nil" do
          get :create
          expect(assigns[:account_names]).not_to be nil
        end

        it "assigns session[:category_name_to_add] to @category_name" do
          session[:category_name_to_add] = "testcategory"
          get :create
          expect(assigns[:category_name]).to eql "testcategory"
        end

        it "sets session[:category_name_to_add] to nil" do
          get :create
          expect(session[:category_name_to_add]).to be nil
        end
      end
    end

    describe "when user_id is nil" do
      it "redirects to users/signin view" do
        session[:current_user_id] = nil
        get :create
        expect(response).to redirect_to("/users/signin")
      end
    end
  end

  describe "POST create" do
    before :each do
      @user = User.new(user_name: "test_user", password: "test_pw",
        password_confirmation: "test_pw", user_email: "test@test.com")
      @user.save
      session[:current_user_id] = @user[:id]
      @account = Account.new(account_name: "test_account", user_id: @user[:id])
      @account.save
      session[:account_name] = @account.account_name
    end

    describe "when account_name equal to session account_name," do
      describe "but category_name already exists" do
        it "flash alert message" do
          @category = Category.new(category_name: "test_category", account_id: @account[:id])
          @category.save
          category_params = { account_name: "test_account", category_name: "test_category" }
          post :create, :category => category_params
          flash[:alert].should eql "Category Name Already Exists!"
        end
      end

      describe "and goal entry is valid" do
        describe "and category is valid" do
          it "flashes notice category creation successful" do
            category_params = { account_name: "test_account", category_name: "test_category",
                                savings_goal: "123.45", "savings_goal_date(1i)" => "2020",
                                "savings_goal_date(2i)" => "12", "savings_goal_date(3i)" => "31" }
            post :create, :category => category_params
            flash[:notice].should eql "Category Created Successfully!"
          end
        end

        describe "and category is not valid" do
          it "flashed alert message" do
            category_params = { account_name: "test_account", category_name: "" }
            post :create, :category => category_params
            flash[:alert].should_not be_nil
          end
        end
      end

      describe "or date entry is valid but goal not set" do
        before do
          category_params = { account_name: "test_account", category_name: "test_category",
                              "savings_goal_date(1i)" => "2020", "savings_goal_date(2i)" => "12",
                              "savings_goal_date(3i)" => "31" }
          post :create, :category => category_params
        end

        it "sets session[:category_name_to_add] to category_attributes[:category_name]" do
          expect(session[:category_name_to_add]).to eql "test_category"
        end

        it "flashes alert message" do
          flash[:alert].should eql "Goal amount required with goal date!"
        end
      end
    end

    describe "when account_name not equal to session account_name" do
      it "sets session account_name to account_name" do
        session[:account_name] = "test_account2"
        category_params = { :account_name => @account.account_name }
        post :create, :category => category_params
        session[:account_name].should eql @account.account_name
      end
    end

    it "redirects to categories/create url" do
      session[:account_name] = "test_account2"
      category_params = { :account_name => @account.account_name }
      post :create, :category => category_params
      expect(response).to redirect_to "/categories/create"
    end
  end

  # view method examples
  it { should respond_to :view }

  describe "GET view" do
    before do
      @user = User.new(user_name: "test_user", password: "test_pw",
        password_confirmation: "test_pw", user_email: "test@test.com")
      @user.save
    end

    describe "if session[:current_user_id] is nil" do
      it "redirects to users/signin page" do
        get :view
        expect(response).to redirect_to "/users/signin"
      end
    end

    describe "if session[:current_user_id] is not nil" do
      describe "if @account_names is nil" do
        it "flashes No Account alert meassage" do
          session[:current_user_id] = @user[:id]
          get :view
          flash[:alert].should eql "No Accounts for User.  Must create at least one account!"
        end
      end

      it "renders categories/view" do
        session[:current_user_id] = @user[:id]
        get :view
        expect(response).to render_template("categories/view");
      end

      describe "if @account_names not nil" do
        before do
          session[:current_user_id] = @user[:id]
          @account = Account.new(account_name: "test_account", user_id: @user[:id])
          @account.save
          session[:account_name] = @account.account_name
        end

        it "assigns @account_names" do
          get :view
          expect(assigns[:account_names][0]).to eql "test_account"
        end

        describe "if there are category names" do
          before do
            @category = Category.new(category_name: "test_category", account_id: @account[:id])
            @category.save
          end

          it "assigns @category_names" do
            get :view
            expect(assigns[:category_names][0]).to eql "test_category"
          end

          describe "if session[:category_name] is nil" do
            it "assigns first category name to session[:category_name]" do
              get :view
              expect(session[:category_name]).to eql "test_category"
            end
          end

          describe "if there are category_entries" do
            before do
              @entryAdd = Entry.new("entry_date(1i)" => "2020", "entry_date(2i)" => "12",
                                    "entry_date(3i)" => "30" , entry_amount: 123.45,
                                    category_id: @category[:id])
              @entryAdd.save
              @entryDeduct = Entry.new("entry_date(1i)" => "2020", "entry_date(2i)" => "12",
                                       "entry_date(3i)" => "31" , entry_amount: -23.45,
                                       category_id: @category[:id])
              @entryDeduct.save
              get :view
            end

            it "assigns @category_entries size greater than zero" do
              expect(assigns[:category_entries].size).to be > 0
            end

            it "assigns @category_entries" do
              expect(assigns[:category_entries][0][:id]).to eql @entryDeduct[:id]
            end

            it "assigns @deduction_category_entries_total" do
              expect(assigns[:deduction_category_entries_total]).to eql @entryDeduct[:entry_amount]
            end

            it "assigns @addition_category_entries_total" do
              expect(assigns[:addition_category_entries_total]).to eql @entryAdd[:entry_amount]
            end

            it "assigns @category_balance" do
              expect(assigns[:category_balance]).to eql(@entryAdd[:entry_amount] + @entryDeduct[:entry_amount])
            end
          end

          describe "if there are no category_entries" do
            it "flashes No Entries alert" do
              get :view
              flash[:alert].should eql "No Entries for Selected Category!"
            end
          end
        end

        describe "if there are not category names" do
          it "flashes No Categories alert" do
            get :view
            flash[:alert].should eql "No Categories for Selected Account!"
          end
        end
      end
    end
  end

  describe "POST view" do
    describe "if account and category name not changed" do
      before do
        @user = User.new(user_name: "test_user", password: "test_pw",
          password_confirmation: "test_pw", user_email: "test@test.com")
        @user.save
        session[:current_user_id] = @user[:id]
        @account = Account.new(account_name: "test_account", user_id: @user[:id])
        @account.save
        session[:account_name] = @account.account_name
        @category = Category.new(category_name: "test_category", account_id: @account[:id])
        @category.save
        session[:category_name] = @category.category_name
        @entryAdd = Entry.new("entry_date(1i)" => "2020", "entry_date(2i)" => "12",
                           "entry_date(3i)" => "30" , entry_amount: 123.45,
                           category_id: @category[:id])
        @entryAdd.save
        @entryDeduct = Entry.new("entry_date(1i)" => "2020", "entry_date(2i)" => "12",
                                 "entry_date(3i)" => "31" , entry_amount: -23.45,
                                 category_id: @category[:id])
        @entryDeduct.save
      end

      describe "if delete entry submitted" do
        describe "and valid deletion" do
          it "flashes notice message" do
            post :view, account_name: @account.account_name, category_name: @category.category_name,
                        delete: { @entryDeduct[:id] => "Delete Entry"}
            flash[:notice].should eql "Entry deleted successfully!"
          end
        end

        describe "but not valid deletion" do
          it "flashes alert message" do
            post :view, account_name: @account.account_name, category_name: @category.category_name,
                        delete: { @entryAdd[:id] => "Delete Entry"}
            flash[:alert].should eql "Invalid entry deletion!<br>
                            Deletion would result in a negative
                            balance in savings history.".html_safe
          end
        end
      end
    end

    describe "if account not changed and category changed" do
      it "sets session[:category_name] to submitted category name" do
        session[:account_name] = "test_account"
        session[:category_name] = "test_category1"
        post :view, account_name: "test_account", category_name: "test_category2"
        expect(session[:category_name]).to eql "test_category2"
      end
    end

    describe "if account changed" do
      before do
        session[:account_name] = "test_account1"
        session[:category_name] = "test_category"
        post :view, account_name: "test_account2", category_name: "test_category"
      end

      it "sets session[:account_name] to submitted account name" do
        expect(session[:account_name]).to eql "test_account2"
      end

      it "sets session[:category_name] to nil" do
        expect(session[:category_name]).to eql nil
      end
    end

    it "redirects to categories/view url" do
      post :view
      expect(response).to redirect_to "/categories/view"
    end
  end

end
