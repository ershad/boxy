current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
syntax_check_cache_path  "#{current_dir}/syntax_check_cache"
cache_type               'BasicFile'
cache_options( :path => "#{current_dir}/checksums" )
data_bag_path           "#{current_dir}/../data_bags"
chef_repo_path          "#{current_dir}/../"
encrypted_data_bag_secret "#{current_dir}/../certificates/encrypted_data_bag_secret"

