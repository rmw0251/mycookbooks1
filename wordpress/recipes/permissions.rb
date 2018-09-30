# AWS OpsWorks Recipe for file permissions

require 'uri'
require 'net/http'
require 'net/https'

uri = URI.parse("https://api.wordpress.org/secret-key/1.1/salt/")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
request = Net::HTTP::Get.new(uri.request_uri)
response = http.request(request)
keys = response.body


# Create the Wordpress config file wp-config.php with corresponding values

node[:deploy].each do |app_name, deploy|
  app_root = "#{deploy[:deploy_to]}/current"
  execute "chmod -R g+rw #{app_root}" do
  end
end

package "php" do
  action :install
end
