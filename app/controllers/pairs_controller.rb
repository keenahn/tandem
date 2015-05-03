# Controller for manipulating Pairs
# TODO: clean up, remove most of these actions
# TODO: clean up controller spec too
# TODO: change all magic strings to live in translation dictionaries
class PairsController < ApplicationController

  before_action :set_pair, only: [:show, :edit, :update, :destroy]
  before_action :set_group, except: [:create]

  def index
    if params[:group_id]
      @pairs = Pair.in_group params[:group_id]
    else
      @pairs = Pair.all
    end
  end

  def show
  end

  def new
    @pair = Pair.new
  end

  def edit
  end

  def create
    @pair  = Pair.new(pair_params)
    @group = @pair.group
    @pair.set_all_reminder_times(params[:reminder_time])

    respond_to do |format|
      if @pair.save
        format.html { redirect_to group_pairs_path(@pair.group), notice: "Pair was successfully created." }
        format.json { render :show, status: :created, location: @pair }
      else
        format.html { render :new }
        format.json { render json: @pair.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|

      @pair.set_all_reminder_times(params[:reminder_time])
      @pair.update_attributes(pair_params)
      if @pair.save
        format.html { redirect_to group_pairs_path(@pair.group), notice: "Pair was successfully updated." }
        format.json { render :show, status: :ok, location: @pair }
      else
        format.html { render :edit }
        format.json { render json: @pair.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @pair.destroy
    respond_to do |format|
      format.html { redirect_to pairs_url, notice: "Pair was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_pair
    @pair = Pair.find(params[:id])
  end

  def set_group
    @group = Group.find_by_id params[:group_id] # if nested under group
    @group = @pair.group if @pair && !@group    # If not nested, but we're given a pair
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def pair_params
    params.require(:pair).permit(
      :active,
      :activity,
      :group_id,
      :member_1_id,
      :member_2_id,
      :time_zone,
    )
  end

end

