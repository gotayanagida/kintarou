class ReportsController < ApplicationController
  before_action :set_report, only: [:show, :edit, :update, :destroy]
  # GET /reports
  # GET /reports.json
  def index
    @reports = current_company.reports.reverse_order.page(params[:page]).per(10) if params[:sort] == nil && params[:uesr_id] == nil
    @reports = current_company.reports.order(params[:sort]).page(params[:page]).per(10) if params[:sort] != nil
    @reports = current_company.reports.where(user_id: params[:user_id]).reverse_order.page(params[:page]).per(10) if params[:user_id] != nil
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
  end

  # GET /reports/new
  def new
    @report = Report.new
  end

  # GET /reports/1/edit
  def edit
  end

  # POST /reports
  # POST /reports.json
  def create
    @report = Report.new(report_params)
    @report.update(work_started_at: @report.schedule.work_started_at)

    respond_to do |format|
      if @report.save
        format.html { redirect_to @report, notice: 'Report was successfully created.' }
        format.json { render :show, status: :created, location: @report }
      else
        format.html { render :new }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end

    #Todo生成
    name = current_user.name
    title = params[:report][:title]
    day = Schedule.find(params[:report][:schedule_id]).work_started_at.strftime("%m月%d日")
    generate_todo(users_id:staffs_id_arr, companies_id:companies_id_arr, body:"#{name}さんが#{day}出社分の日報「#{title}」を作成しました。確認してスタンプを押しましょう。", associate_type:"report", associate_id: @report.id)

    #update Todo
    update_todo(associate_type:"schedule", associate_id: @report.schedule.id)
  end

  # PATCH/PUT /reports/1
  # PATCH/PUT /reports/1.json
  def update
    respond_to do |format|
      if @report.update(report_params)
        format.html { redirect_to @report, notice: 'Report was successfully updated.' }
        format.json { render :show, status: :ok, location: @report }
      else
        format.html { render :edit }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report.destroy
    respond_to do |format|
      format.html { redirect_to reports_url, notice: 'Report was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      params.require(:report).permit(:user_id, :company_id, :title, :schedule_id, :body, schedules_attributes: [:schedule_id])
    end
end
