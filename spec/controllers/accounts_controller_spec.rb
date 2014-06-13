require 'spec_helper'

describe AccountsController do

  # create method examples
  it { should respond_to :create }

  describe "GET create" do
    describe "when user_id is not nil" do
      it "renders accounts/create view" do
        session[:current_user_id] = 1
        get :create
        expect(response).to render_template("create")
      end
    end

    describe "when user_id is nil" do
      it "redirects to user/signin view" do
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
      @user_id = User.find_by(user_name: "test_user")[:id]
      session[:current_user_id] = @user_id
    end

    describe "when account_name does exist" do
      it "flashes alert message to user" do
        @account = Account.new(account_name: "test_account", user_id: @user_id)
        @account.save
        account_params = { account_name: @account.account_name, user_id: @user_id }
        post :create, :account => account_params
        flash[:alert].should eql("Account Name Already Exists!")
      end
    end

    describe "when account_name does not exist" do
      describe "and account is valid" do
        before do
          account_params = { account_name: "test_account", user_id: @user_id }
          post :create, :account => account_params
        end

        it "flashes notice account created successfully" do
          flash[:notice].should eql("Account Created Successfully!")
        end

        it "redirects to accounts.create" do
          expect(response).to redirect_to "/accounts/create"
        end
      end

      describe "and account is not valid," do
        before do
          account_params = { account_name: "", user_id: @user_id }
          post :create, :account => account_params
        end

        it "flash alert is not nil" do
          flash[:alert].should_not be_nil
        end

        it "redirects to accounts.create" do
          expect(response).to redirect_to "/accounts/create"
        end
      end
    end
  end

  # create method examples
  it { should respond_to :view }

  describe "GET view" do
    describe "if user_id is not nil" do
      before do
        @user = User.new(user_name: "testuser", password: "testpw",
                         password_confirmation: "testpw",
                         user_email: "test@test.com")
        @user.save
        @account = Account.new(account_name: "testaccount", user_id: @user[:id])
        @account.save
        session[:current_user_id] = @user[:id]
        session[:account_name] = @account[:account_name]
      end

      it "renders accounts/view" do
        get :view
        expect(response).to render_template "view"
      end

      it "assigns account_names" do
        get :view
        expect(assigns[:account_names].size).to eql 1
      end

      describe "if account_names not nil" do
        it "assigns @account_total" do
          get :view
          expect(assigns[:account_total]).to be >= 0
        end

        it "assigns category_names" do
          get :view
          expect(assigns[:category_names].size).to be >= 0
        end

        describe "if no category names exist" do
          it "flashes alert message" do
            get :view
            flash.now[:alert].should eql "No Categories for Selected Account!"
          end
        end

        describe "if category names exist" do
          before do
            @category = Category.new(category_name: "testcategory", account_id: @account[:id])
            @category.save
            get :view
          end

          it "assigns @category_name_id_mapping key" do
            expect(assigns[:category_name_id_mapping].keys.first).to eql @category[:category_name]
          end

          it "assigns @category_name_id_mapping value" do
            expect(assigns[:category_name_id_mapping][@category[:category_name]]).to eql @category[:id]
          end

          it "@category_name_savings_amount_mapping should exist" do
            expect(assigns[:category_name_savings_amount_mapping]).to_not be nil
          end
        end
      end
    end

    describe "if user_id is nil" do
      it "redirects to users/signin page" do
        session[:current_user_id] = nil
        get :view
        expect(response).to redirect_to "/users/signin"
      end
    end
  end

  describe "POST view" do

    it "redirects to accounts/view" do
      post :view
      expect(response).to redirect_to "/accounts/view"
    end

    describe "if session[:account_name] not equal to params[:account_name]" do
      it "sets session[:account_name] to params[:account_name]" do
        session[:account_name] = "testaccount1"
        post :view, account_name: "testaccount2"
        expect(session[:account_name]).to eql "testaccount2"
      end
    end

    describe "if params[:delete] not nil" do
      before do
        @user = User.new(user_name: "testuser", password: "testpw",
                         password_confirmation: "testpw",
                         user_email: "test@test.com")
        @user.save
        @account = Account.new(account_name: "testaccount", user_id: @user[:id])
        @account.save
        @category = Category.new(category_name: "testcategory", account_id: @account[:id])
        @category.save
        #session[:current_user_id] = @user[:id]
        session[:account_name] = @account[:account_name]
      end

      it "flashes notice message" do
        post :view, account_name: @account[:account_name], delete: { @category[:id] => "Delete Category" }
        flash[:notice].should eql "Category Deleted Successfully!"
      end
    end
  end

end
