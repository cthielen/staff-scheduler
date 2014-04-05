class SchedulesController < ApplicationController
  before_action :set_schedule, only: [:show, :edit, :update, :destroy]
  wrap_parameters :schedule, include: [:name, :start_date, :end_date, :organization_id, :state, :shifts_attributes, :add_employees]

  # GET /schedules
  # GET /schedules.json
  def index
    if params[:active]
      @schedules = Schedule.active_schedules.order(:start_date)
    else
      @schedules = Schedule.all.order(:start_date)
    end
  end

  # GET /schedules/1
  # GET /schedules/1.json
  def show
  end

  # GET /schedules/new
  def new
    @schedule = Schedule.new
  end

  # GET /schedules/1/edit
  def edit
  end

  # POST /schedules
  # POST /schedules.json
  def create
    @schedule = Schedule.new(schedule_params)

    respond_to do |format|
      if @schedule.save
        format.html { redirect_to @schedule, notice: 'Schedule was successfully created.' }
        format.json { render action: 'show', status: :created, location: @schedule }
      else
        format.html { render action: 'new' }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /schedules/1
  # PATCH/PUT /schedules/1.json
  def update
    send_notifications(params)

    respond_to do |format|
      if @schedule.update(schedule_params)
        format.html { redirect_to @schedule, notice: 'Schedule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /schedules/1
  # DELETE /schedules/1.json
  def destroy
    @schedule.destroy
    respond_to do |format|
      format.html { redirect_to schedules_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_schedule
      @schedule = Schedule.find(params[:id])
    end

    def send_notifications(params)
      return unless params[:schedule][:state]

      new_state = params[:schedule][:state].to_i
      unless new_state.blank? or (new_state == @schedule.state)
        case new_state
        when 2
          # Schedule complete, email employees for availabilities
          StaffMailer.request_availability_form().deliver
        when 4
          # Assignments are done, email employees for confirmation
          StaffMailer.request_assignment_confirmation_form().deliver
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def schedule_params
      params.require(:schedule).permit(:start_date, :end_date, :name, :organization_id, :state, shifts_attributes: [:id, :start_datetime, :end_datetime, :is_mandatory, :location_id, :skill_id], add_employees: [:name, :email])
    end
end
