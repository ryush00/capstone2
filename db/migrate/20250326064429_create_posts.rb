class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.datetime :posted_date
      t.integer :view_count
      t.string :author_name
      t.string :author_id
      t.string :author_email
      t.string :cid
      t.string :gid
      t.string :bid
      t.boolean :is_notice
      t.text :attachment_urls
      t.text :attachment_names
      t.string :source_url
      t.datetime :scraped_at
      t.datetime :last_updated_at

      t.timestamps
    end
  end
end
