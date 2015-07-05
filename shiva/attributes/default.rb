override['libev']['version'] = '4.20'
override[:apache][:logrotate][:mode] = '0644'

# http://docs.aws.amazon.com/opsworks/latest/userguide/workingstacks-json.html
default['shiva']['apache_conf'] = '/etc/apache2/sites-enabled/001-shiva.conf'
default['shiva']['apache_conf_template'] = 'apache2.conf.erb'
default['shiva']['conf_file'] = 'local.py'
default['shiva']['conf_template'] = 'shiva.conf.erb'
default['shiva']['db_uri'] = 'sqlite://'
default['shiva']['git_path'] = '/var/git/shiva-server'
default['shiva']['git_repo'] = 'https://github.com/tooxie/shiva-server.git'
default['shiva']['media_dir_root'] = '/var/shiva'
default['shiva']['media_dir_url'] = ''
default['shiva']['port'] = '54174'
default['shiva']['secret_key'] = ''  # Overwrite with custom JSON
default['shiva']['server_uri'] = ''
default['shiva']['wsgi_path'] = '/var/www/shiva.wsgi'
default['shiva']['wsgi_path_template'] = 'shiva.wsgi.erb'
