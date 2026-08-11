module AuthenticateRequest
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
    attr_reader :current_user
  end

  private

  def authenticate_request!
    header = request.headers['Authorization']
    token = header.split(' ').last if header.present?
    decoded = JsonWebToken.decode(token) if token

    if decoded && decoded[:user_id]
      @current_user = User.find_by(id: decoded[:user_id])
    end

    unless @current_user
      render json: { error: 'Not Authorized' }, status: :unauthorized
    end
  end
end
