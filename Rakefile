require 'dm-migrations'

namespace :db do
  desc 'Auto-migrate the database (destroys data)'
  task :migrate do
    puts "This will destroy all data in the _#{ENV['RACK_ENV']}_ database, continue? (yN)"
    if STDIN::gets.strip.downcase == 'y'
      DataMapper.auto_migrate!
    else
      puts "Okay, exiting."
    end
  end

  desc 'Auto-upgrade the database (preserves data)'
  task :upgrade do
    DataMapper.auto_upgrade!
  end
end
