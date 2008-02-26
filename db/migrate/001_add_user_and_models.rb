class AddUserAndModels < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :username,         :string, :limit => 80
      t.column :password_salt,    :string
      t.column :password_hash,    :string
      t.column :created_at,       :datetime
      t.column :updated_at,       :datetime
    end
    
    create_table "groups", :force => true do |t|
      t.column :name,             :string, :limit => 80
      t.column :created_at,       :datetime
      t.column :updated_at,       :datetime
    end
    
    create_table "meetings", :force => true do |t|
      t.column :name,             :string, :limit => 80
      t.column :created_at,       :datetime
      t.column :updated_at,       :datetime
    end
    
    # add ActiveRecordStore session support
    create_table :sessions, :force => true do |t|
      t.column :session_id,       :string
      t.column :data,             :text
      t.column :updated_at,       :datetime
    end  
    add_index :sessions, :session_id
  end

  def self.down
    drop_table :users
    drop_table :groups
    drop_table :meetings
    drop_table :sessions
  end
end
