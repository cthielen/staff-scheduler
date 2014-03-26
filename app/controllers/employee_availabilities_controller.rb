class EmployeeAvailabilitiesController < ApplicationController
  before_action :set_employee_availability, only: [:show, :edit, :update, :destroy]

  # GET /employee_availabilities
  # GET /employee_availabilities.json
  def index
    if params[:schedule].present? and params[:skill].present? and params[:location].present?
      @employee_availabilities = EmployeeAvailability.with_permissions_to(:read).by_schedule(params[:schedule]).by_skill(params[:skill]).by_location(params[:location])
    elsif params[:schedule].present? and params[:employee].present?
      @employee_availabilities = EmployeeAvailability.with_permissions_to(:read).by_schedule(params[:schedule]).by_employee(params[:employee])
    end
  end

  # GET /employee_availabilities/1
  # GET /employee_availabilities/1.json
  def show
  end

  # GET /employee_availabilities/new
  def new
    @employee_availability = EmployeeAvailability.new
  end

  # GET /employee_availabilities/1/edit
  def edit
  end

  # POST /employee_availabilities
  # POST /employee_availabilities.json
  def create
    @employee_availability = EmployeeAvailability.new(employee_availability_params)

    respond_to do |format|
      if @employee_availability.save
        format.html { redirect_to @employee_availability, notice: 'Employee availability was successfully created.' }
        format.json { render action: 'show', status: :created, location: @employee_availability }
      else
        format.html { render action: 'new' }
        format.json { render json: @employee_availability.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /employee_availabilities/1
  # PATCH/PUT /employee_availabilities/1.json
  def update
    respond_to do |format|
      if @employee_availability.update(employee_availability_params)
        format.html { redirect_to @employee_availability, notice: 'Employee availability was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @employee_availability.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employee_availabilities/1
  # DELETE /employee_availabilities/1.json
  def destroy
    @employee_availability.destroy
    respond_to do |format|
      format.html { redirect_to employee_availabilities_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_employee_availability
      @employee_availability = EmployeeAvailability.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def employee_availability_params
      params.require(:employee_availability).permit(:start_datetime, :end_datetime, :employee_id)
    end
end
