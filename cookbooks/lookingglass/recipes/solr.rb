#
# Cookbook Name:: lookingglass
# Recipe:: solr
#
# Copyright 2013, HipSnip Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe "lookingglass::proxy"
include_recipe "hipsnip-jetty"

require 'fileutils'

################################################################################
# Create Solr home directory

directory node['solr']['home'] do
  owner node['jetty']['user']
  group node['jetty']['group']
  mode "755"
  recursive true
  action :create
end

################################################################################
# Guess few node attributes if not set based on the given solr version in
# node['solr']['version']

if node['solr']['link'].empty?
  if /^3\.[0-9]{1,}\.[0-9]{1,}/.match(node['solr']['version'])
    node.default['solr']['link'] = "http://archive.apache.org/dist/lucene/solr/#{node['solr']['version']}/apache-solr-#{node['solr']['version']}.tgz"
    node.default['solr']['download'] = "#{node['solr']['directory']}/apache-solr-#{node['solr']['version']}.tgz"
    node.default['solr']['extracted'] = "#{node['solr']['directory']}/apache-solr-#{node['solr']['version']}"
    node.default['solr']['war'] = "apache-solr-#{node['solr']['version']}.war"
  elsif /^4\.[0-9]{1,}\.[0-9]{1,}/.match(node['solr']['version'])
    node.default['solr']['link'] = "http://archive.apache.org/dist/lucene/solr/#{node['solr']['version']}/solr-#{node['solr']['version']}.tgz"
    node.default['solr']['download'] = "#{node['solr']['directory']}/solr-#{node['solr']['version']}.tgz"
    node.default['solr']['extracted'] = "#{node['solr']['directory']}/solr-#{node['solr']['version']}"
    node.default['solr']['war'] = "solr-#{node['solr']['version']}.war"
  else
    # throw here!
  end
end

if node['solr']['conf_src'].empty?
    node['solr']['conf_src'] = "#{node['solr']['extracted']}/example/solr/"
end

################################################################################
# Download and unpack

remote_file node['solr']['download'] do
  source   node['solr']['link']
  checksum node['solr']['checksum']
  mode     0644
end


ruby_block 'Extract Solr' do
  block do
    Chef::Log.info "Extracting Solr archive #{node['solr']['download']} into #{node['solr']['directory']}"
    `tar xzf #{node['solr']['download']} -C #{node['solr']['directory']}`
    raise "Failed to extract Solr package" unless File.exists?(node['solr']['extracted'])
  end

  action :create

  not_if do
    File.exists?(node['solr']['extracted'])
  end
end

################################################################################
# Install into Jetty

ruby_block 'Copy Solr war into Jetty webapps folder' do
  block do
    Chef::Log.info "Copying #{node['solr']['war']} into #{node['jetty']['webapps']}"

    FileUtils.cp(File.join(node['solr']['extracted'],'dist',node['solr']['war']),File.join(node['jetty']['webapps'],node['solr']['war']))
    FileUtils.chown_R(node['jetty']['user'],node['jetty']['group'],File.join(node['jetty']['webapps'],node['solr']['war']))
    raise "Failed to copy Solr war" unless File.exists?(File.join(node['jetty']['webapps'],node['solr']['war']))
  end

  action :create
  notifies :restart, "service[jetty]"

  not_if do
    if not File.exists?(File.join(node['jetty']['webapps'],node['solr']['war']))
      false
    else
      downloaded_signature = `sha256sum #{node['solr']['extracted']}/dist/#{node['solr']['war']} | cut -d ' ' -f 1`
      installed_signature = `sha256sum #{node['jetty']['webapps']}/#{node['solr']['war']} | cut -d ' ' -f 1`
      downloaded_signature == installed_signature
    end
  end
end

ruby_block 'Copy ext libs into Jetty' do
  block do
    lib_files = Dir.glob(File.join(node['solr']['extracted'],'/example/lib/ext' , '**' ) )
    ext_dir = File.join(node['jetty']['home'],'/lib/ext')

    Chef::Log.info "Copying #{lib_files} into #{ext_dir}"
    FileUtils.cp_r(lib_files, ext_dir)
    raise "Failed to copy ext lib files" unless !Dir.glob(File.join(ext_dir, 'log4j-*.jar')).empty?
  end

  action :create
  notifies :restart, "service[jetty]"
end

template "#{node['jetty']['contexts']}/solr.xml" do
  owner node['jetty']['user']
  group node['jetty']['group']
  mode "644"
  source "solr.context.erb"
  notifies :restart, "service[jetty]"
end

directory node['solr']['data'] do
  owner node['jetty']['user']
  group node['jetty']['group']
  mode "755"
  recursive true
  action :create
end

################################################################################
# Export desired Solr environment variables into the attribute node.set['jetty']['java_options']

solr_env_vars = []
for key in node['solr']['env_vars'].keys.sort do
  solr_env_vars.push("-D#{key}=#{node['solr']['env_vars'][key]}")
end

node.set['jetty']['java_options'] = (node['jetty']['java_options'] + solr_env_vars).uniq

if node['lookingglass']['env'] != 'dev'

    ################################################################################
    # checkout source files

    Chef::Log.info "Exporting #{node['lookingglass']['source']} to #{node['lookingglass']['temp']}"

    directory node['lookingglass']['temp'] do
      owner node['jetty']['user']
      group node['jetty']['group']
      mode "755"
      recursive true
      action :create
    end

    git "#{node['lookingglass']['temp']}" do
        repository node['lookingglass']['source']
        reference  node['lookingglass']['version']
        action :export
    end
end

################################################################################
# Configure

ruby_block 'Copy Solr configurations files' do
  block do
    config_files = Dir.glob( File.join( node['lookingglass']['temp'], 'solr', '**' ) )
    Chef::Log.info "Copying #{config_files} into #{node['solr']['home']}"
    FileUtils.cp_r(config_files, "#{node['solr']['home']}/")
    FileUtils.chown_R(node['jetty']['user'],node['jetty']['group'],node['solr']['home'])
    raise "Failed to copy Solr configurations files" unless File.exists?(File.join(node['solr']['home'], 'solr.xml'))
  end

  action :create
  notifies :restart, "service[jetty]"
end

logging_properties_file = "#{node['jetty']['home']}/etc/logging.properties"
template logging_properties_file do
  source 'logging.properties.erb'
  mode '644'
  notifies :restart, "service[jetty]"
end

node.set['jetty']['java_options'] =  node.set['jetty']['java_options'].push("-Djava.util.logging.config.file=#{logging_properties_file}").uniq