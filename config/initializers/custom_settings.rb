APP_SETTINGS = YAML::load_file(File.join(Rails.root,'config','application.yml')).symbolize_keys
