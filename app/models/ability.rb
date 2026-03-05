class Ability 
  include CanCan::Ability

  def user
    @user
  end

  def initialize(user)
    user ||= User.new
    @user = user

    if @user.role?(:site_admin)
      can :manage, User
      can :manage, Input
      can :manage, Output
      can :manage, Engine
      can :manage, Vehicle
      can :manage, Company
      can :manage, Location
      can :manage, Parameter
      can :manage, DriveType
      can :manage, Manufacturer
      can :manage, EngineConfig
      can :manage, VehicleStat
    else @user.role?(:data_entry)
      can [:read, :create], Input, location_id: @user.location_id, submitter_email: @user.email
      can :read, Location, id: @user.location_id
      can :read, Vehicle, location_id: @user.location_id
    end
  end

  def can_access_maintenance?
    all_access = [User, Engine, Vehicle, Company, Location, Parameter, DriveType, Manufacturer, EngineConfig] 

    all_access.each { |m| return true if can? :manage, m } 

    return false
  end
end
