def redefine_constant(const, value)
  if Kernel.const_defined?(const)
    Kernel.send(:remove_const, const)
  end
  Kernel.const_set(const, value)
end

def upcase_keys(hash)
  hash.each_with_object({}) do |(k, v), h|
    h[k.upcase] = v
  end
end

task :ssl_cert do
  settings_ssl_path = File.join('config', 'settings_ssl.yml')
  puts "Loading configuration from #{settings_ssl_path}..."
  ssl_settings = upcase_keys(YAML.load(File.open(File.join(TOPDIR, settings_ssl_path))))

  ssl_settings.each do |setting, value|
    puts "#{setting.capitalize.gsub(/_/, ' ')}: #{value}"
    redefine_constant(setting, value)
  end
  puts "...done"

  # Where to store certificates generated with ssl_cert
  redefine_constant('CADIR', File.expand_path(File.join(TOPDIR, "certificates")))
end
