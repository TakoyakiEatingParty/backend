class Api::V1::CurrentUserController < ApplicationController
	before_action :authenticate_user

	def show
		render json: { logged_in: true, user: current_user }
	end

	private

	def authenticate_user
		unless session[:user_id] && current_user
			render json: { status: 'unauthorized' }, status: :unauthorized
		end
	end

	def current_user
		@current_user ||= User.find_by(id: session[:user_id])
	end
end
