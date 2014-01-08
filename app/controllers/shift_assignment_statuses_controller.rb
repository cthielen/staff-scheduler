class ShiftAssignmentStatusesController < ApplicationController
  before_action :set_shift_assignment_status, only: [:show, :edit, :update, :destroy]

  # GET /shift_assignment_statuses
  # GET /shift_assignment_statuses.json
  def index
    @shift_assignment_statuses = ShiftAssignmentStatus.all
  end

  # GET /shift_assignment_statuses/1
  # GET /shift_assignment_statuses/1.json
  def show
  end

  # GET /shift_assignment_statuses/new
  def new
    @shift_assignment_status = ShiftAssignmentStatus.new
  end

  # GET /shift_assignment_statuses/1/edit
  def edit
  end

  # POST /shift_assignment_statuses
  # POST /shift_assignment_statuses.json
  def create
    @shift_assignment_status = ShiftAssignmentStatus.new(shift_assignment_status_params)

    respond_to do |format|
      if @shift_assignment_status.save
        format.html { redirect_to @shift_assignment_status, notice: 'Shift assignment status was successfully created.' }
        format.json { render action: 'show', status: :created, location: @shift_assignment_status }
      else
        format.html { render action: 'new' }
        format.json { render json: @shift_assignment_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shift_assignment_statuses/1
  # PATCH/PUT /shift_assignment_statuses/1.json
  def update
    respond_to do |format|
      if @shift_assignment_status.update(shift_assignment_status_params)
        format.html { redirect_to @shift_assignment_status, notice: 'Shift assignment status was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @shift_assignment_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shift_assignment_statuses/1
  # DELETE /shift_assignment_statuses/1.json
  def destroy
    @shift_assignment_status.destroy
    respond_to do |format|
      format.html { redirect_to shift_assignment_statuses_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shift_assignment_status
      @shift_assignment_status = ShiftAssignmentStatus.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shift_assignment_status_params
      params.require(:shift_assignment_status).permit(:name)
    end
end
