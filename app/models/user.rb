# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable
  include DeviseTokenAuth::Concerns::User

  has_many :room_reservations, dependent: :destroy

  validates :name, :email, presence: true
end