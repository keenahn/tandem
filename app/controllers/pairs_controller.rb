# Controller for manipulating Pairs
# TODO: clean up, remove most of these actions
# TODO: clean up controller spec too
# TODO: change all magic strings to live in translation dictionaries
class PairsController < ApplicationController

  before_action :set_pair, only: [:show, :edit, :update, :destroy]

  # GET /pairs
  # GET /pairs.json
  def index
    @pairs = Pair.all
  end

  # GET /pairs/1
  # GET /pairs/1.json
  def show
  end

  # GET /pairs/new
  def new
    @pair = Pair.new
  end

  # GET /pairs/1/edit
  def edit
  end

  # POST /pairs
  # POST /pairs.json
  def create
    @pair = Pair.new(pair_params)

    respond_to do |format|
      if @pair.save
        format.html { redirect_to @pair, notice: "Pair was successfully created." }
        format.json { render :show, status: :created, location: @pair }
      else
        format.html { render :new }
        format.json { render json: @pair.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pairs/1
  # PATCH/PUT /pairs/1.json
  def update
    respond_to do |format|
      if @pair.update(pair_params)
        format.html { redirect_to @pair, notice: "Pair was successfully updated." }
        format.json { render :show, status: :ok, location: @pair }
      else
        format.html { render :edit }
        format.json { render json: @pair.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pairs/1
  # DELETE /pairs/1.json
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

  # Never trust parameters from the scary internet, only allow the white list through.
  def pair_params
    # params[:pair]
    params.require(:pair).permit(:group_id, :member_1_id, :member_2_id)
  end

end
