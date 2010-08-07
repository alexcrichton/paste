namespace :paste do
  desc 'Rebuild all cached javascripts with compression'
  task :rebuild => :environment do
    Paste::Rails.glue.rebuild! :compress => 'google'
  end
end