desc 'Capify the application. Required the option APP_PATH the full path to application.'
task :capify_app, :node do |t, args|
  if ENV['APP_PATH'].nil?
    puts 'Required the the ENV variable provided `APP_PATH`'
    exit 1
  end

  node = args[:node]
  builder = BoxBuilder.new(node)

  server_config = builder.nodes.first
  build_config = server_config.config
  app_path = File.realpath(ENV['APP_PATH'])
  repo_url = `git --git-dir #{app_path}/.git config --get remote.origin.url`.chop!

  deploy_dir_path = File.join app_path, 'config', 'deploy'
  deploy_templates_dir_path = File.join deploy_dir_path, 'templates'
  capistrano_templates_path = File.expand_path('../../../capistrano/templates', __FILE__)
  unicorn_templates_path = File.expand_path('../../../unicorn/templates', __FILE__)
  lib_dir_path = File.join app_path, 'lib'
  unicorn_config_dir_path = File.join(app_path, 'config', 'unicorn')

  puts "--> Create required folders:"
  mkdir_p(deploy_dir_path)
  mkdir_p(deploy_templates_dir_path)
  mkdir_p(lib_dir_path)
  mkdir_p(unicorn_config_dir_path)

  puts "--> Create #{app_path}/Capfile"
  capfile_path = File.join(app_path, 'Capfile')
  file(capfile_path) do |t|
    FileUtils.cp(File.join(capistrano_templates_path, 'Capfile'), capfile_path)
  end
  Rake::Task[capfile_path].invoke

  puts "--> Create #{app_path}/deploy.rb"
  deploy_path = File.join(app_path, 'config', 'deploy.rb')
  file(deploy_path) do |t|
    template = File.read File.join(capistrano_templates_path, 'config', 'deploy.rb.erb')
    File.open(t.name, 'w+') do |f|
      f.write(ERB.new(template).result(binding))
    end
  end
  Rake::Task[deploy_path].invoke

  capistrano_stage_rb = File.join(capistrano_templates_path, 'config', 'stage.rb.erb')
  unicorn_stage_rb = File.join(unicorn_templates_path, 'config', 'stage.rb.erb')
  capistrano_stage_template = File.read(capistrano_stage_rb)
  unicorn_stage_template = File.read(unicorn_stage_rb)


  envs = %w(staging production)
  envs.each do |stage|
    puts "--> Create #{app_path}/deploy/#{stage}.rb files"
    file = File.join(deploy_dir_path, "#{stage}.rb")
    puts server_config.inspect
    server = server_config.hostname
    options = server_config.options
    File.open(file, 'w') do |f|
      f.write(ERB.new(capistrano_stage_template).result(binding))
    end

    server_app_path = "/data/apps/#{server_config.options['app_name']}"
    puts "--> Create #{app_path}/#{unicorn_config_dir_path}/#{stage}.rb files"
    file = File.join(unicorn_config_dir_path, "#{stage}.rb")
    File.open(file, 'w') do |f|
      f.write(ERB.new(unicorn_stage_template).result(binding))
    end

  end

  puts "--> Adding required gems to #{app_path}/Gemfile. Please review it after capify and run `bundle install`!!!"
  # Update Gemfile with required gems
  File.open(File.join(app_path, 'Gemfile'), 'a') do |f|
    f.write("\ngem 'boxy-cap', github: 'bigbinary/boxy-cap'\n")
    f.write("gem 'capistrano'\n")
    f.write("gem 'capistrano-rbenv'\n")
    f.write("gem 'capistrano-rails', github: 'capistrano/rails'\n")
    f.write("gem 'capistrano-bundler'\n")
    f.write("gem 'sshkit'\n")

    f.write("gem 'unicorn'\n")
  end

  puts "--> Create #{app_path}/.ruby-version if does not exists"
  ruby_version_file = File.join(app_path, '.ruby-version')
  unless File.exists?(ruby_version_file)
    File.open(ruby_version_file, 'w') do |f|
      ruby_version = build_config['ruby']['version']
      raise "ruby_version is nil" if ruby_version.nil?
      f.write(ruby_version)
    end
  end

  puts "--> Copy default database templates"
  cp File.join(capistrano_templates_path, 'config', 'templates', 'database_mysql.yml.erb'), deploy_templates_dir_path
  cp File.join(capistrano_templates_path, 'config', 'templates', 'database_pg.yml.erb'),    deploy_templates_dir_path
end
