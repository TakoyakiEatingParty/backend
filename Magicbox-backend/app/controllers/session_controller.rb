class SessionController < ApplicationController
	def github_auth
    	client_id = ENV.fetch('GITHUB_CLIENT_ID', nil)
    	github_url = "https://github.com/login/oauth/authorize?client_id=#{client_id}&scope=repo"
    	redirect_to github_url, allow_other_host: true
  	end

	def github_callback
		#callback処理
		#帰ってきたcodeを使ってaccess_tokenを取得する
		auth_code = params[:code]
		access_token = github_access_token(auth_code)
		p access_token
		# Github APIを叩いてユーザー情報を取得する
		user_info = fetch_github_user_info(access_token)

		# user_infoをもとに、ユーザーを探すか新規作成する
		if user_info.present?
			user = User.find_or_create_from_auth_hash!(user_info)
		else
			raise 'Unable to authenticate with GitHub'
		end
		# ユーザー情報をもとに、JWTを生成する
		jwt_payload = { user_id: user.id }
		jwt_token = JWT.encode(jwt_payload, Rails.application.credentials.secret_key_base, 'HS256')

		redirect_to ENV.fetch('FRONTEND_URL', nil) + "/?token=#{jwt_token}"
	end

	private
	def github_access_token(auth_code)
		token_endpoint = 'https://github.com/login/oauth/access_token'.freeze
		response = HTTParty.post(token_endpoint,
								headers: { 'Accept' => 'application/json' },
								body: {
								client_id: ENV.fetch('GITHUB_CLIENT_ID', nil),
								client_secret: ENV.fetch('GITHUB_CLIENT_SECRET', nil),
								code: auth_code
								},
							debug_output: $stdout,)
		return response.parsed_response['access_token'] if response.code == 200

		nil
	end

	def fetch_github_user_info(access_token)
		response = HTTParty.get('https://api.github.com/user',
			headers: {
				'Authorization' => "token #{access_token}",
				'User-Agent' => 'Magicbox',
				'Accept' => 'application/vnd.github.v3+json'
			}
		)
		return nil unless response.code == 200

		user_info = response.parsed_response
		{
			provider: 'github',
			uid: user_info['id'],
			name: user_info['name'] || user_info['login'],
			image_url: user_info['avatar_url'],
			email: user_info['email']
		}
	end
end
