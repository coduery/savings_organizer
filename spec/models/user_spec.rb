require 'spec_helper'

describe User do

  before :each do
    @user = User.new(user_name: "test_user", password: "test_pw",
                     password_confirmation: "test_pw", user_email: "test@test.com")
  end

  subject { @user }

  it { should respond_to :user_name }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to :user_email }

  it { should be_valid }
  it { should respond_to(:authenticate) }

  describe "when user name is not present" do
    before { @user.user_name = " " }
    it { should_not be_valid }
  end

  describe "when user email is not present" do
    before { @user.user_email = " " }
    it { should_not be_valid }
  end

  describe "when user name is too long" do
    before { @user.user_name = "a" * 21 }
    it { should_not be_valid }
  end

  describe "when password is too long" do
    before { @user.password = "a" * 21 }
    it { should_not be_valid }
  end

  describe "when user email is too long" do
    before { @user.user_email = "a" * 41 }
    it { should_not be_valid }
  end

  describe "when user email invalid pattern" do
    before { @user.user_email = "invalid_email@yahoo..com" }
    it { should_not be_valid }
  end

  describe "when user name already taken" do
    before do
      duplicate_user = @user.dup
      duplicate_user.save
    end
    it { should_not be_valid }
  end

  describe "when password is not present" do
    before do
      @user = User.new(user_name: "test_user", password: " ",
                       password_confirmation: " ", user_email: "test@test.com")
    end
    it { should_not be_valid }
  end

  describe "when passwords do not match" do
    before do
      @user = User.new(user_name: "test_user", password: "test_pw",
                     password_confirmation: "wrong_pw", user_email: "test@test.com")
    end
    it { should_not be_valid }
  end

  describe "when checking password confirmation" do
    before { @user.save }
    let(:user) { User.find_by(user_name: @user.user_name) }

    describe "with valid password" do
      it { should eq user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_invalid_password) { user.authenticate("invalid") }

      it { should_not eq user_invalid_password }
      specify { expect(user_invalid_password).to be_false }
    end
  end

end
