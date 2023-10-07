# app/controllers/concerns/authenticable.rb
module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    authorization_header = request.headers['Authorization']
    token = authorization_header.split('Bearer ').last if authorization_header
    raise 'Token is missing' unless token

    decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })
    @current_user = User.find(decoded_token[0]['user_id'])
  rescue StandardError => e
    render json: { error: e.message }, status: :unauthorized
  end
end
