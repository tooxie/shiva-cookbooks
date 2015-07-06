#
# Cookbook Name:: shiva
# Recipe:: default
#
# Copyright 2015, Alvaro Mouriño <alvaro@mourino.net>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
Chef::Log.level = :debug

include_recipe 'build-essential'
include_recipe 'git'
include_recipe 'libev'
include_recipe 'python'
include_recipe 'xml'

# Packages
package 'apache2-dev'
package 'libapache2-mod-wsgi'
package 'libffi-dev'
package 'pypy'
package 'python-cffi'
package 'python-dev'

# Groups
group 'opsworks' do
  action :modify
  members 'www-data'
  append true
end

group 'adm' do
  action :modify
  members 'shiva'
  append true
end

# Directories
directory '/var/git' do
  owner  'shiva'
  group  'opsworks'
  mode   '0755'
  action :create
end

directory '/var/venv' do
  owner  'shiva'
  group  'opsworks'
  mode   '0755'
  action :create
end

directory '/var/www/.python-eggs' do
  owner  'shiva'
  group  'opsworks'
  mode   '0775'
  action :create
end

# Virtualenv
python_virtualenv '/var/venv/shiva' do
  owner  'shiva'
  group  'opsworks'
  action :create
end

# bcrypt 2.0.0
# https://github.com/pyca/bcrypt/archive/2.0.0.tar.gz

directory '/var/git/bcrypt' do
  owner  'shiva'
  group  'opsworks'
  mode   '0764'
  action :create
end

git '/var/git/bcrypt' do
  repository 'https://github.com/pyca/bcrypt.git'
  revision   '2.0.0'
  user       'shiva'
  group      'opsworks'
  action     :sync
end

bash 'bcrypt_install' do
  code  '/var/venv/shiva/bin/python setup.py install'
  user  'shiva'
  group 'opsworks'
  cwd   '/var/git/bcrypt'
end

# mod_wsgi 4.4.13
# https://github.com/GrahamDumpleton/mod_wsgi/archive/4.4.13.tar.gz

directory '/var/git/mod_wsgi' do
  owner  'root'
  group  'root'
  mode   '0764'
  action :create
end

git '/var/git/mod_wsgi' do
  repository 'https://github.com/GrahamDumpleton/mod_wsgi.git'
  revision   '4.4.13'
  action     :sync
end

bash 'install mod_wsgi' do
  cwd '/var/git/mod_wsgi'
  code <<-EOH
  ./configure
  make
  make install
  EOH
end

# Shiva
git node['shiva']['git_path'] do
  repository node['shiva']['git_repo']
  reference  'master'
  user       'shiva'
  group      'opsworks'
  action     :sync
end

template "#{node['shiva']['git_path']}/shiva/config/#{node['shiva']['conf_file']}" do
  source node['shiva']['conf_template']
  variables(
    :anonymous_access => node['shiva']['anonymous_access'],
    :db_uri => node['shiva']['db_uri'],
    :media_dir_root => node['shiva']['media_dir_root'],
    :media_dir_url => node['shiva']['media_dir_url'],
    :secret_key => node['shiva']['secret_key'],
    :server_uri => node['shiva']['server_uri'],
  )
  owner  'shiva'
  group  'opsworks'
  mode   '0754'
  action :create
end

bash 'shiva_install' do
  code  '/var/venv/shiva/bin/python setup.py install'
  user  'shiva'
  group 'opsworks'
  cwd   node['shiva']['git_path']
end

python_pip 'psycopg2' do
  virtualenv '/var/venv/shiva'
  action :install
end

bash 'shiva_db_create' do
  code  '/var/venv/shiva/bin/shiva-admin db create'
  user  'shiva'
  group 'opsworks'
  environment(
    'PYTHON_EGG_CACHE' => '/var/www/.python-eggs',
  )
  cwd   node['shiva']['git_path']
end

# Templates
template node['shiva']['wsgi_path'] do
  source node['shiva']['wsgi_path_template']
  variables(
    :path => '/var/venv/shiva',
  )
  owner  'shiva'
  group  'opsworks'
  mode   '0777'
  action :create
end

template node['shiva']['apache_conf'] do
  source node['shiva']['apache_conf_template']
  variables(
    :port => node['shiva']['port'],
    :shiva_path => node['shiva']['git_path'],
    :wsgi_path => node['shiva']['wsgi_path'],
  )
  action :create
end

file '/etc/apache2/sites-enabled/000-default.conf' do
  action :delete
end
