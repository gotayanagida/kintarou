class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = current_company.tasks.all.page(params[:page]).per(20).search(params[:search]).reverse_order if params[:sort] == nil && params[:uesr_id] == nil
    @tasks = current_company.tasks.order(params[:sort]).page(params[:page]).per(20) if params[:sort] != nil
    @tasks = current_company.tasks.where(user_id: params[:user_id]).reverse_order.page(params[:page]).per(20) if params[:user_id] != nil
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(task_params)
    Task.associate_task(params:params, task: @task)

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: 'Task was successfully created.' }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end

    #お知らせ生成
    if @task.task_users != []
      if params[:user_id] != [] && params[:schedule_id] != []
        name = current_user.name
        title = @task.title
        day = @task.task_schedules.first.schedule.work_started_at.strftime("%m月%d日") unless @task.task_schedules == []
        users_id_arr = []
        users_id_arr.append(@task.task_users.first.user.id)
        generate_notice(users_id:users_id_arr, companies_id:companies_id_arr, body:"#{name}さんが#{day}のあなたの タスク「#{title}」を追加しました", associate_type:"task", associate_id: @task.id)
      end
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    Task.associate_task(params:params, task: @task)
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:user_id, :company_id, :schedule_id, :title, :detail)
    end
end
