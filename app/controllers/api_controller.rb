class ApiController < ApplicationController
  protect_from_forgery with: :null_session

  rescue_from ManifestNotFound, with: :manifest_not_found_error

  private

  def user_not_authorized
    render json: {
      message: "Permission denied",
      error: "You are not authorized to perform this action."
    }, status: 403
  end

  def authenticate_user!
    unless authenticated?
      render json: {
        message: "Permission denied",
        errors: "Missing or invalid authorization token"
      }, status: 403
    end
  end

  def run_validator(validator)
    if validator.run == false
      render json: {
        message: "Validation failed",
        errors: validator.error_messages
      }, status: 422
    end

    !validator.errors.any?
  end

  def find_manifest(id = params[:id])
    Manifest.find_by_uuid_or_tracking_number!(id)
  end

  def manifest_not_found_error
    render json: {
      message: "Manifest not found",
      errors: ["No manifest for id #{params[:id]}"]
    }, status: 404
  end

  def read_body_as_json(opts = {})
    begin
      JSON.parse(request.body.read, opts)
    rescue JSON::ParserError => error
      render json: { message: "Invalid JSON in request: #{error}" }, status: 400
    end
  end
end
