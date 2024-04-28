class AddCheckConstraintRoleNames < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :roles,
      "name IN ('adopter', 'fosterer', 'staff', 'admin')",
      name: "valid_role_names"
  end
end
