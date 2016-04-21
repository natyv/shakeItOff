require "active_record"

options = {
  adapter: 'postgresql',
  database: 'shakeitoff'
}

ActiveRecord::Base.establish_connection(options)
