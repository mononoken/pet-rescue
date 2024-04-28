class AddUniqueNameIndexToRoles < ActiveRecord::Migration[7.1]
  def change
    remove_index :roles, %i[name resource_type resource_id], unique: true
    add_index :roles, %i[name resource_type resource_id], unique: true
  end
end
