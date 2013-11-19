# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "node" do |node| 
      node.vm.box = "Ubuntu130432"
      node.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/raring/current/raring-server-cloudimg-i386-vagrant-disk1.box"

      node.vm.network :forwarded_port, guest: 8080, host: 8080
      node.vm.network :private_network, ip: "192.168.254.10"

      config.vm.synced_folder "src", "/hostsrc"

      node.vm.provision :chef_solo do |chef|
		 # chef.http_proxy  = "http://dev-scheduler:devscripting@web.proxy.s3ms.com:8080/"
         # chef.https_proxy = "http://dev-scheduler:devscripting@web.proxy.s3ms.com:8080/"
         chef.add_recipe "git"
         chef.add_recipe "lookingglass"
         chef.json = {  :proxy => {
                            :http_proxy     => "",
                        },
                        :lookingglass => {
                            :env            => "dev",
                            :home           => "/hostsrc",
                        },
                     }
      end
  end

  config.vm.define "solr" do |solr|
    solr.vm.box = "Ubuntu130432"
    solr.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/raring/current/raring-server-cloudimg-i386-vagrant-disk1.box"

    solr.vm.network :forwarded_port, guest: 8090, host: 8090
    solr.vm.network :private_network, ip: "192.168.254.11"

    solr.vm.provision :chef_solo do |chef|
		# chef.http_proxy  = "http://dev-scheduler:devscripting@web.proxy.s3ms.com:8080/"
        # chef.https_proxy = "http://dev-scheduler:devscripting@web.proxy.s3ms.com:8080/"
		chef.add_recipe "git"
		chef.add_recipe "lookingglass::solr"

        config.vm.synced_folder "./", "/host"

        chef.json = {  :java => {
                         :oracle          => { "accept_oracle_download_terms" => true },
                         :jdk_version     => "7"
                       },
                       :jetty => {
                          :port           => "8090",
                       },
                       :solr => {
                          :conf_src       => "/hostsolr/",
                       },
                       :proxy => {
                          :http_proxy     => "",
                       },
                       :lookingglass => {
                          :env            => "dev",
                          :temp           => "/host",
                       },
                    }
    end
  end
end