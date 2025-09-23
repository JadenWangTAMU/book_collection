class Admin < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  def self.from_google(email:, full_name:, uid:, avatar_url:)
    Rails.logger.info "Admin.from_google called with email=#{email}, uid=#{uid}"

    begin
      admin = find_or_create_by!(email: email) do |a|
        a.uid = uid
        a.full_name = full_name
        a.avatar_url = avatar_url
      end

      # In case the admin existed but we need to update info
      admin.update(uid: uid, full_name: full_name, avatar_url: avatar_url) if admin.changed?

      Rails.logger.info "Admin found or created: #{admin.inspect}"
      admin
    rescue => e
      Rails.logger.error "Error in Admin.from_google: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      nil
    end
  end

end
