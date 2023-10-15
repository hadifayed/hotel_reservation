class ApplicationController < ActionController::API
	include DeviseTokenAuth::Concerns::SetUserByToken
	before_action :configure_permitted_parameters, if: :devise_controller?
	rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

	def record_not_found
    render json: [I18n.t('general_errors.not_found')], status: :not_found
	end

	protected

	def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password])
  end
end
