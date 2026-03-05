class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # :registerable, :recoverable, :rememberable
  devise :database_authenticatable, :trackable, :validatable

  belongs_to :location
  has_many :inputs

  ROLES = %w[site_admin data_entry imports].freeze

  def role?(role)
    self.role == role.to_s
  end

  def active_for_authentication?
    super && is_active?
  end

  def company_code 
    unless location.blank?
      "#{location.company.code}"
    else 
      ""
    end
  end

  def location_code 
    unless location.blank?
    "#{location.code}"
    else
      ""
    end
  end

  def fullname
    "#{first_name} #{last_name}"
  end

  def as_json(options={})
    super(only: [:id, :first_name, :last_name, :email, :role, :is_active, 
                 :require_password_change, :location_id],
      methods: [:company_code, :location_code, :fullname])
  end
end
