class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]
  wrap_parameters :employee, include: [:max_hours, :email, :name, :is_disabled, :profile, :organization_id, :employee_availabilities_attributes, :location_assignments_attributes, :skill_assignments_attributes, :shift_assignments_attributes]
  respond_to :json

  # GET /employees
  # GET /employees.json
  def index
    if params[:shift].blank? or params[:start].blank? or params[:end].blank?
      @employees = Employee.active_employees.with_permissions_to(:read)
    else
      @employees = Array.new
      Employee.active_employees.with_permissions_to(:read).each do |employee|
        @employees << employee if employee.eligible_to_work(Shift.find(params[:shift]), DateTime.parse(params[:start]).in_time_zone, DateTime.parse(params[:end]).in_time_zone)
      end
    end

    respond_with @employees
  end

  # GET /employees/1
  # GET /employees/1.json
  def show
  end

  # GET /employees/new
  def new
    @employee = Employee.new
  end

  def edit
  end

  def create
    @employee = Employee.new(employee_params.except(:location_assignments_attributes).except(:skill_assignments_attributes))

    if @employee.save
      update
    else
      respond_to do |format|
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    clear_associations

    respond_to do |format|
      if @employee.update(employee_params)
        format.json { render action: 'show' }
      else
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @employee.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def lookup
    req = RestClient::Resource.new "https://roles.dss.ucdavis.edu/api/entities.json?q=#{params[:q]}", 'Staff Scheduler', '376d988a44b395ace5b6d3a4ae206e9b'
    @employees = req.get if params[:q].length > 1
    
    respond_with @employees
  end

  def rm_employee
    req = RestClient::Resource.new "https://roles.dss.ucdavis.edu/people/#{params[:q]}.json", 'Staff Scheduler', '376d988a44b395ace5b6d3a4ae206e9b'
    @employee = req.get if !params[:q].blank?
    
    respond_with @employee
  end

  def current_employee
    @currentEmployee = {
      id: Authorization.current_user.employee ? Authorization.current_user.employee.id : nil,
      isManager: Authorization.current_user.role_symbols.include?(:manager)
    }

    respond_with @currentEmployee
  end

  private
    def clear_associations
      @employee.locations.destroy_all unless params[:location_assignments_attributes].blank?
      @employee.skills.destroy_all unless params[:skill_assignments_attributes].blank?
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_employee
      @employee = Employee.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def employee_params
      params.require(:employee).permit(:max_hours, :email, :name, :is_disabled, :profile, :organization_id, employee_availabilities_attributes: [:id, :schedule_id, :start_datetime, :end_datetime], location_assignments_attributes: [:location_id], skill_assignments_attributes: [:skill_id], shift_assignments_attributes: [:id, :shift_id, :start_datetime, :end_datetime])
    end
end
