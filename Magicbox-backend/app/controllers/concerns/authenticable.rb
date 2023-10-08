module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    token = cookies.signed[:user_token]
    raise 'Token is missing' unless token

    decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })
    jti = decoded_token[0]['jti']

    # データベースに存在するJWTのjtiを検索
    jwt_record = JwtToken.find_by(jti:)

    # jtiがデータベースに存在しない、またはトークンの有効期限が切れている場合、エラーを返す
    raise 'Token is not valid or expired' unless jwt_record && Time.at(decoded_token[0]['exp']) > Time.now

    @current_user = User.find(decoded_token[0]['user_id'])
  rescue StandardError => e
    render json: { error: e.message }, status: :unauthorized
  end
end
