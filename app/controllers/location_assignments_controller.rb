class LocationAssignmentsController < ApplicationController
  before_action :set_location_assignment, only: [:show, :edit, :update, :destroy]

  # GET /location_assignments
  # GET /location_assignments.json
  def index
    @location_assignments = LocationAssignment.all
  end

  # GET /location_assignments/1
  # GET /location_assignments/1.json
  def show
  end

  # GET /location_assignments/new
  def new
    @location_assignment = LocationAssignment.new
  end

  # GET /location_assignments/1/edit
  def edit
  end

  # POST /location_assignments
  # POST /location_assignments.json
  def create
    @location_assignment = LocationAssignment.new(location_assignment_params)

    respond_to do |format|
      if @location_assignment.save
        format.html { redirect_to @location_assignment, notice: 'Location assignment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @location_assignment }
      else
        format.html { render action: 'new' }
        format.json { render json: @location_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /location_assignments/1
  # PATCH/PUT /location_assignments/1.json
  def update
    respond_to do |format|
      if @location_assignment.update(location_assignment_params)
        format.html { redirect_to @location_assignment, notice: 'Location assignment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @location_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /location_assignments/1
  # DELETE /location_assignments/1.json
  def destroy
    @location_assignment.destroy
    respond_to do |format|
      format.html { redirect_to location_assignments_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location_assignment
      @location_assignment = LocationAssignment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_assignment_params
      params.require(:location_assignment).permit(:location_id, :employee_id)
    end
end
