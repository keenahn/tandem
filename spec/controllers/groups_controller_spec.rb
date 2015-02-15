require "spec_helper"

describe GroupsController do

  describe "Not Logged in" do
    let(:g) { FactoryGirl.create(:group) }

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
      get :show, id: g
      expect(response.status).to eq(302)
    end

    it "should not get edit" do
      get :edit, id: g.id
      expect(subject).to redirect_to(root_path)
    end
  end

  describe "Logged in" do

    login_user

    describe "has permission" do

      let(:g) { FactoryGirl.create(:group, owner_id: subject.current_user.id) }

      it "GET new" do
        get :new
        expect(response.status).to eq(200)
      end

      it "should create group" do
        c = Group.count
        gr = FactoryGirl.build(:group)
        post :create, group: { description: gr.description , name: gr.name, owner_id: subject.current_user.id }
        expect(Group.count).to equal(c + 1)
        expect(subject).to redirect_to(group_path(assigns(:group)))
      end

      it "should get edit" do
        get :edit, id: g.id
        expect(response.status).to eq(200)
      end

      it "GET index" do
        get :index
        expect(response.status).to eq(200)
        expect(assigns(:groups)).not_to be_nil
      end

      it "should show group" do
        get :show, id: g.id
        expect(response.status).to eq(200)
      end

      it "should update group" do
        patch :update, id: g, group: { description: g.description + " derp", name: g.name,  owner_id: subject.current_user.id }
        expect(subject).to redirect_to(group_path(assigns(:group)))
      end

      it "should destroy group" do
        expect(Group.find_by_id g.id).to_not be_nil
        delete :destroy, id: g.id
        expect(Group.find_by_id g.id).to be_nil
        expect(subject).to redirect_to(groups_path)
      end
    end

    describe "does not have permission" do

      let(:g) { FactoryGirl.create(:group, owner_id: 9999999) }

      it "should not get edit" do
        get :edit, id: g.id
        expect(subject).to redirect_to(root_path)
      end

      it "should not update" do
        patch :update, id: g, group: { description: g.description + " derp", name: g.name,  owner_id: subject.current_user.id }
        expect(subject).to redirect_to(root_path)
      end

      it "should not show group" do
        get :show, id: g.id
        expect(subject).to redirect_to(root_path)
      end

      it "should not destroy group" do
        c = Group.count
        delete :destroy, id: g.id
        expect(Group.find_by_id g.id).to_not be_nil
        expect(subject).to redirect_to(root_path)
      end
    end
  end

end
