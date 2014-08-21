require 'spec_helper'

describe AccountsController do

  # create method examples
  it { should respond_to :create }

  describe "GET create" do
    describe "when user_id is not nil," do
      it "renders accounts/create view" do
        session[:current_user_id] = 1
        get :create
        expect(response).to render_template("create")
      end
    end

    describe "when user_id is nil," do
      it "redirects to user/signin view" do
        session[:current_user_id] = nil
        get :create
        expect(response).to redirect_to("/users/signin")
      end
    end
  end

  describe "POST create," do
    before :each do
      @user = User.new(user_name: "test_user", password: "test_pw",
                       password_confirmation: "test_pw", user_email: "test@test.com")
      @user.save
      session[:current_user_id] = @user[:id]
    end

    describe "when account_name does exist," do
      it "flashes alert message to user" do
        @account = Account.new(account_name: "test_account", user_id: @user[:id])
        @account.save
        account_params = { account_name: @account.account_name, user_id: @user[:id] }
        post :create, :account => account_params
        flash[:alert].should eql("Account Name Already Exists!")
      end
    end

    describe "when account_name does not exist," do
      describe "and account is valid," do
        before do
          account_params = { account_name: "test_account", user_id: @user[:id] }
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
          account_params = { account_name: "", user_id: @user[:id] }
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
    describe "if user_id is not nil," do
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

      describe "if account_names not nil," do
        describe "if no category names exist," do
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

          it "assigns @categories" do
            get :view
            expect(assigns[:categories].first[:category_name]).to eql "testcategory"
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

          it "assigns @account_total" do
            get :view
          expect(assigns[:account_total]).to be >= 0
        end

        end
      end

      describe "if account names nil," do
        it "flashes No Accounts alert" do
          @user2 = User.new(user_name: "testuser2", password: "testpw",
                  password_confirmation: "testpw",
                  user_email: "test2@test.com")
          @user2.save
          session[:current_user_id] = @user2[:id]
          get :view
          flash[:alert].should eql "No Accounts for User.  Must create at least one account!"
        end
      end
    end

    describe "if user_id is nil," do
      it "redirects to users/signin page" do
        session[:current_user_id] = nil
        get :view
        expect(response).to redirect_to "/users/signin"
      end
    end
  end

  describe "POST view," do

    it "redirects to accounts/view" do
      post :view
      expect(response).to redirect_to "/accounts/view"
    end

    describe "if session[:account_name] not equal to params[:account_name]," do
      it "sets session[:account_name] to params[:account_name]" do
        session[:account_name] = "testaccount1"
        post :view, account_name: "testaccount2"
        expect(session[:account_name]).to eql "testaccount2"
      end
    end

    describe "if params[:save-update] not nil," do
      before do
        @user = User.new(user_name: "testuser", password: "testpw",
                         password_confirmation: "testpw",
                         user_email: "test@test.com")
        @user.save
        session[:current_user_id] = @user[:id]
        @account = Account.new(account_name: "testaccount", user_id: @user[:id])
        @account.save
        session[:account_name] = @account[:account_name]
        @category1 = Category.new(category_name: "testcategory1", account_id: @account[:id])
        @category1.save
        session[:category_name] = @category1[:category_name]
        @category2 = Category.new(category_name: "testcategory2", account_id: @account[:id])
        @category2.save
      end

      describe "if category params have not changed," do
        it "flashes Category Parameters Unchanged message" do
            post :view, account_name: @account[:account_name],
                        category: { category_name: @category1[:category_name], savings_goal: "", savings_goal_date: "" },
                        "save-update" => { @category1[:id] => "Save" }
            flash[:alert].should eql "Category Parameters Unchanged. Category Not Updated!"
        end
      end

      describe "if category[:category_name] not equal to params[:category][:category_name]," do
        describe "if category name does not exist," do
          it "sets session[:category_name] to new submitted category name" do
            post :view, account_name: @account[:account_name],
                        category: { category_name: "testcategory3", savings_goal: "", savings_goal_date: "" },
                        "save-update" => { @category2[:id] => "Save" }
            expect(session[:category_name]).to eql "testcategory3"
          end
        end

        describe "if category name already exists," do
          it "flashes Category Name Already Exist message" do
            post :view, account_name: @account[:account_name],
                        category: { category_name: "testcategory1" , savings_goal: "", savings_goal_date: ""},
                        "save-update" => { @category2[:id] => "Save" }
            flash[:alert].should eql "Category Name Already Exists. Category Not Updated!"
          end
        end

        describe "if category name is nil" do
          it "flashes Invalid Account Name message" do
            post :view, account_name: @account[:account_name],
                        category: { category_name: "", savings_goal: "", savings_goal_date: "" },
                        "save-update" => { @category2[:id] => "Save" }
            flash[:alert].should eql "Category Name is Required!"
          end
        end
      end

      describe "if category[:savings_goal] not equal to params[:category][:savings_goal]," do
        describe "if params[:category][:savings_goal] is a positive amount," do
          it "sets session[:savings_goal] to new submitted savings goal" do
            post :view, account_name: @account[:account_name],
                        category: { category_name: @category1[:category_name], savings_goal: 1000.0, savings_goal_date: "" },
                        "save-update" => { @category1[:id] => "Save" }
            category = Category.where("id = ?", @category1[:id]).first
            expect(category[:savings_goal]).to eql 1000.0
          end
        end

        describe "if [:category][:savings_goal] is an empty string," do
          describe "if params[:category][:savings_goal_date] is empty" do
            it "flashes Category Updated Successfully message" do
              @category3 = Category.new(category_name: "testcategory3", savings_goal: 1000.0, savings_goal_date: "1/1/2020",
                                        account_id: @account[:id])
              @category3.save
              session[:category_name] = @category3[:category_name]
              post :view, account_name: @account[:account_name],
                          category: { category_name: @category3[:category_name], savings_goal: "", savings_goal_date: "" },
                          "save-update" => { @category3[:id] => "Save" }
              flash[:notice].should eql "Category Updated Successfully!"
            end
          end
        end

        describe "if [:category][:savings_goal] is an empty string," do
          describe "if params[:category][:savings_goal_date] is not empty" do
            it "flashes Savings Goal alert message" do
              @category3 = Category.new(category_name: "testcategory3", savings_goal: 1000.0, savings_goal_date: "1/1/2020",
                                        account_id: @account[:id])
              @category3.save
              session[:category_name] = @category3[:category_name]
              post :view, account_name: @account[:account_name],
                          category: { category_name: @category3[:category_name], savings_goal: "", savings_goal_date: "1/1/2020" },
                          "save-update" => { @category3[:id] => "Save" }
              flash[:alert].should eql "Savings Goal Target Date cannot be set without a Savings Goal!"
            end
          end
        end
      end

      describe "if category[:savings_goal_date] not equal to params[:category][:savings_goal_date]," do
        describe "if savings_goal is set," do
          describe "if savings date is valid," do
            it "sets session[:savings_goal_date] to new submitted savings goal date" do
              post :view, account_name: @account[:account_name],
                          category: { category_name: @category1[:category_name], savings_goal: 1000.0,
                          savings_goal_date: "1/1/2020" }, "save-update" => { @category1[:id] => "Save" }
              category = Category.where("id = ?", @category1[:id]).first
              expect(category[:savings_goal_date].strftime("%-m/%-d/%Y")).to eql "1/1/2020"
            end
          end

          describe "if savings date is not valid," do
            it "flashes Invalid Date message" do
              post :view, account_name: @account[:account_name],
                          category: { category_name: @category1[:category_name], savings_goal: 1000.0,
                          savings_goal_date: "111/1/2020" }, "save-update" => { @category1[:id] => "Save" }
              flash[:alert].should eql "Invalid Target Date Entered!"
            end
          end
        end

        describe "if savings_goal is not set," do
          it "flashes Savings Goal must be set alert" do
            post :view, account_name: @account[:account_name],
                        category: { category_name: @category1[:category_name], savings_goal: "",
                        savings_goal_date: "1/1/2020" }, "save-update" => { @category1[:id] => "Save" }
            flash[:alert].should eql "Savings Goal Target Date cannot be set without a Savings Goal!"
          end
        end
      end
    end

    describe "if params[:delete] not nil," do
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
