require_relative '../util'

desc "builds the box"
task :build do |_, args|
  include Util

  base_dir = File.realpath(File.join(File.dirname(__FILE__), '..', '..'))
  @logger = Logger.new(File.join(base_dir, 'log', 'build.log'))

  log_time_taken do
    builder = BoxBuilder.new( @logger)
    if builder.nodes.any?
      builder.bundle_install
      builder.berkshelf_update_cookbooks
      builder.build
    end
  end
end

desc 'grants access to root user'
task :grant_root_access, :node do |t, args|
  builder = BoxBuilder.new args[:node]
  builder.nodes.first.grant_ssh_access
end

desc 'bundle install'
task :bundle_install do
  BoxBuilder.new.bundle_install
end

desc "Bundles a single cookbook for distribution"
task :bundle_cookbook => [ :metadata ]
task :bundle_cookbook, :cookbook do |t, args|
  tarball_name = "#{args.cookbook}.tar.gz"
  temp_dir = File.join(Dir.tmpdir, "chef-upload-cookbooks")
  temp_cookbook_dir = File.join(temp_dir, args.cookbook)
  tarball_dir = File.join(TOPDIR, "pkgs")
  FileUtils.mkdir_p(tarball_dir)
  FileUtils.mkdir(temp_dir)
  FileUtils.mkdir(temp_cookbook_dir)

  child_folders = [ "cookbooks/#{args.cookbook}", "site-cookbooks/#{args.cookbook}" ]
  child_folders.each do |folder|
    file_path = File.join(TOPDIR, folder, ".")
    FileUtils.cp_r(file_path, temp_cookbook_dir) if File.directory?(file_path)
  end

  system("tar", "-C", temp_dir, "-cvzf", File.join(tarball_dir, tarball_name), "#{args.cookbook}")

  FileUtils.rm_rf temp_dir
end
