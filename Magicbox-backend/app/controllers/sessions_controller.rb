class SessionsController < ApplicationController

	def create
		user = User.find_or_create_from_auth_hash!(request.env['omniauth.auth'])
		session[:user_id] = user.id
		redirect_to 'http://localhost:3001'
	end

	def destroy
		reset_session
		render json: { status: :ok, logged_in: false }
	end
end
