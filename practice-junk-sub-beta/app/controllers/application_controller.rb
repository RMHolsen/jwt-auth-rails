class ApplicationController < ActionController::API
    # All controllers inherit from this one, so this will provide functionality to all controllers
    before_action :authorized

    def encode_token(payload)
        # payload => { beef: 'steak' }
        # I have no idea what this means
        # is 'beef' supposed to be the username? 
        # wtf
        JWT.encode(payload, 'my_s3cr3t')
        # jwt string: "eyJhbGciOiJIUzI1NiJ9.eyJiZWVmIjoic3RlYWsifQ._IBTHTLGX35ZJWTCcY30tLmwU9arwdpNVxtVU0NpAuI"
    end 

    def auth_header
        # Whenever the user wants to access a protected route or resource, the user agent (browser in our case) should send the JWT, 
        # typically in the Authorization header using the Bearer schema. The content of the header should look like the following:
        # { 'Authorization': 'Bearer <token>'}
        request.headers['Authorization']
    end 

    def decoded_token
        if auth_header
            token = auth_header.split(' ')[1] 
            # i.e. the <token> part above
            # token => "eyJhbGciOiJIUzI1NiJ9.eyJiZWVmIjoic3RlYWsifQ._IBTHTLGX35ZJWTCcY30tLmwU9arwdpNVxtVU0NpAuI"
            begin 
                JWT.decode(token, 'my_s3cr3t', true, algorithm: 'HS256')
                # JWT.decode => [{ "beef"=>"steak" }, { "alg"=>"HS256" }]
            rescue JWT::DecodeError
                nil
                # This returns nil for a bad token rather than crashing the whole system. 
        end 
    end 

    def current_user
        if decoded_token # See above with JWT.decode, apparently 'beef' means 'user_id'
        # That's a stupid way to describe a railroad.
            user_id = decoded_token[0]['user_id']
            @user = User.find_by(id: user_id)
        end 
    end 

    def logged_in?
        !!current_user
        # You know this from previous iterations of things and stuff
    end 

    def authorized 
        render json: { message: 'Please log in' }, status: :unauthorized unless logged_in?
    end 
end
