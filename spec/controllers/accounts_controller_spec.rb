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
        it "flashes notice account created successfully" do
          account_params = { account_name: "test_account", user_id: @user_id }
          post :create, :account => account_params
          flash[:notice].should eql("Account Created Successfully!")
        end
      end
      
      describe "and account is not valid," do
        it "flash alert is not nil" do
          account_params = { account_name: "", user_id: @user_id }
          post :create, :account => account_params
          flash[:alert].should_not be_nil
        end
      end
    end
  end

end
