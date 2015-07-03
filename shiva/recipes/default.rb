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
include_recipe 'nginx'
include_recipe 'python::default'
include_recipe 'xml'

package 'libffi-dev'

directory '/var/git' do
  owner  'root'
  group  'root'
  mode   '0755'
  action :create
end

directory node['shiva']['shiva_conf_dir'] do
  owner  'root'
  group  'root'
  mode   '0755'
  action :create
end

python_pip 'uwsgi' do
  action :install
end

git node['shiva']['git_path'] do
  repository node['shiva']['git_repo']
  reference  'master'
  action     :sync
end

bash 'shiva_install' do
  code "python setup.py install"
  cwd node['shiva']['git_path']
end

template '/etc/nginx/sites-enabled/shiva.conf' do
  source node['shiva']['nginx_conf']
  variables(
    :access_log => node['shiva']['shiva_log_access'],
    :error_log => node['shiva']['shiva_log_error'],
    :port => node['shiva']['shiva_port'],
  )
  action :create
end

template "#{node['shiva']['shiva_conf_dir']}/#{node['shiva']['shiva_conf_file']}" do
  source node['shiva']['shiva_conf_template']
  variables(
    :server_uri => node['shiva']['shiva_uri'],
    :secret_key => node['shiva']['shiva_key'],
    :media_dir_root => node['shiva']['shiva_media_dir_root'],
    :media_dir_url => node['shiva']['shiva_media_dir_url']
  )
  action :create
end

file node['shiva']['uwsgi_log'] do
  mode '0744'
  action :create
end

command = "uwsgi --socket /tmp/uwsgi.sock -w shiva.app:app --logto #{node['shiva']['uwsgi_log']}"

bash 'shiva_run' do
  code command
  environment "SHIVA_CONFIG" => "#{node['shiva']['shiva_conf_dir']}/#{node['shiva']['shiva_conf_file']}"
end
