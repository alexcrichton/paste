namespace :paste do
  desc 'Rebuild all cached javascripts with compression'
  task :rebuild => :environment do
    Paste::JS::Unify.new.rebuild_cached_sprockets! :compress => 'google'
  end
end