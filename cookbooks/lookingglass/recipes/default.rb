#
# Cookbook Name:: lookingglass
# Recipe:: default
#

require 'fileutils'

################################################################################
# Require node recipe

include_recipe "lookingglass::proxy"
include_recipe "nodejs"

################################################################################
# configure npm

bash "Configure npm for the proxy" do
  user "root"
  code <<-EOH
    npm config set proxy #{node['proxy']['http_proxy']} --global
	npm config set https-proxy #{node['proxy']['http_proxy']} --global
	npm config set strict-ssl false --global
  EOH
  not_if { node['proxy']['http_proxy'].empty? }
end

if node['lookingglass']['env'] == 'dev'

   node.set['lookingglass']['user']  = 'vagrant'
   node.set['lookingglass']['group'] = 'vagrant'

else

    ################################################################################
    # Create user and group

    user node['lookingglass']['user'] do
      home  node['lookingglass']['home']
      shell '/bin/false'
      system true
      action :create
    end

    group node['lookingglass']['group'] do
      members "lookingglass"
      system true
      action :create
    end

    ################################################################################
    # Create home directory

    directory node['lookingglass']['home'] do
      owner node['lookingglass']['user']
      group node['lookingglass']['group']
      mode "755"
      recursive true
      action :create
    end

    service 'lookingglass' do
      provider Chef::Provider::Service::Upstart
      action :nothing
    end

    ################################################################################
    # Clear old source files

    ruby_block 'Copy source files into home directory' do
      block do
        source_files = Dir.glob(File.join(node['lookingglass']['home'], '**' ) )
        home_dir     = node['lookingglass']['home']

        Chef::Log.info "deleting old source files #{source_files}"
        FileUtils.rm_r(source_files)
        raise "Failed to delete old source files" unless Dir.glob(File.join(home_dir, '*.js')).empty?
      end
    end

    ################################################################################
    # checkout source files

    Chef::Log.info "Exporting #{node['lookingglass']['source']} to #{node['lookingglass']['temp']}"

    directory node['lookingglass']['temp'] do
      owner node['lookingglass']['user']
      group node['lookingglass']['group']
      mode "755"
      recursive true
      action :create
    end

    git "#{node['lookingglass']['temp']}" do
        repository node['lookingglass']['source']
        reference  node['lookingglass']['version']
        action :export
    end

    ################################################################################
    # Copy source files

    ruby_block 'Copy source files into home directory' do
      block do
        source_files = Dir.glob(File.join(node['lookingglass']['temp'], 'src', '**' ) )
        home_dir     = node['lookingglass']['home']

        Chef::Log.info "Copying #{source_files} into #{home_dir}"
        FileUtils.cp_r(source_files, home_dir)
        raise "Failed to copy source files" unless !Dir.glob(File.join(home_dir, '*.js')).empty?
      end
    end

    ################################################################################
    # NPM Modules

    bash "npm install modules" do
      cwd node['lookingglass']['home']
      user "root"
      code <<-EOH
        npm install
      EOH
    end

end

################################################################################
# Make log dir

directory node['lookingglass']['log'] do
  owner node['lookingglass']['user']
  group node['lookingglass']['group']
  mode "755"
  recursive true
  action :create
end

################################################################################
# Make upstart service from template

template "/etc/init/lookingglass.conf" do
  owner "root"
  group "root"
  mode "644"
  source "lookingglass.conf.erb"
end

################################################################################
# Start upstart service

service "lookingglass" do
  provider Chef::Provider::Service::Upstart
  action :restart
end
