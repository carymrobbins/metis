require 'test_helper'

class ListTest < ActiveSupport::TestCase
  def setup
    User.delete_all
    @user = User.create name: 'John Doe', email: 'johndoe@example.com',
                        password: 'foobar', password_confirmation: 'foobar'
    @list = @user.lists.build name: 'My list'
  end

  def teardown
    @user = nil
  end

  test 'list response to attributes' do
    attrs = [:name, :user_id, :user]
    attrs.each do |attr|
      assert (@list.respond_to? attr), "list.#{attr} did not respond"
    end
  end

  test 'list user should be the user' do
    assert_equal @list.user, @user
  end

  test 'list should be valid' do
    assert @list.valid?
  end

  test 'list orders by name' do
    other_list = @user.lists.build name: 'Zappa'
    assert_equal @user.lists.to_a, [@list, other_list]
  end

  test 'deleting user cascade deletes lists' do
    lists = @user.lists.to_a
    @user.destroy
    assert_not_empty lists
    lists.each do |list|
      assert_empty List.where list.id
    end
  end

  test 'invalid without user' do
    @list.user_id = nil
    refute @list.valid?
  end

  test 'invalid with blank name' do
    @list.name = ' '
    refute @list.valid?
  end

  test 'name is unique for user' do
    dup_list = @user.lists.new name: @list.name
    assert_equal [dup_list.name, dup_list.user_id],
                 [@list.name, @list.user_id]
    refute dup_list.valid?
  end
end
