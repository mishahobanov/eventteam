class CreateTable < ActiveRecord::CompatibleLegacyMigration.migration_class
  def change
    create_table :meeting_users do |t|

      t.integer :meeting_id

      t.integer :user_id


    end

  end
end
