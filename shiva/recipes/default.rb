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

include_recipe 'build-essential::default'
include_recipe 'git'
include_recipe 'libev'
include_recipe 'python::default'
include_recipe 'xml'

package 'libffi-dev'
package 'libapache2-mod-wsgi'

directory '/var/git' do
  owner  'root'
  group  'root'
  mode   '0755'
  action :create
end

git node['shiva']['git_path'] do
  repository node['shiva']['git_repo']
  reference  'master'
  action     :sync
end

bash 'shiva_install' do
  code 'python setup.py install'
  cwd node['shiva']['git_path']
end

template node['shiva']['wsgi_path'] do
  source node['shiva']['wsgi_path_template']
  action :create
end

template "#{node['shiva']['git_path']}/shiva/config/#{node['shiva']['shiva_conf_file']}" do
  source node['shiva']['shiva_conf_template']
  variables(
    :media_dir_root => node['shiva']['shiva_media_dir_root'],
    :media_dir_url => node['shiva']['shiva_media_dir_url'],
    :secret_key => node['shiva']['shiva_key'],
    :server_uri => node['shiva']['shiva_uri'],
  )
  action :create
end

template node['shiva']['wsgi_path'] do
  source node['shiva']['wsgi_path_template']
  action :create
end

template node['shiva']['apache_conf'] do
  source node['shiva']['apache_conf_template']
  variables(
    :port => node['shiva']['shiva_port'],
    :shiva_path => node['shiva']['git_path'],
    :wsgi_path => node['shiva']['wsgi_path'],
  )
  action :create
end

# mod_wsgi
# https://github.com/GrahamDumpleton/mod_wsgi/archive/4.4.13.tar.gz
# 0. Install apache2-dev
# 1. Download source
# 2. Uncompress
# 3. configure
# 4. make
# 5. make install
# 6. LoadModule wsgi_module modules/mod_wsgi.so

package 'apache2-dev'

directory '/var/git/mod_wsgi' do
  owner  'root'
  group  'root'
  mode   '0764'
  action :create
end

git '/var/git/mod_wsgi' do
  repository 'https://github.com/GrahamDumpleton/mod_wsgi.git'
  reference  'master'
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


# FIXME: Temporary hack to access apache logs.
file '/var/log/apache2/error.log' do
  mode '0644'
  owner 'shiva'
  group 'opsworks'
end

file '/var/log/apache2/access.log' do
  mode '0644'
  owner 'shiva'
  group 'opsworks'
end

file '/var/log/apache2/other_vhosts_access.log' do
  mode '0644'
  owner 'shiva'
  group 'opsworks'
end
