class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :assign_sales_companies, dependent: :destroy
  has_many :companies, through: :assign_sales_companies
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships


  validates :name, presence: true, length: { minimum: 3 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }
end
