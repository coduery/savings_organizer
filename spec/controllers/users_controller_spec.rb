require 'spec_helper'

describe UsersController do

  # manage method examples
  it { should respond_to :manage }

  describe "GET manage," do
    describe "if current_user_id is not nil," do
      it "renders users/manage page" do
        session[:current_user_id] = 1
        get :manage
        expect(response).to render_template("manage")
      end
    end

    describe "if current_user_id is nil," do
      it "redirects to users/signin page" do
        get :manage
        expect(response).to redirect_to("/users/signin")
      end
    end
  end

  describe "POST manage," do
    before do
      @user = User.new(user_name: "test_user", password: "test_pw",
                       password_confirmation: "test_pw", user_email: "test@test.com")
      @user.save
    end

    describe "if params[:delete] not nil," do
      describe "username and password valid," do
        before do
          post :manage, delete: { @user[:id] => "Delete User Account" },
            "user_name" => @user.user_name, "password" => @user.password
        end

        it "deletes user account" do
          flash[:notice].should eql "User Account Deleted Successfully!"
        end

        it "redirects to users/signin page" do
          expect(response).to redirect_to("/users/signin")
        end
      end

      describe "username or password not valid," do
        it "flashes error message" do
          post :manage, delete: { @user[:id] => "Delete User Account" },
            "user_name" => @user.user_name, "password" => "notvalid"
          flash[:alert].should eql "Invalid user credentials.  Unable to delete user account.  Try again."
        end
      end
    end
  end

  # registration method examples
  it { should respond_to :registration }

  describe "GET registration," do
    it "renders users/registration view" do
      get :registration
      expect(response).to render_template("registration")
    end

    it "sets flash[:notice] to nil" do
      flash[:notice].should eql nil
    end

  end

  describe "POST registration," do
    before do
      @user_params = { user_name: "test_user", password: "test_pw",
                       password_confirmation: "test_pw", user_email: "test@test.com" }
    end

    describe "when successful," do
      it "flashes success message" do
        post :registration, :user => @user_params
        flash[:notice].should eql "Registration Successful. Please Sign In!"
      end
    end

    describe "when successful," do
      it "renders users/signin view" do
        post :registration, :user => @user_params
        expect(response).to redirect_to("/")
      end
    end

    describe "when not successful," do
      it "flashes a registration error message" do
        @user_params[:user_name] = ""
        post :registration, :user => @user_params
        flash[:alert].should_not be_nil
      end
    end
  end

  # signin method examples
  it { should respond_to :signin }

  describe "GET signin," do
    it "renders users/signin view" do
      get :signin
      expect(response).to render_template("signin")
    end

    describe "when current_user_id not nil and flash[:notice] nil," do
      before do
        session[:current_user_id] = 1
        get :signin
      end

      it "flashes a signed out message" do
        flash[:notice].should eql "You have been signed out!"
      end

      it "sets flash[:alert] to nil" do
        flash[:alert].should eql nil
      end
    end

    it "sets session[:current_user_id] to nil" do
      get :signin
      expect(session[:current_user_id]).to be_nil
    end

    it "sets session[:account_name] to nil" do
      get :signin
      expect(session[:account_name]).to be_nil
    end

    it "sets session[:category_name] to nil" do
      get :signin
      expect(session[:category_name]).to be_nil
    end
  end

  describe "POST signin," do
    before do
      @user = User.new(user_name: "test_user", password: "test_pw",
                       password_confirmation: "test_pw", user_email: "test@test.com")
      @user.save
      @account = Account.new(account_name: "test_account", user_id: @user[:id])
      @account.save
    end

    describe "when user authenticated," do
      before do
        post :signin, "user_name" => @user.user_name, "password" => @user.password, "client_time" => Time.now
      end

      it "flashes success message" do
        flash[:notice].should eql "Sign in successful."
      end

      it "sets session[:current_user_id] to user[:id]" do
        expect(session[:current_user_id]).to eql @user[:id]
      end

      it "sets session[:account_name] to user's first account_name" do
        expect(session[:account_name]).to eql @account[:account_name]
      end

      it "redirects to users/welcome view" do
        expect(response).to redirect_to("/users/welcome")
      end

    end

    describe "when user not authenticated," do
      before do
        post :signin, "user_name" => @user.user_name, "password" => "invalid_pw"
      end

      it "flashes a invalid credentials alert" do
        flash[:alert].should eql("Credentials Invalid. Please try again!")
      end

      it "redirects to root view" do
        expect(response).to redirect_to("/")
      end
    end

    describe "when username is blank," do
      it "flashes a invalid credentials alert" do
        post :signin, "user_name" => "", "password" => "test_pw"
        flash[:alert].should eql("Credentials Invalid. Please try again!")
      end
    end
  end

  # view method examples
  it { should respond_to :view }

  describe "GET view," do
    describe "when session[:current_user_id] is not nil," do
      before do
        @user = User.new(user_name: "test_user", password: "test_pw",
                         password_confirmation: "test_pw", user_email: "test@test.com")
        @user.save
        @account = Account.new(account_name: "test_account", user_id: @user[:id])
        @account.save
      end

      it "renders users/view" do
        session[:current_user_id] = 1
        get :view
        expect(response).to render_template("view")
      end

      it "when user has no accounts" do
        @user2 = User.new(user_name: "test_user2", password: "test_pw2",
                                     password_confirmation: "test_pw2", user_email: "test2@test.com")
        @user2.save
        session[:current_user_id] = @user2[:id]
        get :view
        flash.now[:alert].should eql "No Accounts for User!"
      end

      describe "when user has accounts," do
        before do
          session[:current_user_id] = @user[:id]
          get :view
        end

        it "expect @account_name_to_savings_amount_map to have account name" do
          expect(assigns(:account_name_to_savings_amount_map).keys.first).to eql(:test_account)
        end

        it "expect @user_accounts_total to be zero or greater" do
          expect(assigns(:user_accounts_total)).to be >= 0
        end

        it "expect @account_name_id_map to have mapping" do
          account_name_id_map = assigns(:account_name_id_map)
          expect(account_name_id_map["test_account"]).to eql @account[:id]
        end
      end
    end

    describe "when session[:current_user_id] is nil," do
      it "redirects to users/signin page" do
        get :view
        expect(response).to redirect_to("/users/signin")
      end
    end
  end

  describe "POST view," do
    it "redirects to users/view" do
      post :view
      expect(response).to redirect_to("/users/view")
    end

    describe "if params[:save-update] not nil," do
      before do
        @user = User.new(user_name: "test_user", password: "test_pw",
                         password_confirmation: "test_pw", user_email: "test@test.com")
        @user.save
        session[:current_user_id] = @user[:id]
        @account = Account.new(account_name: "test_account", user_id: @user[:id])
        @account.save
        @account2 = Account.new(account_name: "test_account2", user_id: @user[:id])
        @account2.save
      end

      describe "if account[:account_name] not equal params[:account][:account_name]," do
        describe "if account name does not already exist," do
          before do
            post :view, account: {account_name: "test_account3"}, "save-update" => {@account[:id] => "Save"}
          end

          it "flashes Account Updated Successfully message" do
            flash[:notice].should eql "Account Updated Successfully!"
          end

          it "sets session[:account_name] to updated account name" do
            expect(session[:account_name]).to eql "test_account3"
          end
        end

        describe "if account name already exists," do
          it "flashes Account Name Already Exists alert" do
            post :view, account: {account_name: "test_account2"}, "save-update" => {@account[:id] => "Save"}
            flash[:alert].should eql "Account Name Already Exists. Account Not Updated!"
          end
        end
      end

      describe "if account[:account_name] is equal params[:account][:account_name]," do
        it "flashes Account Name Unchanged alert" do
          post :view, account: {account_name: @account[:account_name]}, "save-update" => {@account[:id] => "Save"}
          flash[:alert].should eql "Account Name Unchanged. Account Not Updated!"
        end
      end
    end

    describe "if params[:delete] not nil," do
      before do
        @user = User.new(user_name: "test_user", password: "test_pw",
                         password_confirmation: "test_pw", user_email: "test@test.com")
        @user.save
        @account = Account.new(account_name: "test_account", user_id: @user[:id])
        @account.save
      end

      it "flash confirmation message" do
        post :view, delete: { @account[:id] => "Delete Account" }
        flash[:notice].should eql("Account Deleted Successfully!")
      end
    end
  end

  # welcome method examples
  it { should respond_to :welcome }

  describe "GET welcome," do
    describe "when user_id is nil," do
      it "redirects to users/signin view" do
        session[:current_user_id] = nil
        get "welcome"
        expect(response).to redirect_to("/users/signin")
      end
    end

    describe "when user_id is not nil," do
      before do
        @user = User.new(user_name: "test_user", password: "test_pw",
                         password_confirmation: "test_pw", user_email: "test@test.com")
        @user.save
        @account = Account.new(account_name: "test_account", user_id: @user[:id])
        @account.save
        session[:current_user_id] = @user[:id]
        session[:username] = @user[:user_name]
      end

      describe "set/get instance variables," do
        before do
          get :welcome
        end

        it "sets @user_name to session[:username]" do
          expect(assigns(:user_name)).to eql(session[:user_name])
        end

        it "gets @account_names" do
          expect(assigns(:account_names)[0]).to eql("test_account")
        end

        it "gets @account_total" do
          expect(assigns(:account_total)).to be >= 0
        end

        it "gets @categories" do
          expect(assigns(:categories).size).to be >= 0
        end

        it "gets @number_of_account_entries" do
          expect(assigns(:number_of_account_entries)).to be >= 0
        end

        describe "if no categories exist," do
          it "sets last_entry date" do
            expect(assigns(:last_entry)[0]).to eql "No Entries"
          end

          it "sets last_entry amount" do
            expect(assigns(:last_entry)[1]).to eql 0
          end
        end
      end

      describe "if categories and entries exist," do
        before do
          @category = Category.new(category_name: "test_category", account_id: @account[:id])
          @category.save
          @entry = Entry.new(entry_date: Date.civil(2014, 6, 4), entry_amount: 123.45, category_id: @category[:id])
          @entry.save
          get :welcome
        end

        it "gets last_entry date" do
          last_entry_date = assigns(:last_entry)[0]
          expect(last_entry_date).to eql @entry[:entry_date].strftime("%B %-d, %Y")
        end

        it "gets last_entry amount" do
          expect(assigns(:last_entry)[1]).to eql @entry[:entry_amount]
        end

        it "gets @category_saved_amount_map" do
          expect(assigns(:category_saved_amount_map).length).to be > 0
        end
      end

      describe "and account_name is nil," do
        it "renders users/welcome view" do
          session[:current_user_id] = 1
          session[:account_name] = nil
          get :welcome
          expect(response).to render_template("welcome")
        end
      end

      describe "and account_name is not nil," do
        it "renders users/welcome view" do
          session[:current_user_id] = 1
          session[:account_name] = "test_account"
          get :welcome
          expect(response).to render_template("welcome")
        end
      end
    end
  end

  describe "POST welcome," do
    it "redirects to users/welcome view with different account" do
      session[:current_user_id] = 1
      post :welcome, "account_name" => "test_account"
      expect(response).to redirect_to("/users/welcome")
    end
  end

end