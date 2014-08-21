require 'spec_helper'

describe CategoriesController do

  # create method examples
  it { should respond_to :create }

  describe "GET create," do
    describe "when user_id is not nil," do
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

      describe "if @account_names is nil," do
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

      describe "if @account_names is not nil," do
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

    describe "when user_id is nil," do
      it "redirects to users/signin view" do
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
      @account = Account.new(account_name: "test_account", user_id: @user[:id])
      @account.save
      session[:account_name] = @account.account_name
    end

    describe "when account_name equal to session account_name," do
      describe "but category_name already exists," do
        it "flash alert message" do
          @category = Category.new(category_name: "test_category", account_id: @account[:id])
          @category.save
          category_params = { account_name: "test_account", category_name: "test_category" }
          post :create, :category => category_params
          flash[:alert].should eql "Category Name Already Exists!"
        end
      end

      describe "and goal entry is valid," do
        describe "and category is valid," do
          before do
            category_params = { account_name: "test_account", category_name: "test_category",
                                savings_goal: "123.45", "savings_goal_date(1i)" => "2020",
                                "savings_goal_date(2i)" => "12", "savings_goal_date(3i)" => "31" }
            post :create, :category => category_params
          end

          it "flashes notice category creation successful" do
            flash[:notice].should eql "Category Created Successfully!"
          end

          it "sets session[:category_name]" do
            expect(session[:category_name]).to eql "test_category"
          end
        end

        describe "and category is not valid," do
          it "flashed alert message" do
            category_params = { account_name: "test_account", category_name: "" }
            post :create, :category => category_params
            flash[:alert].should_not be_nil
          end
        end
      end

      describe "or date entry is valid but goal not set," do
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

    describe "when account_name not equal to session account_name," do
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

  describe "GET view," do
    before do
      @user = User.new(user_name: "test_user", password: "test_pw",
        password_confirmation: "test_pw", user_email: "test@test.com")
      @user.save
    end

    describe "if session[:current_user_id] is nil," do
      it "redirects to users/signin page" do
        get :view
        expect(response).to redirect_to "/users/signin"
      end
    end

    describe "if session[:current_user_id] is not nil," do
      describe "if @account_names is nil," do
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

      describe "if @account_names not nil," do
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

        describe "if there are category names," do
          before do
            @category = Category.new(category_name: "test_category", account_id: @account[:id],
                                     savings_goal: 1000)
            @category.save
          end

          it "assigns @category_names" do
            get :view
            expect(assigns[:category_names][0]).to eql "test_category"
          end

          it "assigns @category" do
            get :view
            expect(assigns[:category][:category_name]).to eql "test_category"
          end

          describe "if session[:category_name] is nil," do
            it "assigns first category name to session[:category_name]" do
              get :view
              expect(session[:category_name]).to eql "test_category"
            end
          end

          describe "if there are category_entries," do
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

            it "assigns @category_entries_dates_cumulative_amounts" do
              expect(assigns[:category_entries_dates_cumulative_amounts].last.last).to eql 100.0
            end

            it "@category[:savings_goal] not nil" do
              expect(assigns[:goal_percentage]).to eql 10.0
            end

            it "assigns @category_entry_ids" do
              expect(assigns[:category_entry_ids].first).to eql @entryDeduct[:id]
            end
          end

          describe "if there are no category_entries," do
            it "flashes No Entries alert" do
              get :view
              flash[:alert].should eql "No Entries for Selected Category!"
            end
          end
        end

        describe "if there are not category names," do
          it "flashes No Categories alert" do
            get :view
            flash[:alert].should eql "No Categories for Selected Account!"
          end
        end
      end
    end
  end

  describe "POST view," do
    describe "if account and category name not changed," do
      describe "if delete entry submitted," do
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

        describe "and valid deletion," do
          it "flashes notice message" do
            post :view, account_name: @account.account_name, category_name: @category.category_name,
                        delete: { @entryDeduct[:id] => "Delete Entry"}
            flash[:notice].should eql "Entry deleted successfully!"
          end
        end

        describe "but not valid deletion," do
          it "flashes alert message" do
            post :view, account_name: @account.account_name, category_name: @category.category_name,
                        delete: { @entryAdd[:id] => "Delete Entry"}
            flash[:alert].should eql "Invalid entry deletion!<br>
                        Deletion would result in a negative
                        balance in savings history.".html_safe
          end
        end
      end

      describe "if update entry submitted," do
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
          @entryAdd1 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "1",
                                "entry_date(3i)" => "5" , entry_amount: 100,
                                category_id: @category[:id])
          @entryAdd1.save
          @entryDeduct1 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "2",
                                    "entry_date(3i)" => "5" , entry_amount: -50,
                                    category_id: @category[:id])
          @entryDeduct1.save
        end

        describe "if submitted entry date is an invalid format," do
          it "flashes Invalid Date alert message" do
            post :view, account_name: @account.account_name, category_name: @category.category_name,
                        entry: { entry_date: "13/1/2014", entry_amount: @entryAdd1[:entry_amount] },
                                 "save-update" => { @entryAdd1[:id] => "Save" }
            flash[:alert].should eql "Invalid Entry Date Entered!"
          end
        end

        describe "if updated deduction amount is blank," do
          it "flashes Deduction amount cannot be blank alert message" do
            post :view, account_name: @account.account_name, category_name: @category.category_name,
                        entry: { entry_date: "2/5/2014", entry_amount: "" },
                                 "save-update" => { @entryDeduct1[:id] => "Save" }
            flash[:alert].should eql "Deduction amount cannot be blank and must be a positive number!"
          end
        end

        describe "if updated deduction amount is negative," do
          it "flashes Deduction amount must be positive alert message" do
            post :view, account_name: @account.account_name, category_name: @category.category_name,
                        entry: { entry_date: "2/5/2014", entry_amount: -100 },
                                 "save-update" => { @entryDeduct1[:id] => "Save" }
            flash[:alert].should eql "Deduction amount cannot be blank and must be a positive number!"
          end
        end

        describe "if updated deduction amount is zero," do
          it "flashes Deduction amount must be positive alert message" do
            post :view, account_name: @account.account_name, category_name: @category.category_name,
                        entry: { entry_date: "2/5/2014", entry_amount: 0 },
                                 "save-update" => { @entryDeduct1[:id] => "Save" }
            flash[:alert].should eql "Deduction amount cannot be blank and must be a positive number!"
          end
        end

        describe "if updated addition amount is blank," do
          it "flashes Addition amount cannot be blank alert message" do
            post :view, account_name: @account.account_name, category_name: @category.category_name,
                        entry: { entry_date: "1/5/2014", entry_amount: "" },
                                 "save-update" => { @entryAdd1[:id] => "Save" }
            flash[:alert].should eql "Addition amount cannot be blank and must be a positive number!"
          end
        end

        describe "if updated addition amount is negative," do
          it "flashes Addition amount must be positive alert message" do
            post :view, account_name: @account.account_name, category_name: @category.category_name,
                        entry: { entry_date: "1/5/2014", entry_amount: -100 },
                                 "save-update" => { @entryAdd1[:id] => "Save" }
            flash[:alert].should eql "Addition amount cannot be blank and must be a positive number!"
          end
        end

        describe "if updated addition amount is zero," do
          it "flashes Addition amount must be positive alert message" do
            post :view, account_name: @account.account_name, category_name: @category.category_name,
                        entry: { entry_date: "1/5/2014", entry_amount: 0 },
                                 "save-update" => { @entryAdd1[:id] => "Save" }
            flash[:alert].should eql "Addition amount cannot be blank and must be a positive number!"
          end
        end

        describe "if flash alert nil," do
          describe "if entry date or entry amount updated," do
            describe "if original entry a deduction," do
              describe "if date unchanged and amount changed," do
                describe "if deduction greater than original deduction," do
                  describe "if deduction does not result in negative balance," do
                    it "flashes Update Successful message" do
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "2/5/2014", entry_amount: 100 },
                                           "save-update" => { @entryDeduct1[:id] => "Save" }
                      flash[:notice].should eql "Entry Updated Successfully!"
                    end
                  end

                  describe "if deduction results in negative balance," do
                    it "flashes Invalid Update alert" do
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "2/5/2014", entry_amount: 100.01 },
                                           "save-update" => { @entryDeduct1[:id] => "Save" }
                      flash[:alert].should eql "Invalid updated amount for specified date!<br>
                      Amount would result in a negative balance in
                      savings history."
                    end
                  end

                  describe "if deduction does not result in negative future balance," do
                    it "flashes Update Successful message" do
                      @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "3",
                                                "entry_date(3i)" => "5" , entry_amount: -25,
                                                category_id: @category[:id])
                      @entryDeduct2.save
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "2/5/2014", entry_amount: 75 },
                                           "save-update" => { @entryDeduct1[:id] => "Save" }
                      flash[:notice].should eql "Entry Updated Successfully!"
                    end
                  end

                  describe "if deduction results in negative future balance," do
                    it "flashes Invalid Update alert" do
                      @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "3",
                                                "entry_date(3i)" => "5" , entry_amount: -25,
                                                category_id: @category[:id])
                      @entryDeduct2.save
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "2/5/2014", entry_amount: 75.01 },
                                           "save-update" => { @entryDeduct1[:id] => "Save" }
                      flash[:alert].should eql "Invalid updated amount for specified date!<br>
                      Amount would result in a negative balance in
                      savings history."
                    end
                  end
                end

                describe "if deduction less than original deduction," do
                  it "flashes Update Successful message" do
                    post :view, account_name: @account.account_name, category_name: @category.category_name,
                                entry: { entry_date: "2/5/2014", entry_amount: 25 },
                                         "save-update" => { @entryDeduct1[:id] => "Save" }
                    flash[:notice].should eql "Entry Updated Successfully!"
                  end
                end
              end

              describe "if date changed and amount unchanged," do
                describe "if new date earlier than original date," do
                  describe "if new date results in a negative balance #1," do
                    it "flashes Invalid Update alert" do
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "12/5/2013", entry_amount: 50 },
                                           "save-update" => { @entryDeduct1[:id] => "Save" }
                      flash[:alert].should eql "Invalid updated amount for specified date!<br>
                      Amount would result in a negative balance in
                      savings history."
                    end
                  end

                  describe "if new date results in a negative balance #2," do
                    it "flashes Invalid Update alert" do
                      @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                            "entry_date(3i)" => "5" , entry_amount: 50,
                                            category_id: @category[:id])
                      @entryAdd2.save
                      @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "5",
                                                "entry_date(3i)" => "5" , entry_amount: -50.01,
                                                category_id: @category[:id])
                      @entryDeduct2.save
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "3/5/2014", entry_amount: 50.01 },
                                           "save-update" => { @entryDeduct2[:id] => "Save" }
                      flash[:alert].should eql "Invalid updated amount for specified date!<br>
                      Amount would result in a negative balance in
                      savings history."
                    end
                  end

                  describe "if new date does not result in a negative balance," do
                    it "flashes Update Successful message" do
                      @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                            "entry_date(3i)" => "5" , entry_amount: 50,
                                            category_id: @category[:id])
                      @entryAdd2.save
                      @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "5",
                                                "entry_date(3i)" => "5" , entry_amount: -50,
                                                category_id: @category[:id])
                      @entryDeduct2.save
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "3/5/2014", entry_amount: 50 },
                                           "save-update" => { @entryDeduct2[:id] => "Save" }
                      flash[:notice].should eql "Entry Updated Successfully!"
                    end
                  end
                end
                
                describe "if new date later than original date," do
                  it "flashes Update Successful message" do
                    post :view, account_name: @account.account_name, category_name: @category.category_name,
                                entry: { entry_date: "3/5/2014", entry_amount: 50 },
                                         "save-update" => { @entryDeduct1[:id] => "Save" }
                    flash[:notice].should eql "Entry Updated Successfully!"
                  end
                end
              end

              describe "if both date and amount changed," do
                describe "if new date prior to original date," do
                  describe "if new date deduction amount valid #1," do
                    it "flashes Update Successful message" do
                      @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                            "entry_date(3i)" => "5" , entry_amount: 50,
                                            category_id: @category[:id])
                      @entryAdd2.save
                      @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "5",
                                                "entry_date(3i)" => "5" , entry_amount: -25,
                                                category_id: @category[:id])
                      @entryDeduct2.save
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "3/5/2014", entry_amount: 50 },
                                           "save-update" => { @entryDeduct2[:id] => "Save" }
                      flash[:notice].should eql "Entry Updated Successfully!"
                    end
                  end

                  describe "if new date deduction amount valid #2," do
                    it "flashes Update Successful message" do
                      @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                                "entry_date(3i)" => "5" , entry_amount: -25,
                                                category_id: @category[:id])
                      @entryDeduct2.save
                      @entryDeduct3 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "5",
                                                "entry_date(3i)" => "5" , entry_amount: -20,
                                                category_id: @category[:id])
                      @entryDeduct3.save
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "3/5/2014", entry_amount: 25 },
                                           "save-update" => { @entryDeduct3[:id] => "Save" }
                      flash[:notice].should eql "Entry Updated Successfully!"
                    end
                  end

                  describe "if new date deduction amount is not valid #1," do
                    it "flashes Invalid Update alert" do
                      @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                            "entry_date(3i)" => "5" , entry_amount: 50,
                                            category_id: @category[:id])
                      @entryAdd2.save
                      @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "5",
                                                "entry_date(3i)" => "5" , entry_amount: -25,
                                                category_id: @category[:id])
                      @entryDeduct2.save
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "3/5/2014", entry_amount: 50.01 },
                                           "save-update" => { @entryDeduct2[:id] => "Save" }
                      flash[:alert].should eql "Invalid updated amount for specified date!<br>
                      Amount would result in a negative balance in
                      savings history."
                    end
                  end

                  describe "if new date deduction amount is not valid #2," do
                    it "flashes Invalid Update alert" do
                      @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                                "entry_date(3i)" => "5" , entry_amount: -25,
                                                category_id: @category[:id])
                      @entryDeduct2.save
                      @entryDeduct3 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "5",
                                                "entry_date(3i)" => "5" , entry_amount: -20,
                                                category_id: @category[:id])
                      @entryDeduct3.save
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "3/5/2014", entry_amount: 25.01 },
                                           "save-update" => { @entryDeduct3[:id] => "Save" }
                      flash[:alert].should eql "Invalid updated amount for specified date!<br>
                      Amount would result in a negative balance in
                      savings history."
                    end
                  end
                end

                describe "if new date later than original date," do
                  describe "if new date deduction amount valid #3," do
                    it "flashes Update Successful message" do
                      @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "3",
                                                "entry_date(3i)" => "5" , entry_amount: -50,
                                                category_id: @category[:id])
                      @entryDeduct2.save
                      @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                            "entry_date(3i)" => "5" , entry_amount: 50,
                                            category_id: @category[:id])
                      @entryAdd2.save
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "5/5/2014", entry_amount: 100 },
                                           "save-update" => { @entryDeduct2[:id] => "Save" }
                      flash[:notice].should eql "Entry Updated Successfully!"
                    end
                  end

                  describe "if new date deduction amount is not valid #3," do
                    it "flashes Invalid Update alert" do
                      @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "3",
                                                "entry_date(3i)" => "5" , entry_amount: -50,
                                                category_id: @category[:id])
                      @entryDeduct2.save
                      @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                            "entry_date(3i)" => "5" , entry_amount: 50,
                                            category_id: @category[:id])
                      @entryAdd2.save
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "5/5/2014", entry_amount: 100.01 },
                                           "save-update" => { @entryDeduct2[:id] => "Save" }
                      flash[:alert].should eql "Invalid updated amount for specified date!<br>
                      Amount would result in a negative balance in
                      savings history."
                    end
                  end
                  
                  describe "if new date deduction amount valid #4," do
                    it "flashes Update Successful message" do
                      @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "3",
                                                "entry_date(3i)" => "5" , entry_amount: -25,
                                                category_id: @category[:id])
                      @entryDeduct2.save
                      @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                            "entry_date(3i)" => "5" , entry_amount: 50,
                                            category_id: @category[:id])
                      @entryAdd2.save
                      @entryDeduct3 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "6",
                                                "entry_date(3i)" => "5" , entry_amount: -50,
                                                category_id: @category[:id])
                      @entryDeduct3.save
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "5/5/2014", entry_amount: 50 },
                                           "save-update" => { @entryDeduct2[:id] => "Save" }
                      flash[:notice].should eql "Entry Updated Successfully!"
                    end
                  end

                  describe "if new date deduction amount is not valid #4," do
                    it "flashes Invalid Update alert" do
                      @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "3",
                                                "entry_date(3i)" => "5" , entry_amount: -25,
                                                category_id: @category[:id])
                      @entryDeduct2.save
                      @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                            "entry_date(3i)" => "5" , entry_amount: 50,
                                            category_id: @category[:id])
                      @entryAdd2.save
                      @entryDeduct3 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "6",
                                                "entry_date(3i)" => "5" , entry_amount: -50,
                                                category_id: @category[:id])
                      @entryDeduct3.save
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "5/5/2014", entry_amount: 50.01 },
                                           "save-update" => { @entryDeduct2[:id] => "Save" }
                      flash[:alert].should eql "Invalid updated amount for specified date!<br>
                      Amount would result in a negative balance in
                      savings history."
                    end
                  end
                end
              end
            end

            describe "if original entry an addition," do
              describe "if date unchanged and amount changed," do
                describe "if addition less than original addition," do
                  describe "if smaller addition does not result in negative future balance," do
                    it "flashes Update Successful message" do
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "1/5/2014", entry_amount: 50 },
                                           "save-update" => { @entryAdd1[:id] => "Save" }
                      flash[:notice].should eql "Entry Updated Successfully!"
                    end
                  end

                  describe "if smaller addition results in negative future balance," do
                    it "flashes Invalid Update alert" do
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "1/5/2014", entry_amount: 49.99 },
                                           "save-update" => { @entryAdd1[:id] => "Save" }
                      flash[:alert].should eql "Invalid updated amount for specified date!<br>
                      Amount would result in a negative balance in
                      savings history."
                    end
                  end
                end

                describe "if addition greater than original addition," do
                  it "flashes Update Successful message" do
                    post :view, account_name: @account.account_name, category_name: @category.category_name,
                                entry: { entry_date: "1/5/2014", entry_amount: 150 },
                                         "save-update" => { @entryAdd1[:id] => "Save" }
                    flash[:notice].should eql "Entry Updated Successfully!"
                  end
                end
              end

              describe "if date changed and amount unchanged," do
                describe "if new date later than original date," do
                  describe "results in negative balance," do
                    it "flashes Invalid Update alert" do
                      @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "3",
                                            "entry_date(3i)" => "5" , entry_amount: 50,
                                            category_id: @category[:id])
                      @entryAdd2.save
                      @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                                "entry_date(3i)" => "5" , entry_amount: -50.01,
                                                category_id: @category[:id])
                      @entryDeduct2.save
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "5/5/2014", entry_amount: 50 },
                                           "save-update" => { @entryAdd2[:id] => "Save" }
                      flash[:alert].should eql "Invalid updated amount for specified date!<br>
                      Amount would result in a negative balance in
                      savings history."
                    end
                  end

                  describe "does not result in negative balance," do
                  it "flashes Update Successful message" do
                      @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "3",
                                            "entry_date(3i)" => "5" , entry_amount: 50,
                                            category_id: @category[:id])
                      @entryAdd2.save
                      @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                                "entry_date(3i)" => "5" , entry_amount: -50,
                                                category_id: @category[:id])
                      @entryDeduct2.save
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "5/5/2014", entry_amount: 50 },
                                           "save-update" => { @entryAdd2[:id] => "Save" }
                      flash[:notice].should eql "Entry Updated Successfully!"
                    end
                  end
                end

                describe "if new date earlier than original date," do
                  it "flashes Update Successful message" do
                    @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                              "entry_date(3i)" => "5" , entry_amount: -50,
                                              category_id: @category[:id])
                    @entryDeduct2.save
                    @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "5",
                                          "entry_date(3i)" => "5" , entry_amount: 50,
                                          category_id: @category[:id])
                    @entryAdd2.save
                    post :view, account_name: @account.account_name, category_name: @category.category_name,
                                entry: { entry_date: "3/5/2014", entry_amount: 50 },
                                         "save-update" => { @entryAdd2[:id] => "Save" }
                    flash[:notice].should eql "Entry Updated Successfully!"
                  end
                end
              end

              describe "if both date and amount changed," do
                describe "if new date prior to original date," do
                  describe "if new addition amount less than original amount," do
                    describe "if new date amount valid" do
                      it "flashes Update Successful message" do
                        @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                                  "entry_date(3i)" => "5" , entry_amount: -50,
                                                  category_id: @category[:id])
                        @entryDeduct2.save
                        @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "5",
                                              "entry_date(3i)" => "5" , entry_amount: 50,
                                              category_id: @category[:id])
                        @entryAdd2.save
                        @entryDeduct3 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "6",
                                                  "entry_date(3i)" => "5" , entry_amount: -25,
                                                  category_id: @category[:id])
                        @entryDeduct3.save
                        post :view, account_name: @account.account_name, category_name: @category.category_name,
                                    entry: { entry_date: "3/5/2014", entry_amount: 25 },
                                             "save-update" => { @entryAdd2[:id] => "Save" }
                        flash[:notice].should eql "Entry Updated Successfully!"
                      end
                    end

                    describe "if new date amount not valid" do
                      it "flashes Invalid Update alert" do
                        @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                                  "entry_date(3i)" => "5" , entry_amount: -50,
                                                  category_id: @category[:id])
                        @entryDeduct2.save
                        @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "5",
                                              "entry_date(3i)" => "5" , entry_amount: 50,
                                              category_id: @category[:id])
                        @entryAdd2.save
                        @entryDeduct3 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "6",
                                                  "entry_date(3i)" => "5" , entry_amount: -25,
                                                  category_id: @category[:id])
                        @entryDeduct3.save
                        post :view, account_name: @account.account_name, category_name: @category.category_name,
                                    entry: { entry_date: "3/5/2014", entry_amount: 24.99 },
                                             "save-update" => { @entryAdd2[:id] => "Save" }
                        flash[:alert].should eql "Invalid updated amount for specified date!<br>
                      Amount would result in a negative balance in
                      savings history."
                      end
                    end
                  end

                  describe "if new addition amount greater than original amount," do
                    it "flashes Update Successful message" do
                      @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                                "entry_date(3i)" => "5" , entry_amount: -50,
                                                category_id: @category[:id])
                      @entryDeduct2.save
                      @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "5",
                                            "entry_date(3i)" => "5" , entry_amount: 25,
                                            category_id: @category[:id])
                      @entryAdd2.save
                      @entryDeduct3 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "6",
                                                "entry_date(3i)" => "5" , entry_amount: -25,
                                                category_id: @category[:id])
                      @entryDeduct3.save
                      post :view, account_name: @account.account_name, category_name: @category.category_name,
                                  entry: { entry_date: "3/5/2014", entry_amount: 25.01 },
                                           "save-update" => { @entryAdd2[:id] => "Save" }
                      flash[:notice].should eql "Entry Updated Successfully!"
                    end
                  end
                end

                describe "if new date after original date," do
                  describe "if new amount less than original amount," do
                    describe "if date amount is valid #1," do
                      it "flashes Update Successful message" do
                        @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "3",
                                                  "entry_date(3i)" => "5" , entry_amount: -25,
                                                  category_id: @category[:id])
                        @entryDeduct2.save
                        @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                               "entry_date(3i)" => "5" , entry_amount: 50,
                                               category_id: @category[:id])
                        @entryAdd2.save
                        @entryDeduct3 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "5",
                                                  "entry_date(3i)" => "5" , entry_amount: -25,
                                                  category_id: @category[:id])
                        @entryDeduct3.save
                        post :view, account_name: @account.account_name, category_name: @category.category_name,
                                    entry: { entry_date: "6/5/2014", entry_amount: 25 },
                                             "save-update" => { @entryAdd2[:id] => "Save" }
                        flash[:notice].should eql "Entry Updated Successfully!"
                      end
                    end

                    describe "if date amount is not valid #1," do
                      it "flashes Invalid Update alert" do
                        @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "3",
                                                  "entry_date(3i)" => "5" , entry_amount: -25,
                                                  category_id: @category[:id])
                        @entryDeduct2.save
                        @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                               "entry_date(3i)" => "5" , entry_amount: 50,
                                               category_id: @category[:id])
                        @entryAdd2.save
                        @entryDeduct3 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "5",
                                                  "entry_date(3i)" => "5" , entry_amount: -25.01,
                                                  category_id: @category[:id])
                        @entryDeduct3.save
                        post :view, account_name: @account.account_name, category_name: @category.category_name,
                                    entry: { entry_date: "6/5/2014", entry_amount: 25 },
                                             "save-update" => { @entryAdd2[:id] => "Save" }
                        flash[:alert].should eql "Invalid updated amount for specified date!<br>
                      Amount would result in a negative balance in
                      savings history."
                      end
                    end

                    describe "if date amount is valid #2," do
                      it "flashes Update Successful message" do
                        @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "3",
                                               "entry_date(3i)" => "5" , entry_amount: 50.01,
                                               category_id: @category[:id])
                        @entryAdd2.save
                        @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                                  "entry_date(3i)" => "5" , entry_amount: -50,
                                                  category_id: @category[:id])
                        @entryDeduct2.save
                        @entryDeduct3 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "6",
                                                  "entry_date(3i)" => "5" , entry_amount: -50,
                                                  category_id: @category[:id])
                        @entryDeduct3.save
                        post :view, account_name: @account.account_name, category_name: @category.category_name,
                                    entry: { entry_date: "5/5/2014", entry_amount: 50 },
                                             "save-update" => { @entryAdd2[:id] => "Save" }
                        flash[:notice].should eql "Entry Updated Successfully!"
                      end
                    end

                    describe "if date amount is not valid #2," do
                      it "flashes Invalid Update alert" do
                        @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "3",
                                               "entry_date(3i)" => "5" , entry_amount: 50.01,
                                               category_id: @category[:id])
                        @entryAdd2.save
                        @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                                  "entry_date(3i)" => "5" , entry_amount: -50,
                                                  category_id: @category[:id])
                        @entryDeduct2.save
                        @entryDeduct3 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "6",
                                                  "entry_date(3i)" => "5" , entry_amount: -50.01,
                                                  category_id: @category[:id])
                        @entryDeduct3.save
                        post :view, account_name: @account.account_name, category_name: @category.category_name,
                                    entry: { entry_date: "5/5/2014", entry_amount: 50 },
                                             "save-update" => { @entryAdd2[:id] => "Save" }
                        flash[:alert].should eql "Invalid updated amount for specified date!<br>
                      Amount would result in a negative balance in
                      savings history."
                      end
                    end
                  end

                  describe "if new amount greater than original amount," do
                    describe "if date amount is valid" do
                      it "flashes Update Successful message" do
                        @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "3",
                                                  "entry_date(3i)" => "5" , entry_amount: -25,
                                                  category_id: @category[:id])
                        @entryDeduct2.save
                        @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                               "entry_date(3i)" => "5" , entry_amount: 50,
                                               category_id: @category[:id])
                        @entryAdd2.save
                        @entryDeduct3 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "5",
                                                  "entry_date(3i)" => "5" , entry_amount: -25,
                                                  category_id: @category[:id])
                        @entryDeduct3.save
                        post :view, account_name: @account.account_name, category_name: @category.category_name,
                                    entry: { entry_date: "6/5/2014", entry_amount: 50.01 },
                                             "save-update" => { @entryAdd2[:id] => "Save" }
                        flash[:notice].should eql "Entry Updated Successfully!"
                      end
                    end
                    
                    describe "if date amount is not valid" do
                      it "flashes Invalid Update alert" do
                        @entryDeduct2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "3",
                                                  "entry_date(3i)" => "5" , entry_amount: -25.01,
                                                  category_id: @category[:id])
                        @entryDeduct2.save
                        @entryAdd2 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "4",
                                               "entry_date(3i)" => "5" , entry_amount: 50,
                                               category_id: @category[:id])
                        @entryAdd2.save
                        @entryDeduct3 = Entry.new("entry_date(1i)" => "2014", "entry_date(2i)" => "5",
                                                  "entry_date(3i)" => "5" , entry_amount: -25,
                                                  category_id: @category[:id])
                        @entryDeduct3.save
                        post :view, account_name: @account.account_name, category_name: @category.category_name,
                                    entry: { entry_date: "6/5/2014", entry_amount: 50.01 },
                                             "save-update" => { @entryAdd2[:id] => "Save" }
                        flash[:alert].should eql "Invalid updated amount for specified date!<br>
                      Amount would result in a negative balance in
                      savings history."
                      end
                    end
                  end
                end
              end
            end
          end

          describe "if addition entry date and amount parameters unchanged," do
            it "flashes Entry Not Updated message" do
              post :view, account_name: @account.account_name, category_name: @category.category_name,
                          entry: { entry_date: "1/5/2014", entry_amount: 100 },
                                   "save-update" => { @entryAdd1[:id] => "Save" }
              flash[:alert].should eql "Entry Parameters Unchanged. Entry Not Updated!"
            end
          end

          describe "if deduction entry date and amount parameters unchanged," do
            it "flashes Entry Not Updated message" do
              post :view, account_name: @account.account_name, category_name: @category.category_name,
                          entry: { entry_date: "2/5/2014", entry_amount: 50 },
                                   "save-update" => { @entryDeduct1[:id] => "Save" }
              flash[:alert].should eql "Entry Parameters Unchanged. Entry Not Updated!"
            end
          end
        end
      end
    end

    describe "if account not changed and category changed," do
      it "sets session[:category_name] to submitted category name" do
        session[:account_name] = "test_account"
        session[:category_name] = "test_category1"
        post :view, account_name: "test_account", category_name: "test_category2"
        expect(session[:category_name]).to eql "test_category2"
      end
    end

    describe "if account changed," do
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
