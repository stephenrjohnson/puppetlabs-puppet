require 'spec_helper'

describe 'puppet::master', :type => :class do

    context 'on Debian operatingsystems' do
        let(:facts) do
            {
                :osfamily        => 'Debian',
                :operatingsystem => 'Debian',
                :operatingsystemrelease => '5',
                :concat_basedir => '/nde',
                :lsbdistcodename => 'lenny',
                :processorcount => '2',
                :puppetversion   => '3.8.0'
            }
        end
        let (:params) do
            {
                :version                => 'present',
                :puppet_master_package  => 'puppetmaster',
                :puppet_master_service  => 'puppetmaster',
                :modulepath             => '/etc/puppet/modules',
                :manifest               => '/etc/puppet/manifests/site.pp',
                :external_nodes         => '/usr/local/bin/puppet_node_classifier',
                :node_terminus          => 'exec',
                :autosign               => 'true',
                :certname               => 'test.example.com',
                :storeconfigs           => 'true',
                :storeconfigs_dbserver  => 'test.example.com',
                :dns_alt_names          => ['puppet'],
                :strict_variables       => 'true',
            }
        end
        it {
            should contain_user('puppet').with(
                :ensure => 'present',
                :uid    => nil,
                :gid    => 'puppet'
            )
            should contain_group('puppet').with(
                :ensure => 'present',
                :gid    => nil
            )
            should contain_package(params[:puppet_master_package]).with(
                :ensure => params[:version],
                :require => 'Package[puppetmaster-common]'
            )
            should contain_package('puppetmaster-common').with(
                :ensure => params[:version]
            )
            should contain_service(params[:puppet_master_service]).with(
                :ensure    => 'stopped',
                :enable    => 'false',
                :require   => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_file('/etc/puppet/puppet.conf').with(
                :ensure  => 'file',
                :require => 'File[/etc/puppet]',
                :owner   => 'puppet',
                :group   => 'puppet',
                :notify  => 'Service[httpd]'
            )
            should contain_file('/etc/puppet').with(
                :require => "Package[#{params[:puppet_master_package]}]",
                :ensure => 'directory',
                :owner  => 'puppet',
                :group  => 'puppet',
                :notify => "Service[httpd]"
            )
            should contain_file('/var/lib/puppet').with(
                :ensure => 'directory',
                :owner  => 'puppet',
                :group  => 'puppet',
                :notify => 'Service[httpd]'
            )
            should contain_class('puppet::storeconfigs').with(
              :before => ['Anchor[puppet::master::end]']
            )
            should contain_class('puppet::passenger').with(
              :before => ['Anchor[puppet::master::end]']
            )
            should contain_ini_setting('puppetmasterenvironmentpath').with(
                :ensure  => 'absent',
                :setting => 'environmentpath'
            )
            should contain_ini_setting('puppetmastermodulepath').with(
                :ensure  => 'present',
                :setting => 'modulepath',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:modulepath],
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmastermanifest').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'manifest',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:manifest],
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmasterencconfig').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'external_nodes',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:external_nodes],
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmasternodeterminus').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'node_terminus',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:node_terminus],
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmasterautosign').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'autosign',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:autosign],
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmastercertname').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'certname',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:certname],
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmasterreports').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'reports',
                :path    => '/etc/puppet/puppet.conf',
                :value   => 'store',
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmasterparser').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'parser',
                :path    => '/etc/puppet/puppet.conf',
                :value   => 'current',
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmasterpluginsync').with(
                :ensure  => 'present',
                :setting => 'pluginsync',
                :path    => '/etc/puppet/puppet.conf',
                :value   => 'true'
            )
            should contain_ini_setting('puppetmasterdnsaltnames').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'dns_alt_names',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:dns_alt_names].join(',')
            )
            should contain_ini_setting('puppetmasterstrictvariables').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'strict_variables',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:strict_variables]
            )
            should contain_anchor('puppet::master::begin').with_before(
              ['Class[Puppet::Passenger]', 'Class[Puppet::Storeconfigs]']
            )
            should contain_anchor('puppet::master::end')
        }
    end

    context 'on RedHat operatingsystems' do
        let(:facts) do
            {
                :osfamily        => 'RedHat',
                :operatingsystem => 'RedHat',
                :operatingsystemrelease => '6',
                :concat_basedir => '/nde',
                :processorcount => '2',
                :puppetversion   => '3.8.0'
            }
        end
        let (:params) do
            {
                :version                => 'present',
                :puppet_master_package  => 'puppetmaster',
                :puppet_master_service  => 'puppetmaster',
                :modulepath             => '/etc/puppet/modules',
                :manifest               => '/etc/puppet/manifests/site.pp',
                :external_nodes         => '/usr/local/bin/puppet_node_classifier',
                :node_terminus          => 'exec',
                :autosign               => 'true',
                :certname               => 'test.example.com',
                :storeconfigs           => 'true',
                :storeconfigs_dbserver  => 'test.example.com',
                :dns_alt_names          => ['puppet'],
                :strict_variables       => 'true'

            }
        end
        it {
            should contain_user('puppet').with(
                :ensure => 'present',
                :uid    => nil,
                :gid    => 'puppet'
            )
            should contain_group('puppet').with(
                :ensure => 'present',
                :gid    => nil
            )
            should contain_package(params[:puppet_master_package]).with(
                :ensure => params[:version]
            )
            should_not contain_package('puppetmaster-common').with(
                :ensure => params[:version]
            )
            should contain_service(params[:puppet_master_service]).with(
                :ensure    => 'stopped',
                :enable    => 'false',
                :require   => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_file('/etc/puppet/puppet.conf').with(
                :ensure  => 'file',
                :require => 'File[/etc/puppet]',
                :owner   => 'puppet',
                :group   => 'puppet',
                :notify  => 'Service[httpd]'
            )
            should contain_file('/etc/puppet').with(
                :require => "Package[#{params[:puppet_master_package]}]",
                :ensure => 'directory',
                :owner  => 'puppet',
                :group  => 'puppet',
                :notify => "Service[httpd]"
            )
            should contain_file('/var/lib/puppet').with(
                :ensure => 'directory',
                :owner  => 'puppet',
                :group  => 'puppet',
                :notify => 'Service[httpd]'
            )
            should contain_class('puppet::storeconfigs').with(
              :before => ['Anchor[puppet::master::end]']
            )
            should contain_class('puppet::passenger').with(
              :before => ['Anchor[puppet::master::end]']
            )
            should contain_ini_setting('puppetmasterenvironmentpath').with(
                :ensure  => 'absent'
            )
            should contain_ini_setting('puppetmastermodulepath').with(
                :ensure  => 'present',
                :setting => 'modulepath',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:modulepath],
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmastermanifest').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'manifest',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:manifest],
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmasterencconfig').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'external_nodes',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:external_nodes],
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmasternodeterminus').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'node_terminus',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:node_terminus],
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmasterautosign').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'autosign',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:autosign],
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmastercertname').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'certname',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:certname],
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmasterreports').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'reports',
                :path    => '/etc/puppet/puppet.conf',
                :value   => 'store',
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmasterparser').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'parser',
                :path    => '/etc/puppet/puppet.conf',
                :value   => 'current',
                :require => 'File[/etc/puppet/puppet.conf]'
            )
            should contain_ini_setting('puppetmasterpluginsync').with(
                :ensure  => 'present',
                :setting => 'pluginsync',
                :path    => '/etc/puppet/puppet.conf',
                :value   => 'true'
            )
            should contain_ini_setting('puppetmasterdnsaltnames').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'dns_alt_names',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:dns_alt_names].join(',')
            )
            should contain_ini_setting('puppetmasterstrictvariables').with(
                :ensure  => 'present',
                :section => 'master',
                :setting => 'strict_variables',
                :path    => '/etc/puppet/puppet.conf',
                :value   => params[:strict_variables]
            )
            should contain_anchor('puppet::master::begin').with_before(
              ['Class[Puppet::Passenger]', 'Class[Puppet::Storeconfigs]']
            )
            should contain_anchor('puppet::master::end')
        }
    end
    context 'When environment handling is set to directory' do
        let(:facts) do
            {
                :osfamily        => 'RedHat',
                :operatingsystem => 'RedHat',
                :operatingsystemrelease => '6',
                :concat_basedir => '/nde',
                :processorcount => '2',
                :puppetversion   => '3.8.0'
            }
        end
        let (:params) do {
            :environments => 'directory'
        }
        end

        it {
            should contain_ini_setting('puppetmasterenvironmentpath').with(
                :ensure  => 'present',
                :section => 'main',
                :setting => 'environmentpath',
                :path    => '/etc/puppet/puppet.conf',
                :value   => '/etc/puppet/environments'
            )
            should contain_ini_setting('puppetmastermodulepath').with(
                :ensure  => 'absent',
                :setting => 'modulepath'
            )
            should contain_ini_setting('puppetmastermanifest').with(
                :ensure  => 'absent',
                :setting => 'manifest'
            )
        }
    end
    context 'When environment handling is set to directory with specified environmentpath' do
        let(:facts) do
            {
                :osfamily        => 'RedHat',
                :operatingsystem => 'RedHat',
                :operatingsystemrelease => '6',
                :concat_basedir => '/nde',
                :processorcount => '2',
                :puppetversion   => '3.8.0'
            }
        end
        let (:params) do {
            :environments => 'directory',
            :environmentpath => '/etc/puppetlabs/puppet/environments',
        }
        end

        it {
            should contain_ini_setting('puppetmasterenvironmentpath').with(
                :ensure  => 'present',
                :section => 'main',
                :setting => 'environmentpath',
                :path    => '/etc/puppet/puppet.conf',
                :value   => '/etc/puppetlabs/puppet/environments'
            )
            should contain_ini_setting('puppetmastermodulepath').with(
                :ensure  => 'absent',
                :setting => 'modulepath'
            )
            should contain_ini_setting('puppetmastermanifest').with(
                :ensure  => 'absent',
                :setting => 'manifest'
            )
        }
    end

end
