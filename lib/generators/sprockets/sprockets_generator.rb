class SprocketsGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  
  def generate_sprockets
    create_file 'app/javascripts/application.js'
    copy_file 'sprockets.yml', 'config/sprockets.yml'
  end
end
