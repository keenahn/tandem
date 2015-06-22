# Controller for manipulating members
# TODO: clean up, remove most of these actions
# TODO: clean up controller spec too
# TODO: change all magic strings to live in translation dictionaries
class MembersController < ApplicationController
  include Pundit

  before_action :set_member, only: [:show, :edit, :update, :destroy]
  before_action :set_group

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # GET /members
  # GET /members.json
  def index
    if params[:group_id]
      @members = Member.in_group params[:group_id]
    elsif current_user
      @members = policy_scope(Member)
    end

  end

  # GET /members/1
  # GET /members/1.json
  def show
  end

  # GET /members/new
  def new
    @member = Member.new(active: true)
  end

  # GET /members/1/edit
  def edit
  end

  # TODO: fix redirects
  def create
    params.delete(:group_id) if params[:group_id]

    @member = create_member_and_membership(member_params)

    respond_to do |format|
      format.html {
        return render :new unless @member
        # TODO: internationalize
        redirect_to(@group ? group_members_path(@group) : members_path, notice: "Member was successfully created.")
      }

      format.json {
        return render(json: @member.errors, status: :unprocessable_entity) unless @member
        render(:show, status: :created, location: @member)
      }
    end
  end

  # Only responds to json
  def bulk_import
    params.delete(:group_id) if params[:group_id]
    members = params[:members].try(:values)
    return render(json: {error: "No members sumbitted"}, status: :unprocessable_entity) unless members

    rendered_rows = []
    error_rows = []
    members.each do |member_params|
      member_params[:time_zone] = @group.time_zone
      @member = create_member_and_membership(member_params)
      if @member
        rendered_rows << render_to_string(partial: "members/row", locals: { member: @member })
      else
        error_rows << member_params
      end
    end

    if rendered_rows.count > 0
      status = :ok
      # TODO: internationalize
      alert_type = "success"
      bold_message = "Awesome!"
      plural_members = ActionController::Base.helpers.pluralize(rendered_rows.count, "member", "members")
      message = "You imported #{plural_members}"
      locals = { alert_type: alert_type, bold_message: bold_message, message: message }
      alert = render_to_string(partial: "bootstrap/dismissable_alert", locals: locals)
    else
      status = :unprocessable_entity
      alert_type = "error"
      alert = nil
    end


    return render(json: { rendered_rows: rendered_rows, error_rows: error_rows, alert: alert}, status: status)
  end

  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update

    respond_to do |format|
      if @member.update(member_params)
        GroupMembership.find_or_create_by(group: @group, member: @member)
        # TODO: internationalize
        format.html { redirect_to @group ? group_members_path(@group) : members_path, notice: "Member was successfully updated." }
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
      # TODO: internationalize
      format.html { redirect_to @group ? group_members_path(@group) : members_path, notice: "Member was successfully destroyed." }
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
    params.require(:member).permit(:name, :phone_number, :active, :time_zone, :gender)
  end

  def create_member_and_membership member_params
    # Build the member object
    member = Member.new(member_params)
    member_saved = member.save

    # Add the member to the group if saved
    return false unless member_saved
    return member unless (member_saved && @group)
    GroupMembership.create(group: @group, member: member)
    member
  end

end
