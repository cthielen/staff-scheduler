class ShiftExceptionsController < ApplicationController
  before_action :set_shift_exception, only: [:show, :edit, :update, :destroy]

  # GET /shift_exceptions
  # GET /shift_exceptions.json
  def index
    @shift_exceptions = ShiftException.all
  end

  # GET /shift_exceptions/1
  # GET /shift_exceptions/1.json
  def show
  end

  # GET /shift_exceptions/new
  def new
    @shift_exception = ShiftException.new
  end

  # GET /shift_exceptions/1/edit
  def edit
  end

  # POST /shift_exceptions
  # POST /shift_exceptions.json
  def create
    @shift_exception = ShiftException.new(shift_exception_params)

    respond_to do |format|
      if @shift_exception.save
        format.html { redirect_to @shift_exception, notice: 'Shift exception was successfully created.' }
        format.json { render action: 'show', status: :created, location: @shift_exception }
      else
        format.html { render action: 'new' }
        format.json { render json: @shift_exception.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shift_exceptions/1
  # PATCH/PUT /shift_exceptions/1.json
  def update
    respond_to do |format|
      if @shift_exception.update(shift_exception_params)
        format.html { redirect_to @shift_exception, notice: 'Shift exception was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @shift_exception.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shift_exceptions/1
  # DELETE /shift_exceptions/1.json
  def destroy
    @shift_exception.destroy
    respond_to do |format|
      format.html { redirect_to shift_exceptions_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shift_exception
      @shift_exception = ShiftException.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shift_exception_params
      params.require(:shift_exception).permit(:start_datetime, :end_datetime, :employee_id, :is_absence, :shift_id)
    end
end
