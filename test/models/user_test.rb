require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    User.delete_all
    @user = User.new name: 'John Doe', email: 'johndoe@example.com',
                     password: 'foobar', password_confirmation: 'foobar'
  end

  def teardown
    @user = nil
  end

  test 'user response to attributes' do
    attrs = [:name, :email, :password_digest, :password_confirmation,
             :authenticate, :lists]
    attrs.each do |attr|
      assert (@user.respond_to? attr), "user.#{attr} did not respond"
    end
  end

  test 'name must be present' do
    @user.name = ' '
    refute @user.valid?
  end

  test 'email must be present' do
    @user.email = ' '
    refute @user.valid?
  end

  test 'name length must be less than 51 characters' do
    @user.name = 'a' * 51
    refute @user.valid?
  end

  test 'email must check for invalid address' do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                   foo@bar_baz.com foo@bar+baz.com]
    addresses.each do |a|
      @user.email = a
      refute @user.valid?
    end
  end

  test 'email must allow valid address' do
    addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
    addresses.each do |a|
      @user.email = a
      assert @user.valid?
    end
  end

  test 'email address must be unique' do
    u2 = @user.dup
    u2.email.upcase!
    u2.save
    refute @user.valid?
  end

  test 'email address saved as lowercase' do
    @user.email.upcase!
    @user.save
    assert_equal @user.email, @user.email.downcase, 'Email was not downcased.'
  end

  test 'password must be present' do
    @user = User.new name: @user.name, email: @user.email,
                     password: ' ', password_confirmation: ' '
    refute @user.valid?
  end

  test 'password and password_confirmation must match' do
    @user.password_confirmation = 'mismatch'
    refute @user.valid?
  end

  test 'with valid password' do
    @user.save
    found_user = User.find_by_email @user.email
    assert_not_equal @user, found_user.authenticate('invalid')
    assert_equal @user, found_user.authenticate(@user.password)
  end

  test 'short password is not valid' do
    @user = User.new name: @user.name, email: @user.email,
                     password: 'actor', password_confirmation: 'actor'
    refute @user.valid?
  end
end
