class Api::V1::UsersController < ApplicationController
    skip_before_action :authorized, only: [:create]
    # Skip the whole authorization process if the user action is create
    # Since obviously if you're creating a new user you're 
    def create 
        @user = User.create(user_params)
        if @user.valid? 
            @token = encode_token(user_id: @user.id)
            render json: { user: UserSerializer.new(@user), jwt: @token }, status: :created 
        else
            render json: { error: 'failed to create user' }, status: :unprocessable_entity 
        end 
    end 

    def profile
        render json: { user: UserSerializer.new(current_user)}, status: :accepted
    end 

    private

    def user_params
        params.require(:user).permit(:username, :password, :bio, :avatar)
    end 
end