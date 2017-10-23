class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :tasks, dependent: :destroy
  has_many :schedules, dependent: :destroy
  has_many :goals, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :notices, through: :notice_user
  has_many :notice_user
end
