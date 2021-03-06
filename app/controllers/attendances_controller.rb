class AttendancesController < ApplicationController
  before_action :set_attendance, only: [:show, :edit, :update, :destroy]

  # GET /attendances
  # GET /attendances.json
  def index
    @attendances = current_company.attendances.where.not(work_stopped_at: nil).page(params[:page]).per(20).reverse_order
    @attendances_for_csv = current_company.attendances.all
  end

  # GET /attendances/1
  # GET /attendances/1.json
  def show
  end

  # GET /attendances/new
  def new
    @attendance = Attendance.new
  end

  # GET /attendances/1/edit
  def edit
  end

  # POST /attendances
  # POST /attendances.json
  def create
    @attendance = Attendance.new(attendance_params)

    respond_to do |format|
      if @attendance.save
        format.html { redirect_to @attendance, notice: 'Attendance was successfully created.' }
        format.json { render :show, status: :created, location: @attendance }
      else
        format.html { render :new }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /attendances/1
  # PATCH/PUT /attendances/1.json
  def update
    cnt = @attendance.num_of_edit + 1
    @attendance.update(num_of_edit: cnt)
    respond_to do |format|
      if @attendance.update(attendance_params)
        format.html { redirect_to @attendance, notice: 'Attendance was successfully updated.' }
        format.json { render :show, status: :ok, location: @attendance }
      else
        format.html { render :edit }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attendances/1
  # DELETE /attendances/1.json
  def destroy
    @attendance.destroy
    respond_to do |format|
      format.html { redirect_to attendances_url, notice: 'Attendance was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def start_work
    @attendance = Attendance.new(user_id: current_user.id, company_id: current_company.id, work_started_at:Time.now)
    respond_to do |format|
      if @attendance.save
        format.html { redirect_to root_path, notice: '出勤が登録されました。'}
        format.json { render :show, status: :created, location: @attendance }
      else
        format.html { render :new }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  def stop_work
    attendance = Attendance.where(user_id: current_user.id).last

    range = attendance.work_started_at.beginning_of_day...attendance.work_started_at.end_of_day
    schedule = Schedule.where(work_started_at:range).last
    if schedule.report == nil
      day = schedule.work_started_at.strftime("%m月%d日")
      generate_todo(users_id:current_users_id_arr, companies_id:companies_id_arr, body:"#{day}の日報を入力しましょう。", associate_type:"schedule", associate_id:schedule.id)
    end
    respond_to do |format|
      if @attendance = attendance.update(work_stopped_at:Time.now)
        format.html { redirect_to root_path, notice: '退勤が登録されました。'}
        format.json { render :show, status: :created, location: @attendance }
      else
        format.html { render :new }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  def start_break
    attendance = Attendance.where(user_id: current_user.id).last
    respond_to do |format|
      if @attendance = attendance.update(break_started_at:Time.now)
        format.html { redirect_to root_path, notice: '休憩開始が登録されました。'}
        format.json { render :show, status: :created, location: @attendance }
      else
        format.html { render :new }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  def stop_break
    attendance = Attendance.where(user_id: current_user.id).last
    respond_to do |format|
      if @attendance = attendance.update(break_stopped_at:Time.now)
        format.html { redirect_to root_path, notice: '休憩終了が登録されました。'}
        format.json { render :show, status: :created, location: @attendance }
      else
        format.html { render :new }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attendance
      @attendance = Attendance.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def attendance_params
      params.require(:attendance).permit(:user_id, :work_started_at, :work_stopped_at, :num_of_edit)
    end
end
