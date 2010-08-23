namespace :paste do
  desc 'Rebuild all cached javascripts'
  task :rebuild => :environment do
    Paste::Rails.glue.rebuild!
  end

  desc 'Compress all cached javascripts'
  task :compress => :environment do
    Paste::Rails.glue.rebuild! :compress => 'google'
  end
end