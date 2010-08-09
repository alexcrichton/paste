Capistrano::Configuration.instance(true).load do
  after 'deploy:setup', 'paste:create_cache'
  after 'deploy:update_code', 'paste:link_cache'
  after 'deploy:update_code', 'paste:rebuild'

  namespace :paste do
    desc "Rebuild javascripts and such"
    task :rebuild do
      # Don't fail if paste isn't installed or something like that. Force this
      # command to succeed
      env = exists?(:rails_env) ? rails_env : 'production'
      run "cd #{latest_release} && " +
          "rake RAILS_ENV=#{env} paste:rebuild; echo ''"
    end

    desc "Create a directory for caching javascript and such"
    task :create_cache do
      run "mkdir -p #{shared_path}/paste-cache"
    end

    desc "Link the cache directory into place"
    task :link_cache do
      run "ln -nsf #{shared_path}/paste-cache #{latest_release}/tmp"
    end
  end
end