class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  after_action :after_sign_up

  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    super
    user = User.find_by(email:params[:user][:email])
    if user.employment_status == false
      company = Company.create(name:params[:user][:companies][:company_name], hp_addr:params[:user][:companies][:hp_addr])
      CompanyUser.create(user_id:user.id, company_id:company.id)
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  def after_sign_up
    session[:after_sign_up] = true
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(:name, :email, :password, :university, :grade, :department, :position, :gender, :birthday, :profile_photo_url, :employment_status, schedules_attributes: [:company_name, :hp_addr, :number_of_interns])
    end
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
