class AddIconToCmItems < ActiveRecord::Migration
  def change
    add_column :cm_items, :icon, :string
  end
end