# Controller for manipulating members
# TODO: clean up, remove most of these actions
# TODO: clean up controller spec too
# TODO: change all magic strings to live in translation dictionaries
class MembersController < ApplicationController

  before_action :set_member, only: [:show, :edit, :update, :destroy]
  before_action :set_group

  # GET /members
  # GET /members.json
  def index
    if params[:group_id]
      @members = Member.in_group params[:group_id]
    else
      @members = Member.all
    end

  end

  # GET /members/1
  # GET /members/1.json
  def show
  end

  # GET /members/new
  def new
    @member = Member.new
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members
  # POST /members.json
  # POST /group/:group_id/members
  # POST /group/:group_id/members.json
  def create
    params.delete(:group_id) if params[:group_id]

    # Build the member object
    @member = Member.new(member_params)
    member_saved = @member.save

    # Add the member to the group if
    create_membership if member_saved && @group

    respond_to do |format|
      format.html {
        return render :new unless member_saved
        redirect_to(@member, notice: "Member was successfully created.")
      }

      format.json {
        return render(json: @member.errors, status: :unprocessable_entity) unless member_saved
        render(:show, status: :created, location: @member)
      }
    end
  end

  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to @member, notice: "Member was successfully updated." }
        format.json { render :show, status: :ok, location: @member }
      else
        format.html { render :edit }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    @member.destroy
    respond_to do |format|
      format.html { redirect_to members_url, notice: "Member was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_member
    @member = Member.find params[:id]
  end

  def set_group
    @group = Group.find_by_id params[:group_id] # if nested under group
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def member_params
    params.require(:member).permit(:name, :phone_number, :active)
  end

  def create_membership
    GroupMembership.create(group: @group, member: @member) if @group && @member
  end


end
