class User < ApplicationRecord
  has_many :user_sessions
  has_many :journal_entries, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :user_roles
  has_many :roles, through: :user_roles

  def role_names
    roles.pluck(:name)
  end

  def has_role?(role)
    role_names.include?(role.to_s)
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  def jwt_payload
    {
      roles: role_names
    }
  end

end
