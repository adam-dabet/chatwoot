class AddContentAttributesToConversations < ActiveRecord::Migration[7.0]
  def change
    add_column :conversations, :content_attributes, :jsonb, default: {}, null: false
    add_index :conversations, :content_attributes, using: :gin
  end
end 