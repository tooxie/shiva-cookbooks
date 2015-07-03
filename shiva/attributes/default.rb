override['libev']['version'] = '4.20'
override[:apache][:logrotate][:mode] = '0644'

default['shiva']['git_path'] = '/var/git/shiva-server'
default['shiva']['git_repo'] = 'https://github.com/tooxie/shiva-server.git'
# TODO: Switch to apache in the main branch, but have a specific branch with
# nginx conf.
default['shiva']['nginx_conf'] = 'nginx.conf.erb'
default['shiva']['shiva_conf_dir'] = '/var/conf'
default['shiva']['shiva_conf_file'] = 'shiva.conf'
default['shiva']['shiva_conf_template'] = 'shiva.conf.erb'
default['shiva']['shiva_key'] = ''
default['shiva']['shiva_log_access'] = '/var/log/nginx/shiva.access.log'
default['shiva']['shiva_log_error'] = '/var/log/nginx/shiva.error.log'
default['shiva']['shiva_media_dir_root'] = '/var/shiva'
default['shiva']['shiva_media_dir_url'] = ''
default['shiva']['shiva_port'] = '54174'
default['shiva']['shiva_uri'] = ''
default['shiva']['uwsgi_log'] = '/var/log/uwsgi.shiva.log'
