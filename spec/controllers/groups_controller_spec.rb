require "spec_helper"

describe GroupsController do

  before :all do
    @group = FactoryGirl.create(:group)
  end

  describe "Not Logged in" do
    it "GET new" do
      get :new
      expect(response.status).to eq(302)
    end

    it "should not GET index" do
      get :index
      expect(response.status).to eq(302)
      expect(assigns(:groups)).to be_nil
    end

    it "should not show group" do
      get :show, id: @group
      expect(response.status).to eq(302)
    end

    it "should not get edit" do
      @g = FactoryGirl.create(:group, owner_id: 9999999)
      get :edit, id: @g.id
      expect(subject).to redirect_to(root_path)
    end

  end

  describe "Logged in" do

    login_user

    describe "has permission" do

      it "GET new" do
        get :new
        expect(response.status).to eq(200)
      end

      it "should create group" do
        c = Group.count
        post :create, group: { description: @group.description, name: @group.name, owner_id: subject.current_user.id }
        expect(Group.count).to equal(c + 1)
        expect(subject).to redirect_to(group_path(assigns(:group)))
      end

      it "should get edit" do
        @g = FactoryGirl.create(:group, owner_id: subject.current_user.id)
        get :edit, id: @g.id
        expect(response.status).to eq(200)
      end

      it "GET index" do
        @g = FactoryGirl.create(:group, owner_id: subject.current_user.id)
        get :index
        expect(response.status).to eq(200)
        expect(assigns(:groups)).not_to be_nil
      end

      it "should show group" do
        @g = FactoryGirl.create(:group, owner_id: subject.current_user.id)
        get :show, id: @g.id
        expect(response.status).to eq(200)
      end

      it "should update group" do
        @g = FactoryGirl.create(:group, owner_id: subject.current_user.id)
        patch :update, id: @g, group: { description: @g.description + " derp", name: @g.name,  owner_id: subject.current_user.id }
        expect(subject).to redirect_to(group_path(assigns(:group)))
      end

      it "should destroy group" do
        @g = FactoryGirl.create(:group, owner_id: subject.current_user.id)
        c = Group.count
        delete :destroy, id: @g
        expect(Group.count).to equal(c - 1)
        expect(subject).to redirect_to(groups_path)
      end
    end

    describe "does not have permission" do
      before :each do
        @g = FactoryGirl.create(:group, owner_id: 9999999)
      end

      it "should not get edit" do
        get :edit, id: @g.id
        expect(subject).to redirect_to(root_path)
      end

      it "should not update" do
        patch :update, id: @g, group: { description: @g.description + " derp", name: @g.name,  owner_id: subject.current_user.id }
        expect(subject).to redirect_to(root_path)
      end

      it "should not show group" do
        get :show, id: @group
        expect(subject).to redirect_to(root_path)
      end

      it "should not destroy group" do
        c = Group.count
        delete :destroy, id: @g
        expect(Group.count).to equal(c)
        expect(subject).to redirect_to(root_path)
      end
    end
  end

end
