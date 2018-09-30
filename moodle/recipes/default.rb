bash "setup_toodle" do
code <<-EOH
yum install gcc libstdc++-devel gcc-c++ fuse fuse-devel curl-devel libxml2-devel openssl-devel mailcap -y
chkconfig rpcbind on
chkconfig nfs on
service rpcbind start
service nfs start
mkdir /tmp/s3fs
cd /tmp/s3fs
wget http://s3fs.googlecode.com/files/s3fs-1.74.tar.gz 
tar xvzf s3fs-1.74.tar.gz
cd s3fs-1.74/
./configure --prefix=/usr
make
make install 

# need to copy from secured s3 bucket to /etc/passwd-s3fs

aws --region "ap-southeast-2" s3 cp s3://rpwawsauth/moodle/passwd-s3fs.txt /etc/passwd-s3fs

chmod 600 /etc/passwd-s3fs
mkdir /tmp/toodle
cd /tmp/toodle
wget https://s3-ap-southeast-2.amazonaws.com/rpw-src/toodle/toodle-site.tgz
tar xf toodle-site.tgz
cp -rf * /var/www
rm -rf /var/www/moodledata
mkdir /var/www/moodledata
chgrp apache /var/www/moodledata
chmod g+rw /var/www/moodledata

# mount 172.31.2.24:/moodledata /var/www/moodledata
mkdir /mdata
s3fs moodlestore -o allow_other /mdata
#ln -s /mdata/moodledata /var/www/moodledata
ln -s /mdata/moodledata/filedir /var/www/moodledata/filedir
ln -s /mdata/moodledata/lang /var/www/moodledata/lang

chgrp -R apache /var/www
chmod -R g+w /var/www
EOH
end

template "#{node[:apache][:dir]}/sites-enabled/toodle" do
  source 'toodle-default-site.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, resources(:service => 'apache2')
end
