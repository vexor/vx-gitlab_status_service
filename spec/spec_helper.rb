require "active_record"

ServiceHook = Class.new(ActiveRecord::Base)
Service = Class.new(ActiveRecord::Base) do
  belongs_to :project
  has_one :service_hook
end

require "protected_attributes"
require "shoulda-matchers"
require "httparty"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveSupport.silence(:stdout) do
  ActiveRecord::Migration.class_eval do
    create_table(:services) { |t| t.integer :project_id }
    create_table(:service_hooks) { |t| t.integer :service_id }
  end
end
