require 'spec_helper'

describe GroupsController do

  before :all do
    @group = FactoryGirl.create(:group)
  end

  describe "not Logged in" do
    it "GET new" do
      get :new
      assert_response :redirect
    end

    it "should show group" do
      get :show, id: @group
      assert_response :success
    end

    it "GET index" do
      get :index
      assert_response :success
      expect(assigns(:groups)).not_to be_nil
    end

  end

  describe "Logged in" do
    login_user

    it "GET new" do
      get :new
      assert_response :success
    end

    it "should create group" do
      c = Group.count
      post :create, group: { description: @group.description, name: @group.name, user_id: @current_user.id }
      expect(Group.count).to equal(c + 1)
      expect(subject).to redirect_to(group_path(assigns(:group)))
    end

    it "should get edit" do
      @g = FactoryGirl.create(:group, user_id: @current_user.id)
      get :edit, id: @g.id
      assert_response :success
    end

    it "should not get edit" do
      @g = FactoryGirl.create(:group, user_id: 9999999)
      get :edit, id: @g.id
      assert_response :redirect
    end


  end

end



# class GroupsControllerTest < ActionController::TestCase
#   setup do
#     @group = groups(:one)
#   end



#   test "should show group" do
#     get :show, id: @group
#     assert_response :success
#   end

#   test "should get edit" do
#     get :edit, id: @group
#     assert_response :success
#   end

#   test "should update group" do
#     patch :update, id: @group, group: { description: @group.description, name: @group.name, user_id: @group.user_id }
#     assert_redirected_to group_path(assigns(:group))
#   end

#   test "should destroy group" do
#     assert_difference('Group.count', -1) do
#       delete :destroy, id: @group
#     end

#     assert_redirected_to groups_path
#   end
# end
