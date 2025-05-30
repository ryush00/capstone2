class AddDeletedAtToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :deleted_at, :datetime, comment: "게시글 삭제 시간"
    add_index :posts, :deleted_at, name: "index_posts_on_deleted_at"
  end
end
