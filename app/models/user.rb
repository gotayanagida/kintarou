class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable,
         omniauth_providers: [:facebook, :google_oauth2]

  has_many :tasks
  has_many :schedules
  has_many :goals
  has_many :reports
  has_many :attendances
  has_many :report_stamps
  has_many :goal_stamps
  has_many :notice_users
  has_many :notices, through: :notice_users
  has_many :todo_users
  has_many :todos, through: :todo_users
  has_many :company_users
  has_many :companies, through: :company_users

  def self.search(search)
    if search
      where(['name LIKE ?', "%#{search}%"])
    else
      all
    end
  end

end
