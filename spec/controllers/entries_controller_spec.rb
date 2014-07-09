require 'spec_helper'

describe EntriesController do

  # add method examples
  it { should respond_to :add }

  describe "GET add," do
    describe "if curret_user_id not nil," do
      before do
        @user = User.new(user_name: "testuser", password: "testpw",
          password_confirmation: "testpw", user_email: "test@test.com")
        @user.save
        session[:current_user_id] = @user[:id]
      end

      it "assigns @account_names" do
        @account = Account.new(account_name: "testaccount", user_id: @user[:id])
        @account.save
        session[:account_name] = @account[:account_name]
        @category = Category.new(category_name: "testcategory", account_id: @account[:id])
        @category.save
        get :add
        expect(assigns[:account_names].first).to eql "testaccount"
      end

      it "assigns @category_names" do
        @account = Account.new(account_name: "testaccount", user_id: @user[:id])
        @account.save
        session[:account_name] = @account[:account_name]
        @category = Category.new(category_name: "testcategory", account_id: @account[:id])
        @category.save
        get :add
        expect(assigns[:category_names].first).to eql "testcategory"
      end

      describe "if @account_names nil," do
        it "flashes No Accounts alert" do
          get :add
          flash[:alert].should eql "No Accounts for User.  Must create at least one account!"
        end
      end

      describe "if @category_names is empty," do
        it "flashes No Categories alert" do
          @account = Account.new(account_name: "testaccount", user_id: @user[:id])
          @account.save
          session[:account_name] = @account[:account_name]
          get :add
          flash[:alert].should eql "No Categories for Savings Account.  Must create at least one category!"
        end
      end

      describe "if session[:category_name] is nil," do
        it "sets session[:category_name] to first category name in account" do
          @account = Account.new(account_name: "testaccount", user_id: @user[:id])
          @account.save
          session[:account_name] = @account[:account_name]
          @category = Category.new(category_name: "testcategory", account_id: @account[:id])
          @category.save
          get :add
          expect(session[:category_name]).to eql "testcategory"
        end
      end
    end

    describe "if current_user_id is nil," do
      it "redirects to users/signin page" do
        get :add
        expect(response).to redirect_to "/users/signin"
      end
    end
  end

  describe "POST add," do
    before do
      @user = User.new(user_name: "testuser", password: "testpw",
        password_confirmation: "testpw", user_email: "test@test.com")
      @user.save
      session[:current_user_id] = @user[:id]
      @account = Account.new(account_name: "testaccount", user_id: @user[:id])
      @account.save
      session[:account_name] = @account[:account_name]
      @category = Category.new(category_name: "testcategory", account_id: @account[:id])
      @category.save
    end

    it "assigns @category_names" do
      post :add, :entry => { "entry_date(1i)" => "2020", "entry_date(2i)" => "12",
                 "entry_date(3i)" => "31" , @category[:category_name].to_sym => 23.45,
                  category_name: @category[:category_name], account_name: @account[:account_name] }
      expect(assigns[:category_names].first).to eql "testcategory"
    end

    describe "if entry_attributes[:account_name] equals session[:account_name]," do
      describe "if categories_names not empty," do
        describe "if entry valid," do
          it "flashes Success notice" do
            session[:account_name] = @account[:account_name]
            post :add, :entry => { "entry_date(1i)" => "2020", "entry_date(2i)" => "12", "entry_date(3i)" => "31" ,
                                 (@category[:category_name].gsub(" ", "_") << "_entry_amount").to_sym => 23.45,
                                 category_name: @category[:category_name], account_name: @account[:account_name] }
            flash[:notice].should eql "Entries Added Successfully!"
          end
        end

        describe "if entry not valid," do
          it "flashes alert" do
            session[:account_name] = @account[:account_name]
            post :add, :entry => { "entry_date(1i)" => "2020", "entry_date(2i)" => "12", "entry_date(3i)" => "31" ,
                                 (@category[:category_name].gsub(" ", "_") << "_entry_amount").to_sym => 0,
                                 category_name: @category[:category_name], account_name: @account[:account_name] }
            flash[:alert].should eql "Entry must be greater than zero!"
          end
        end
      end
    end

    describe "if entry_attributes[:account_name] not equal to session[:account_name]," do
      before do
        session[:account_name] = @account[:account_name]
        @account2 = Account.new(account_name: "testaccount2", user_id: @user[:id])
        @account2.save
        post :add, :entry => { account_name: @account2[:account_name] }
      end

      it "sets session[:account_name] to submitted account name" do
        expect(session[:account_name]).to eql "testaccount2"
      end

      it "sets session[:category_name] to nil" do
        expect(session[:category_name]).to eql nil
      end
    end

    it "redirects to entries/add page" do
      post :add, :entry => { "entry_date(1i)" => "2020", "entry_date(2i)" => "12",
                 "entry_date(3i)" => "31" , @category[:category_name].to_sym => 0,
                  category_name: @category[:category_name], account_name: @account[:account_name] }
      expect(response).to redirect_to "/entries/add"
    end
  end

  # deduct method examples
  it { should respond_to :deduct }

  describe "GET deduct," do
    before do
      @user = User.new(user_name: "testuser", password: "testpw",
        password_confirmation: "testpw", user_email: "test@test.com")
      @user.save
      session[:current_user_id] = @user[:id]
    end

    describe "with valid user id," do
      it "renders entries/deduct view" do
        get :deduct
        expect(response).to render_template("deduct")
      end

      describe "if account names do not exist," do
        it "flashes No Accounts alert message" do
          get :deduct
          flash[:alert].should eql "No Accounts for User.  Must create at least one account!"
        end
      end

      describe "if category names do not exist," do
        it "flashes No Categories alert message" do
          @account = Account.new(account_name: "testaccount", user_id: @user[:id])
          @account.save
          get :deduct
          flash[:alert].should eql "No Categories for Savings Account.  Must create at least one category!"
        end
      end

      describe "if session[:category_name] is nil," do
        it "set session[:category_name] to first category name" do
          @account = Account.new(account_name: "testaccount", user_id: @user[:id])
          @account.save
          session[:account_name] = @account[:account_name]
          @category = Category.new(category_name: "testcategory", account_id: @account[:id])
          @category.save
          get :deduct
          expect(session[:category_name]).to eql "testcategory"
        end
      end

      describe "if account and category names exist," do
        it "assigns @category_balance" do
          @account = Account.new(account_name: "testaccount", user_id: @user[:id])
          @account.save
          session[:account_name] = @account[:account_name]
          @category = Category.new(category_name: "testcategory", account_id: @account[:id])
          @category.save
          @entryAdd = Entry.new("entry_date(1i)" => "2020", "entry_date(2i)" => "12",
                      "entry_date(3i)" => "28" , entry_amount: 123.45,
                      category_id: @category[:id])
          @entryAdd.save
          get :deduct
          expect(assigns[:category_balance]).to eql 123.45
        end
      end
    end

    describe "with invalid user id," do
      it "redirects to users/signin view" do
        session[:current_user_id] = nil
        get :deduct
        expect(response).to redirect_to("/users/signin")
      end
    end
  end

  describe "POST deduct," do
    before :each do
      @user = User.new(user_name: "test_user", password: "test_pw",
                       password_confirmation: "test_pw", user_email: "test@test.com")
      @user.save
      session[:current_user_id] = @user[:id]
      @account = Account.new(account_name: "test_account", user_id: @user[:id])
      @account.save
      session[:account_name] = @account[:account_name]
      @category = Category.new(category_name: "test_category", account_id: @account[:id])
      @category.save
      session[:category_name] = @category[:category_name]
      @entryAdd = Entry.new("entry_date(1i)" => "2020", "entry_date(2i)" => "12",
                            "entry_date(3i)" => "28" , entry_amount: 123.45,
                            category_id: @category[:id])
      @entryAdd.save
    end

    describe "when account and category selection unchanged," do
      describe "if categories exist and deduction less than category balance," do
        describe "if deduction valid," do
          it "flashes success notice message" do
            post :deduct, :entry => { "entry_date(1i)" => "2020", "entry_date(2i)" => "12", "entry_date(3i)" => "31" ,
                                    (@category[:category_name].gsub(" ", "_") << "_entry_amount").to_sym => 23.45,
                                    category_name: @category[:category_name], account_name: @account[:account_name] }
            flash[:notice].should eql "Entry Deducted Successfully!"
          end
        end
      end

      describe "if categories exist and deduction would result in a negative balance in category history," do
        it "flashes invalid deduction for specified date alert message" do
          @entryDeduct = Entry.new("entry_date(1i)" => "2020", "entry_date(2i)" => "12",
                         "entry_date(3i)" => "30" , entry_amount: -123.45,
                         category_id: @category[:id])
          @entryDeduct.save
          @entryAdd2 = Entry.new("entry_date(1i)" => "2020", "entry_date(2i)" => "12",
                                 "entry_date(3i)" => "31" , entry_amount: 123.46,
                                 category_id: @category[:id])
          @entryAdd2.save
          post :deduct, :entry => { "entry_date(1i)" => "2020", "entry_date(2i)" => "12", "entry_date(3i)" => "29" ,
                                  (@category[:category_name].gsub(" ", "_") << "_entry_amount").to_sym => 123.46,
                                  category_name: @category[:category_name], account_name: @account[:account_name] }
          flash[:alert].should eql "Invalid deduction amount for specified date!<br>
                              Deduction would result in a negative balance in
                              savings history.".html_safe
        end
      end

      describe "if categories exist and deduction would result in invalid revised balances," do
        it "flashes invalid deduction for specified date alert message" do
          @entryDeduct = Entry.new("entry_date(1i)" => "2020", "entry_date(2i)" => "12",
                         "entry_date(3i)" => "30" , entry_amount: -123.45,
                         category_id: @category[:id])
          @entryDeduct.save
          @entryAdd2 = Entry.new("entry_date(1i)" => "2020", "entry_date(2i)" => "12",
                                 "entry_date(3i)" => "31" , entry_amount: 50,
                                 category_id: @category[:id])
          @entryAdd2.save
          post :deduct, :entry => { "entry_date(1i)" => "2020", "entry_date(2i)" => "12", "entry_date(3i)" => "29" ,
                                  (@category[:category_name].gsub(" ", "_") << "_entry_amount").to_sym => 0.01,
                                  category_name: @category[:category_name], account_name: @account[:account_name] }
          flash[:alert].should eql "Invalid deduction amount for specified date!<br>
                              Deduction would result in a negative balance in
                              savings history.".html_safe
        end
      end

      describe "if deduction amount blank," do
        it "flashes alert message" do
          post :deduct, :entry => { "entry_date(1i)" => "2020", "entry_date(2i)" => "12", "entry_date(3i)" => "29" ,
                                  (@category[:category_name].gsub(" ", "_") << "_entry_amount").to_sym => "",
                                  category_name: @category[:category_name], account_name: @account[:account_name] }
          flash[:alert].should eql "Deduction amount cannot be blank and must be positive!"
        end
      end

      describe "if categories exist and deduction more than category balance," do
        it "flashes invalid deduction alert message" do
          post :deduct, :entry => { "entry_date(1i)" => "2020", "entry_date(2i)" => "12", "entry_date(3i)" => "31" ,
                                  (@category[:category_name].gsub(" ", "_") << "_entry_amount").to_sym => 123.46,
                                  category_name: @category[:category_name], account_name: @account[:account_name] }
          flash[:alert].should eql "Invalid deduction amount.  Amount exceeds category balance!"
        end
      end
    end

    describe "if category selection changed," do
      it "sets session[:category_name] to submitted category" do
        post :deduct, :entry => { category_name: "test_category2", 
             account_name: @account[:account_name] }
        expect(session[:category_name]).to eql "test_category2"
      end
    end

    describe "when account selection changed," do
      before do
        @account2 = Account.new(account_name: "test_account2", user_id: @user[:id])
        @account2.save
        post :deduct, :entry => { account_name: "test_account2" }
      end

      it "changes session account_name" do
        session[:account_name].should eql "test_account2"
      end

      it "sets session[:category_name] to nil" do
        expect(session[:category_name]).to eql nil
      end
    end

    it "redirects to entries/deduct page" do
      post :deduct, :entry => { "entry_date(1i)" => "2020", "entry_date(2i)" => "12", "entry_date(3i)" => "29" ,
                              (@category[:category_name].gsub(" ", "_") << "_entry_amount").to_sym => 123.46,
                              category_name: @category[:category_name], account_name: @account[:account_name] }
      expect(response).to redirect_to "/entries/deduct"
    end
  end

  # view method examples
  it { should respond_to :view }

  describe "GET view," do
    before do
      @user = User.new(user_name: "test_user", password: "test_pw",
              password_confirmation: "test_pw", user_email: "test@test.com")
      @user.save
      session[:current_user_id] = @user[:id]
    end

    describe "if session[:current_user_id] not nil," do
      it "assigns @account_names" do
        @account = Account.new(account_name: "test_account", user_id: @user[:id])
        @account.save
        session[:account_name] = @account[:account_name]
        get :view
        expect(assigns[:account_names].first).to eql "test_account"
      end

      it "assigns @category_names" do
        @account = Account.new(account_name: "test_account", user_id: @user[:id])
        @account.save
        session[:account_name] = @account[:account_name]
        @category = Category.new(category_name: "test_category", account_id: @account[:id])
        @category.save
        get :view
        expect(assigns[:category_names].first).to eql "test_category"
      end

      describe "if @account_names nil," do
        it "flashes No Account alert" do
          get :view
          flash[:alert].should eql "No Accounts for User.  Must create at least one account!"
        end
      end

      describe "if no category names," do
        it "" do
          @account = Account.new(account_name: "test_account", user_id: @user[:id])
          @account.save
          session[:account_name] = @account[:account_name]
          get :view
          flash[:alert].should eql "No Categories for Savings Account.  Must create at least one category!"
        end
      end

      describe "if account and category names exist," do
        before do
          @account = Account.new(account_name: "test_account", user_id: @user[:id])
          @account.save
          session[:account_name] = @account[:account_name]
          @category = Category.new(category_name: "test_category", account_id: @account[:id])
          @category.save
        end

        describe "if session[:category_name] is nil" do
          it "sets session[:category_name] to first category name in account" do
            get :view
            expect(session[:category_name]).to eql @category[:category_name]
          end
        end

        it "assigns @consolidated_entries" do
          @entryAdd = Entry.new("entry_date(1i)" => "2020", "entry_date(2i)" => "12",
                                "entry_date(3i)" => "28" , entry_amount: 123.45,
                                category_id: @category[:id])
          @entryAdd.save
          get :view
          expect(assigns[:consolidated_entries].first.last).to eql 123.45
        end

        describe "if no consolidated entries," do
          it "flashes alert message" do
            get :view
            flash.now[:alert].should eql "No Entries have been added to account categories!"
          end
        end

        describe "if consolidated entries exist," do
          it "assigns @account_total" do
            @entryAdd = Entry.new("entry_date(1i)" => "2020", "entry_date(2i)" => "12",
                        "entry_date(3i)" => "28" , entry_amount: 123.45,
                        category_id: @category[:id])
            @entryAdd.save
            @entryAdd2 = Entry.new("entry_date(1i)" => "2020", "entry_date(2i)" => "12",
                        "entry_date(3i)" => "29" , entry_amount: 40,
                        category_id: @category[:id])
            @entryAdd2.save
            get :view
            expect(assigns[:account_total]).to eql 163.45
          end
        end
      end
    end

    describe "if session[:current_user_id] is nil," do
      it "redirects to users/signin page" do
        session[:current_user_id] = nil
        get :view
        expect(response).to redirect_to "/users/signin"
      end
    end
  end

  describe "POST view," do
    before do
      @user = User.new(user_name: "test_user", password: "test_pw",
              password_confirmation: "test_pw", user_email: "test@test.com")
      @user.save
      session[:current_user_id] = @user[:id]
      @account = Account.new(account_name: "test_account", user_id: @user[:id])
      @account.save
    end

    describe "if session[:current_user_id] not nil," do
      it "sets session[:account_name] to submitted account_name" do
        post :view, account_name: @account[:account_name]
        expect(session[:account_name]).to eql @account[:account_name]
      end

      it "sets session[:category_name] to nil" do
        post :view, account_name: @account[:account_name]
        expect(session[:category_name]).to eql nil
      end

      it "redirects to entries/view page" do
        post :view
        expect(response).to redirect_to "/entries/view"
      end
    end
  end

end
