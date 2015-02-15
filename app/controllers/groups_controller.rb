# Controller for manipulating Groups
# TODO: change all magic strings to live in translation dictionaries
class GroupsController < ApplicationController

  include Pundit
  #->Prelang (scaffolding:rails/scope_to_user)
  before_filter :require_user_signed_in, only: [:index, :new, :edit, :create, :update, :destroy, :show]
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # GET /groups
  # GET /groups.json
  def index
    @groups = policy_scope(Group)
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    authorize @group
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
    authorize @group
    # return redirect_to root_path unless current_user && current_user.id ==
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
    @group.owner = current_user

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: "Group was successfully created." }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    authorize @group
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: "Group was successfully updated." }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    authorize @group
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: "Group was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def group_params
    params.require(:group).permit(:user_id, :name, :description)
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end

end
