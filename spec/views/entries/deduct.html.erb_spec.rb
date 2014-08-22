require 'spec_helper'
require "rack_session_access/capybara"

describe "entries/deduct.html.erb page" do

  before :each do
    @user = User.new(user_name: "test_user", password: "test_pw",
                     password_confirmation: "test_pw", user_email: "test@test.com")
    @user.save
    @user_id = User.find_by(user_name: "test_user")[:id]
    page.set_rack_session(:current_user_id => @user_id) # uses rack_session_access gem
    @account = Account.new(account_name: "test_account", user_id: @user_id)
    @account.save
    page.set_rack_session(:account_name => @account[:account_name])
    @category = Category.new(category_name: "test_category", account_id:
                             Account.find_by(account_name: "test_account")[:id])
    @category.save
    page.set_rack_session(:time_difference => 7200)
    visit '/entries/deduct'
  end

  it 'has page heading content' do
    page.should have_content('Deduct Savings Entry')
  end

  it 'has page title' do
    page.should have_title('Deduct Savings Entry')
  end

  it 'renders _menu.html.erb' do
    response.should render_template(partial: "shared/_menu")
  end

  it 'contains account selection options' do
    expect(page).to have_select("entry[account_name]")
  end

  it 'contains category selection options' do
    expect(page).to have_select("entry[category_name]")
  end

  it 'contains entry_amount field' do
    session[:category_name] = "test_category"
    expect(page).to have_field("entry[test_category_entry_amount]")
  end

  it 'contains date selection' do
    expect(page).to have_select("entry[entry_date(1i)]")
  end

  it 'contains date selection' do
    expect(page).to have_select("entry[entry_date(2i)]")
  end

  it 'contains date selection' do
    expect(page).to have_select("entry[entry_date(3i)]")
  end

end
