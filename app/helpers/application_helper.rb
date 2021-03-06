module ApplicationHelper
  def current_company
    if current_user.company_users != []
      session[:company_id] ||= current_user.company_users.first.company.id
      @current_company ||= Company.find(session[:company_id])
    else
      @current_company = nil
    end
  end

  def notice_path(notice)
    if notice.associate_type == "report"
      path = notice.report_notices.first.report
    elsif notice.associate_type == "task"
      path = notice.task_notices.first.task
    elsif notice.associate_type == "goal"
      path = notice.goal_notices.first.goal
    end
    path
  end

  def todo_path(todo)
    if todo.associate_type == "report"
      path = todo.report_todos.first.report
    elsif todo.associate_type == "goal"
      path = todo.goal_todos.first.goal
    elsif todo.associate_type == "schedule"
      path = "reports/new"
    end
    path
  end

  def stamp_pressed(type: ,id:)
    if type == "report"
      stamp_pressed = ReportStamp.find_by(report_id: id, user_id: current_user.id)
    elsif type == "goal"
      stamp_pressed = GoalStamp.find_by(goal_id: id, user_id: current_user.id)
    end
    stamp_pressed
  end

  def same_stamp_pressed(type: ,id: ,stamp_id:)
    if type == "report"
      stamp_pressed = ReportStamp.find_by(report_id: id, user_id: current_user.id, id: stamp_id)
    elsif type == "goal"
      stamp_pressed = GoalStamp.find_by(goal_id: id, user_id: current_user.id, id: stamp_id)
    end
    stamp_pressed
  end

  def attendance_status(user:)
    if last_attendance = user.attendances.last
      last_attendance_status = [last_attendance.work_started_at, last_attendance.work_stopped_at, last_attendance.break_started_at, last_attendance.break_stopped_at]
      attendance_status = "am_work" if last_attendance_status[1] == nil && last_attendance_status[2] == nil && last_attendance_status[3] == nil
      attendance_status = "break" if last_attendance_status[1] == nil && last_attendance_status[2] != nil && last_attendance_status[3] == nil
      attendance_status = "pm_work" if last_attendance_status[1] == nil && last_attendance_status[2] != nil && last_attendance_status[3] != nil
      attendance_status = "not_work" if last_attendance_status[1] != nil
    else
      attendance_status = "never_work"
    end
    attendance_status
  end

  def breaked?(attendance:)
    breaked = true if attendance.break_started_at != nil
    breaked = false if attendance.break_started_at == nil
    breaked
  end

  def work_time(attendance:)
    minutes = attendance.work_stopped_at.to_time.to_i - attendance.work_started_at.to_time.to_i
    work_time = (Time.parse("1/1") + minutes - break_time(attendance: attendance).to_i)
  end

  def break_time(attendance:)
    minutes = attendance.break_stopped_at.to_time.to_i - attendance.break_started_at.to_time.to_i if breaked?(attendance: attendance)
    minutes = 0.to_i unless breaked?(attendance: attendance)
    break_time = (Time.parse("1/1") + minutes)
  end

  def today_schedule(user:)
    range = Time.now.beginning_of_day...Time.now.end_of_day
    today_schedule = Schedule.where(user_id:user.id, company_id:current_company.id, work_started_at:range).last
  end

  def after_schedules(user:)
    range = Time.now.next_day.beginning_of_day..Float::INFINITY
    after_schedules = Schedule.where(user_id:user.id, company_id:current_company.id, work_started_at:range).limit(3)
  end

  def stamps
    stamps = Stamp.all
  end

  def mypage?
    session[:mypage]
  end

  def recent_notice_users
    recent_notice_users = current_user.notice_users.limit(10).reverse_order
  end

  def notice_count
    notice_count = 0
		recent_notice_users.each do |notice_user|
  		if notice_user.notice.read == false
  			notice_count += 1
  		end
    end
    return notice_count
  end

  def todo_users
    todos = current_user.todos.where(done:false).reverse_order
  end

  def user_color_list(user_id:,company_id:)
    color = CompanyUser.find_by(user_id:user_id, company_id:company_id).color
  end
end
