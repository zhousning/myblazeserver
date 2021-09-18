class WxUsersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def get_userid
    resource = User.find_for_database_authentication(phone: params[:username])
    return render :json => {:success => false} unless resource

    if resource.valid_password?(params[:password])
      openid = resource.number
      return render :json => {:success => true, :openid => openid}
    else
      return render :json => {:success => false}
    end
  end
end
