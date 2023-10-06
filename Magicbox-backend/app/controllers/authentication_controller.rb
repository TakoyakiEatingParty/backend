require 'httparty'

class AuthenticationController < ApplicationController
	def github_auth
		auth_code = params[:code]
		token = github_auth_token(auth_code)
		if token.present?
			render json: { status: :ok, token: token }
		else
			render json: { status: 500, errors: ['Unable to authenticate with GitHub'] }
		end
	end

	def github_redirect
		client_id = ENV.fetch('GITHUB_CLIENT_ID', nil)
		github_url = "https://github.com/login/oauth/authorize?client_id=#{client_id}&scope=repo"
		redirect_to github_url, allow_other_host: true
	end

	private
	def github_auth_token(auth_code)
		token_endpoint = 'https://github.com/login/oauth/access_token'.freeze
		response = HTTParty.post(token_endpoint,
			headers: { 'Accept' => 'application/json' },
			body: {
				client_id: ENV.fetch('GITHUB_CLIENT_ID', nil),
				client_secret:  ENV.fetch('GITHUB_CLIENT_SECRET', nil),
				code: auth_code
			}
		)
		if response.code == 200
			return response.parsed_response['access_token']
		else
			return nil
		end
	end
end
