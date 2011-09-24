require 'spec_helper'

describe User do

  before(:each) do
      @attr = {
        :first_name => "Example",
        :last_name => "User",
        :email => "user@example.com",
        :password => "foobar",
        :password_confirmation => "foobar"
      }
    end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should have a name method that concat the first name and the last name" do
    user = User.new (@attr)
    user.name.should == user.first_name + " " + user.last_name
  end
  
  it "should require a first name and last name" do
      no_name_user = User.new(@attr.merge(:first_name => "", :last_name => ""))
      no_name_user.should_not be_valid
  end
  
  it "should require an email address" do
      no_email_user = User.new(@attr.merge(:email => ""))
      no_email_user.should_not be_valid
  end
  
  it "should reject a first name or a last name that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:first_name => long_name, :last_name => long_name))
    long_name_user.should_not be_valid
  end
  
  it "should accept valid email addresses" do
      addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
      addresses.each do |address|
        valid_email_user = User.new(@attr.merge(:email => address))
        valid_email_user.should be_valid
      end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject duplicate email addresses" do
      # Put a user with given email address into the database.
      User.create!(@attr)
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
  end
  
  it "should reject email addresses identical up to case" do
      upcased_email = @attr[:email].upcase
      User.create!(@attr.merge(:email => upcased_email))
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
  end
  
  describe "password validations" do

      it "should require a password" do
        User.new(@attr.merge(:password => "", :password_confirmation => "")).
          should_not be_valid
      end

      it "should require a matching password confirmation" do
        User.new(@attr.merge(:password_confirmation => "invalid")).
          should_not be_valid
      end
  end
  
  describe "password encryption" do

      before(:each) do
        @user = User.create!(@attr)
      end
      
      describe "authentification method" do
        
        it "should return nil if the email/password combination is invalid" do
          wrong_password_user = User.authenticate( @attr[:email], "wrongpassword")
          wrong_password_user.should be_nil
        end
        
        it "should return nil for an email address with no user" do
          nonexistant_user = User.authenticate( "nonexistant@foo.com", @attr[:password])
          nonexistant_user.should be_nil
        end
        
        it "should return the user on email/password match" do
          matching_user = User.authenticate( @attr[:email], @attr[:password])
          matching_user.should == @user
        end
      
      end
  
  end
  
end
