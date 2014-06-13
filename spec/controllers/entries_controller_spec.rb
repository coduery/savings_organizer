require 'spec_helper'

describe EntriesController do

  # add method examples
  it { should respond_to :add }

  describe '#add' do
    context 'when request.get?' do
      context 'curret_user_id not nil?' do
        context 'when categories not empty?' do
          xit 'flash alert nil' do
            session[:current_user_id] = 1
            flash[:alert].should be_nil
          end
        end
        context 'when categories empty?' do
          xit 'flash alert message' do
            session[:current_user_id] = 1
            flash[:alert].should eql "No Categories for Savings Account!  Must create at least one category."
          end
        end
      end
      # context 'curret_user_id nil?' do
#
      # end
    end

    # context 'when request.post?' do
#
    # end
  end

  # deduct method examples
  describe "#deduct" do
    it { should respond_to :deduct }

    describe "GET deduct" do
      describe "with valid user id" do
        it "renders entries/deduct view" do
          session[:current_user_id] = 1
          get :deduct
          expect(response).to render_template("deduct")
        end
      end

      describe "with invalid user id" do
        it "redirects to users/signin view" do
          session[:current_user_id] = nil
          get :deduct
          expect(response).to redirect_to("/users/signin")
        end
      end
    end

    describe "POST deduct" do
      before :each do
        @user = User.new(user_name: "test_user", password: "test_pw",
                         password_confirmation: "test_pw", user_email: "test@test.com")
        @user.save
        user_id = User.find_by(user_name: "test_user")[:id]
        session[:current_user_id] = user_id
        @account = Account.new(account_name: "test_account", user_id: user_id)
        @account.save
        session[:account_name] = "test_account"
        account_id = Account.find_by(account_name: "test_account")[:id]
        @category = Category.new(category_name: "test_category", account_id: account_id)
        @category.save
      end

      describe "when account selection changed," do
        it "session account_name changes" do
          post :deduct, :entry => { account_name: "test_account2" }
          session[:account_name].should eql "test_account2"
        end
      end
    end

  end

end
