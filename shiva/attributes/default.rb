override['libev']['version'] = '4.20'
override[:apache][:logrotate][:mode] = '0644'

default['shiva']['apache_conf'] = '/etc/apache2/sites-enabled/001-shiva.conf'
default['shiva']['apache_conf_template'] = 'apache2.conf.erb'
default['shiva']['git_path'] = '/var/git/shiva-server'
default['shiva']['git_repo'] = 'https://github.com/tooxie/shiva-server.git'
default['shiva']['shiva_conf_file'] = 'local.py'
default['shiva']['shiva_conf_template'] = 'shiva.conf.erb'
# http://docs.aws.amazon.com/opsworks/latest/userguide/workingstacks-json.html
default['shiva']['shiva_key'] = ''  # Overwrite with custom JSON
default['shiva']['shiva_media_dir_root'] = '/var/shiva'
default['shiva']['shiva_media_dir_url'] = ''
default['shiva']['shiva_port'] = '54174'
default['shiva']['shiva_uri'] = ''
default['shiva']['wsgi_path'] = '/var/www/shiva.wsgi'
default['shiva']['wsgi_path_template'] = 'shiva.wsgi.erb'
