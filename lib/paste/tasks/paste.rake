namespace :paste do
  desc 'Rebuild all cached javascripts'
  task :rebuild => :environment do
    Paste::Rails.glue.rebuild
  end
end