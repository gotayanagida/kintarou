class DashboardController < ApplicationController
  def index
    redirect_to update_user_after_login_path if session[:after_sign_up] == true
    session[:mypage] = false

    @schedules = current_company.schedules.all
    @tasks = current_company.tasks.all.limit(5).reverse_order
    @reports = current_company.reports.limit(5).reverse_order
    users = current_company.users.where(employment_status:1)
    @users = users.page(params[:page]).per(10)



    if current_company != nil
      @schedules = current_company.schedules.all
      @tasks = current_company.tasks.all.limit(5).reverse_order
      @reports = current_company.reports.limit(5).reverse_order
      users = current_company.users.where(employment_status:1)
      @users = users.page(params[:page]).per(10)

      if current_user.employment_status == false
        #社員用ダッシュボード
        @user = current_company.users.find(current_user.id)
        @active_attendances = Attendance.where(company_id: current_company, work_stopped_at: nil)
        range = Time.now.next_day.beginning_of_day...Float::INFINITY
        @schedules_for_staff = current_company.schedules.where(work_started_at: range).order(:work_started_at).limit(5)
        @searched_users = User.all.page(params[:page]).per(10).search(params[:search])
        @todo_users = @user.todo_users.limit(5).reverse_order
      else
        @user = current_company.users.find(current_user.id)
        #4 buttons
        if @user.attendances != []
          now_time = Time.now.to_time.to_i
          work_started_time = @user.attendances.last.work_started_at.to_i
          work_stopped_time = @user.attendances.last.work_stopped_at.to_i
          break_started_time = @user.attendances.last.break_started_at.to_i
          break_stopped_time = @user.attendances.last.break_stopped_at.to_i
          @break_time = 0.to_i if attendance_status(user:@user) == "am_work"
          @break_time = now_time - break_started_time if attendance_status(user:@user) == "break"
          @break_time = break_stopped_time - break_started_time if attendance_status(user:@user) == "pm_work" || attendance_status(user:@user) == "not_work"
          @attendance_time = now_time - work_started_time - @break_time
          @last_attendance_time = work_stopped_time - work_started_time - @break_time.to_i if attendance_status(user:@user) == "not_work"
        end
        #その日の出勤シフトについて
        today_work_schedule = current_company.schedules.where(user_id: current_user.id, work_started_at: Time.now.beginning_of_day...Time.now.end_of_day).first
        if today_work_schedule != nil
          #その日の出勤シフトがある場合
          @today_work_schedule = ""
          @today_work_schedule += today_work_schedule.work_started_at.strftime("%m月%d日 %-H時%M分")
          @today_work_schedule += " ~ "
          @today_work_schedule += today_work_schedule.work_ended_at.strftime("%-H時%M分")
        else
          #その日の出勤シフトがない場合
          @today_work_schedule = "\"登録なし\""
        end

        #その日の翌日以降の出勤シフトについて
        next_work_schedule = current_company.schedules.where(user_id: current_user.id, work_started_at: Time.now.to_time..Float::INFINITY).order(:work_started_at).first
        if next_work_schedule != nil
          #次回以降の出勤シフトがある場合
          @next_work_schedule = next_work_schedule.work_started_at.strftime("%m月%d日 %-H時%M分")
          @next_work_schedule += " ~ "
          @next_work_schedule += next_work_schedule.work_ended_at.strftime("%-H時%M分")
        else
          #次回以降の出勤シフトがない場合
          @next_work_schedule = "\"登録なし\""
        end
        range = Time.now.next_day.beginning_of_day...Float::INFINITY
        @schedules_for_intern = current_company.schedules.where(work_started_at: range, user_id:current_user.id).order(:work_started_at).limit(5)

        @schedule = Schedule.new
      end
    end
  end

  def set_current_company
    session[:company_id] = params[:company_id]
    redirect_back(fallback_location: root_path)
  end

end
