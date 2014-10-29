require 'spec_helper'

describe User do
  before { @user = FactoryGirl.build(:user)}

  subject { @user }

  it{ should respond_to(:name)}
  it{ should respond_to(:email)}
  it{ should respond_to(:password_digest)}
  it{ should respond_to(:password)}
  it{ should respond_to(:password_confirmation)}
  it{ should respond_to(:authenticate)}
  it{ should respond_to(:remember_token)}
  it{ should be_valid }

  it "should have downcase email" do 
    @user.email = "USER@eXample.com"
    @user.save
    @user.reload
    expect(@user.email).to eq("user@example.com")
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a"*(APP_SETTINGS[:list_name_max_length]+1)}
    it { should_not be_valid }
  end

  describe "when email format is not valid" do
    it "should be invalid" do 
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com foo@@bar.com foo@bar..com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn a+b@-baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "when email is already in base" do
    before do 
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save!
    end
    it { should_not be_valid }
  end

  describe "when password is not present" do
    before { @user.password = nil ; @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "when password differs from confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password too short" do
    before { @user.password = @user.password_confirmation = "a"*5 }
    it { should_not be_valid }
  end

  describe "authenticate method return value" do

    describe "when password is wrong" do
      it "should return false" do
        expect(@user.authenticate("wrong_password")).to eq(false)
      end
    end
    describe "when password is right" do
      it "should return false" do
        expect(@user.authenticate("foobar")).to eq(@user)
      end
    end
  end

  # dependencies

  it{ should respond_to(:lists)}
  it{ should respond_to(:cards)}

  # Email Confirmation

  it "cannot change email addr. without password"
  describe "Email confirmation" do

    context "new user" do

      it "shouldn t be confirmed"

      it "email confirmation mail sent, and then confirmation"
      it "email confirmation mail sent, and email changed again and then confirmation should not confirm the mail"
      it "cannot be sent twice in less than 3 hours"
        
    end
  end

end
