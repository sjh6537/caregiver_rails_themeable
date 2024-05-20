class ChangeIdDefaultNull < ActiveRecord::Migration[7.1]
  def change
    change_column_default :user_requests, :helper_id, nil
  end
end
