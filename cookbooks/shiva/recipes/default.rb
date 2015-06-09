#
# Cookbook Name:: shiva
# Recipe:: default
#
# Copyright 2015, Alvaro Mouriño
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
directory '/var/venv' do
  owner  'root'
  group  'root'
  mode   '0755'
  action :create
end

directory '/var/git' do
  owner  'root'
  group  'root'
  mode   '0755'
  action :create
end

python_pip 'virtualenv' do
  action :install
end

python_virtualenv "/var/venv/shiva" do
  action :create
end

python_pip 'uwsgi' do
  virtualenv '/var/venv/shiva'
  action :install
end

git '/var/git/shiva' do
  repository 'https://github.com/tooxie/shiva-server.git'
  reference  'master'
  action     :sync
end

# FIXME: Not working. Find out how to install something using virtualenv
python 'shiva_install' do
  virtualenv '/var/venv/shiva'
  command '/var/git/shiva/setup.py develop'
  action :run
end

template '/etc/nginx/conf.d/shiva.conf' do
  source 'default/nginx.conf.erb'
  action :create
end

# A dependency of uWSGI
# package 'libssl0.9.8' do
#   action :upgrade
# end
