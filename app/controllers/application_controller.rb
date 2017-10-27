class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def current_company
    if current_user.company_users != []
      session[:company_id] ||= current_user.company_users.first.company.id
      @current_company ||= Company.find(session[:company_id])
    else
      @current_company = nil
    end
  end

  def generate_notice(users_id:, companies_id:, msg:, report_id:)
    notice = Notice.create(body: msg, report_id: report_id)
    users_id.each do |user_id|
      user = User.find(user_id)
      user.notices << notice
    end
    companies_id.each do |company_id|
      company = Company.find(company_id)
      company.notices << notice
    end
  end

  def users_id_for_notice
    users_id = []
    users_id.append(current_user.id)
    current_company.company_users.each do |company_user|
      if company_user.user.employment_status == 0
        users_id.append(company_user.user_id)
      end
    end
    users_id
  end

  def companies_id_for_notice
    companies_id = []
    companies_id.append(current_company.id)
  end

  def check_day_before
    staffs = User.where(employment_status:0)
    staffs.each do |staff|
      next_day_interns = []
      range = Time.now.next_day.beginning_of_day..Time.now.next_day.end_of_day
      schedules = staff.company_users.first.company.schedules.where(work_started_at: range)
      if schedules != []
        NoticeMailer.send_day_before(schedules, staff).deliver
      end
    end
  end
end
