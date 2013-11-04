class ShiftAssignmentsController < ApplicationController
  before_action :set_shift_assignment, only: [:show, :edit, :update, :destroy]

  # GET /shift_assignments
  # GET /shift_assignments.json
  def index
    @shift_assignments = ShiftAssignment.all
  end

  # GET /shift_assignments/1
  # GET /shift_assignments/1.json
  def show
  end

  # GET /shift_assignments/new
  def new
    @shift_assignment = ShiftAssignment.new
  end

  # GET /shift_assignments/1/edit
  def edit
  end

  # POST /shift_assignments
  # POST /shift_assignments.json
  def create
    @shift_assignment = ShiftAssignment.new(shift_assignment_params)

    respond_to do |format|
      if @shift_assignment.save
        format.html { redirect_to @shift_assignment, notice: 'Shift assignment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @shift_assignment }
      else
        format.html { render action: 'new' }
        format.json { render json: @shift_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shift_assignments/1
  # PATCH/PUT /shift_assignments/1.json
  def update
    respond_to do |format|
      if @shift_assignment.update(shift_assignment_params)
        format.html { redirect_to @shift_assignment, notice: 'Shift assignment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @shift_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shift_assignments/1
  # DELETE /shift_assignments/1.json
  def destroy
    @shift_assignment.destroy
    respond_to do |format|
      format.html { redirect_to shift_assignments_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shift_assignment
      @shift_assignment = ShiftAssignment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shift_assignment_params
      params.require(:shift_assignment).permit(:start_datetime, :end_datetime, :employee_id, :is_absence, :is_confirmed, :shift_id)
    end
end
