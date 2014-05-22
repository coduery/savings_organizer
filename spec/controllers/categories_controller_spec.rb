require 'spec_helper'

describe CategoriesController do

  # create method examples
  it { should respond_to :create }
  
  describe "GET create" do
    describe "when user_id is not nil" do
      it "renders categories/create view" do
        session[:current_user_id] = 1
        get :create
        expect(response).to render_template("create")
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
      @user_id = User.find_by(user_name: "test_user")[:id] 
      session[:current_user_id] = @user_id
      @account = Account.new(account_name: "test_account", user_id: @user_id)
      @account.save
      session[:account_name] = @account.account_name
    end
    
    describe "when account_name equal to session account_name," do
      describe "but category_name already exists" do
        it "flash alert message" do
          @category = Category.new(category_name: "test_category", account_id:
                                   Account.find_by(account_name: "test_account")[:id])
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
        it "flashes alert message" do
          category_params = { account_name: "test_account", category_name: "test_category", 
                              "savings_goal_date(1i)" => "2020", "savings_goal_date(2i)" => "12", 
                              "savings_goal_date(3i)" => "31" }
          post :create, :category => category_params
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
  end
    
  describe "GET view" do
    it "renders categories/view" do
      session[:current_user_id] = 1
      get :view
      expect(response).to render_template("categories/view");
    end
  end  

end
