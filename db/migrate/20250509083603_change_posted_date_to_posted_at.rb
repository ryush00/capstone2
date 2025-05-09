class ChangePostedDateToPostedAt < ActiveRecord::Migration[8.0]
  def change
    rename_column :posts, :posted_date, :posted_at
  end
end
