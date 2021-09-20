class Api::V1::AuthController < ApplicationController
    skip_before_action :authorized, only: [:create]

    def create 
        @user = User.find_by(username: user_login_params[:username])
        # user#authenticate comes from bcrypt
        if @user && @user.authenticate(user_login_params[:password])
            # Remember, if the first value is not true, the second value won't even kick off (otherwise we'd get errored all to hell and back)
            token = encode_token({user_id: @user.id})
            # Remember we inherit from application controller, so that's where encode_token comes from
            render json: { user: UserSerializer.new(@user), jwt: token }, status: :accepted
        else
            render json: { message: 'Invalid username or password' }, status: :unauthorized 
        end 
    end 

    private 

    def user_login_params
        params.require(:user).permit(:username, :password)
    end 
end
