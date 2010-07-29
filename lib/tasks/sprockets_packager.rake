namespace :sprockets do
  desc 'Rebuild all cached sprockets'
  task :rebuild => :environment do
    Sprockets::Packager.watcher.rebuild_cached_sprockets!
  end
end