require 'spec_helper'

describe UsersController do

  # signin method examples
  it { should respond_to :signin }
  
  describe "GET signin" do
    it "renders users/signin view" do
      get :signin
      expect(response).to render_template("signin")
    end
  end
  
  describe "POST signin" do
    before do
      @user = User.new(user_name: "test_user", password: "test_pw", 
                       password_confirmation: "test_pw", user_email: "test@test.com")
      @user.save
    end
    
    describe "when user authenticated" do
      it "redirects to users/welcome view" do
        post :signin, "username" => @user.user_name, "password" => @user.password
        expect(response).to redirect_to("/users/welcome")
      end
    end
    
    describe "when user not authenticated" do
      it "flashes a invalid credentials alert" do
        post :signin, "username" => @user.user_name, "password" => "invalid_pw"
        flash[:alert].should eql("Credentials Invalid. Please try again!")
      end
    end
    
    describe "when username is blank" do
      it "flashes a invalid credentials alert" do
        post :signin, "username" => "", "password" => "test_pw"
        flash[:alert].should eql("Credentials Invalid. Please try again!") 
      end
    end
  end
  
  # registration method examples
  it { should respond_to :registration }
  
  describe "GET registration" do
    it "renders users/registration view" do
      get :registration
      expect(response).to render_template("registration")
    end
  end
  
  describe "POST registration" do
    before do
      @user_params = { user_name: "test_user", password: "test_pw", 
                       password_confirmation: "test_pw", user_email: "test@test.com" }
    end
    
    describe "when successful" do
      it "renders users/signin view" do
        post :registration, :user => @user_params
        expect(response).to redirect_to("/")
      end
    end
    
    describe "when not successful" do
      it "flashes a registration error message" do
        @user_params[:user_name] = ""
        post :registration, :user => @user_params
        flash[:alert].should_not be_nil
      end
    end
  end
  
  # welcome method examples
  it { should respond_to :welcome }
  
  describe "GET welcome" do
    describe "when user_id is nil" do
      it "redirects to users/signin view" do
        session[:current_user_id] = nil
        get "welcome"
        expect(response).to redirect_to("/users/signin")
      end
    end
    
    describe "when user_id is not nil" do
      describe "and account_name is nil" do
        it "renders users/welcome view" do
          session[:current_user_id] = 1
          session[:account_name] = nil
          get :welcome
          expect(response).to render_template("welcome")
        end
      end
      
      describe "and account_name is not nil" do
        it "renders users/welcome view" do
          session[:current_user_id] = 1
          session[:account_name] = "test_account"
          get :welcome
          expect(response).to render_template("welcome")
        end
      end
    end
  end
  
  describe "POST welcome" do
    it "renders users/welcome view with different account" do
      session[:current_user_id] = 1
      post :welcome, "account_name" => "test_account"
      expect(response).to redirect_to("/users/welcome")
    end
  end
  
  # view method examples
  it { should respond_to :view }
  
  describe "GET view" do
    it "renders users/view" do
      session[:current_user_id] = 1
      get :view
      expect(response).to render_template("view")
    end
  end

end