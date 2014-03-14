class EmployeeSchedulesController < ApplicationController
  before_action :set_employee_schedule, only: [:show, :edit, :update, :destroy]

  # GET /employee_schedules
  # GET /employee_schedules.json
  def index
    @employee_schedules = EmployeeSchedule.all
  end

  # GET /employee_schedules/1
  # GET /employee_schedules/1.json
  def show
  end

  # GET /employee_schedules/new
  def new
    @employee_schedule = EmployeeSchedule.new
  end

  # GET /employee_schedules/1/edit
  def edit
  end

  # POST /employee_schedules
  # POST /employee_schedules.json
  def create
    @employee_schedule = EmployeeSchedule.new(employee_schedule_params)

    respond_to do |format|
      if @employee_schedule.save
        format.html { redirect_to @employee_schedule, notice: 'EmployeeSchedule was successfully created.' }
        format.json { render action: 'show', status: :created, location: @employee_schedule }
      else
        format.html { render action: 'new' }
        format.json { render json: @employee_schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /employee_schedules/1
  # PATCH/PUT /employee_schedules/1.json
  def update
    respond_to do |format|
      if @employee_schedule.update(employee_schedule_params)
        format.html { redirect_to @employee_schedule, notice: 'EmployeeSchedule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @employee_schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employee_schedules/1
  # DELETE /employee_schedules/1.json
  def destroy
    @employee_schedule.destroy
    respond_to do |format|
      format.html { redirect_to employee_schedules_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_employee_schedule
      @employee_schedule = EmployeeSchedule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def employee_schedule_params
      params.require(:employee_schedule).permit(:amount, :employee_id, :starting_date)
    end
end
