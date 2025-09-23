class AddGoogleFieldsToAdmins < ActiveRecord::Migration[6.1]
  def change
    add_column :admins, :uid, :string
    add_column :admins, :full_name, :string
    add_column :admins, :avatar_url, :string
  end
end
