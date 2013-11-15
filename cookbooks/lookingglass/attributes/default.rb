#
# Cookbook Name:: lookingglass
# Attributes:: default
#

default['lookingglass']['home']     = '/var/lookingglass'
default['lookingglass']['user']     = 'lookingglass'
default['lookingglass']['group']    = 'lookingglass'
default['lookingglass']['source']   = '/hostsrc'
default['lookingglass']['log']      = '/var/log/lookingglass'



# Solr recipe

default['solr']['version'] = "4.5.1"
default['solr']['checksum'] = "8726fa10c6b92aa1d2235768092ee2d4cd486eea1738695f91b33c3fd8bc4bd7" #sha265
default['solr']['directory'] = "/usr/local/src"

default['solr']['link'] = ""
default['solr']['download'] = ""
default['solr']['extracted'] = ""
default['solr']['war'] = ""

default['solr']['home'] = "/usr/share/solr"
default['solr']['data'] = "/usr/local/solr/data"
default['solr']['conf_src'] = ""

default['solr']['context_path'] = '/'
default['solr']['env_vars'] = {
	'solr.solr.home' => node['solr']['home'],
	'solr.data.dir' => node['solr']['data']
}

# SEVERE (highest value) WARNING INFO CONFIG FINE FINER FINEST (lowest value)
default['solr']['log']['level'] = 'INFO'
default['solr']['log']['class'] = 'java.util.logging.ConsoleHandler'
default['solr']['log']['formatter'] = 'java.util.logging.SimpleFormatter'

default['proxy']['http_proxy'] = 'http://dev-scheduler:devscripting@web.proxy.s3ms.com:8080/'

