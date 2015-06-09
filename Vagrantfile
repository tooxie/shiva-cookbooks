Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.berkshelf.enabled = true
  config.berkshelf.berksfile_path = 'cookbooks/shiva/Berksfile'
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = 'cookbooks'
    chef.add_recipe 'python'
    chef.add_recipe 'shiva'
    chef.log_level = :debug
  end
end
