class ApplicationController < ActionController::API
	include DeviseTokenAuth::Concerns::SetUserByToken
	before_action :configure_permitted_parameters, if: :devise_controller?
	rescue_from ActiveRecord::RecordNotFound, with: :render_record_not_found
  rescue_from CanCan::AccessDenied, with: :render_unauthorized

	def render_record_not_found(exception)
    render json: [I18n.t('general_errors.not_found', model: exception.model.downcase)], status: :not_found
	end

  def render_unauthorized
    render json: [I18n.t('general_errors.unauthorized')], status: :forbidden    
  end

	protected

	def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password])
  end
end
