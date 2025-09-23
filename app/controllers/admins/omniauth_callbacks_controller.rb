class Admins::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    Rails.logger.info "=== Google OAuth2 callback hit ==="
    Rails.logger.info "Auth hash: #{auth.inspect}"

    begin
      admin = Admin.from_google(**from_google_params)
      Rails.logger.info "Admin loaded: #{admin.inspect}"

      if admin.present?
        Rails.logger.info "Admin present. Signing in."
        sign_out_all_scopes
        flash[:success] = t 'devise.omniauth_callbacks.success', kind: 'Google'
        sign_in_and_redirect admin, event: :authentication
      else
        Rails.logger.warn "Admin not authorized: #{auth.info.email}"
        flash[:alert] = t 'devise.omniauth_callbacks.failure', kind: 'Google', reason: "#{auth.info.email} is not authorized."
        redirect_to new_admin_session_path
      end
    rescue => e
      Rails.logger.error "Omniauth Google callback error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to new_admin_session_path, alert: "Authentication failed: #{e.message}"
    end
  end

  protected

  def after_omniauth_failure_path_for(_scope)
    new_admin_session_path
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || root_path
  end

  private

  def from_google_params
    @from_google_params ||= {
      uid: auth&.uid,
      email: auth&.info&.email,
      full_name: auth&.info&.name,
      avatar_url: auth&.info&.image
    }
  end

  def auth
    @auth ||= request.env['omniauth.auth']
  end
end