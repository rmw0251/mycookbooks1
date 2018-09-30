#deploy
bash "deploy_toodle" do
code <<-EOH
s3fs moodlestore -o allow_other /mdata
EOH
end

template "#{node[:apache][:dir]}/sites-enabled/toodle" do
  source 'toodle-default-site.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, resources(:service => 'apache2')
end
