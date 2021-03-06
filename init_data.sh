#!/bin/bash


############################################
# Set of centreonConsole commands to init test data
# No need for a timeperiod (default = all the time ~24x7)
############################################

echo " ==== Creating pollers ==== "
php external/bin/centreonConsole centreon-configuration:poller:create --name=central --template=Central --ip-address='127.0.0.1' --engine-init-script='/etc/init.d/centengine' --engine-binary='/usr/sbin/centengine' --engine-modules-dir='/usr/lib64/centreon-engine/' --engine-conf-dir='/etc/centreon-engine/' --engine-logs-dir='/var/log/centreon-engine/' --engine-var-lib-dir='/var/lib/centreon-engine/' --broker-conf-dir='/etc/centreon-broker/' --broker-modules-dir='/usr/share/centreon/lib/centreon-broker/' --broker-data-dir='/var/lib/centreon-broker' --broker-logs-dir='/var/log/centreon-broker/' --broker-cbmod-dir='/usr/lib64/nagios/' --broker-init-script='/etc/init.d/cbd'

#php external/bin/centreonConsole centreon-configuration:poller:create --name=poller6 --template=Poller --ip-address="127.0.0.1" --engine-init-script='/etc/init.d/centengine' --engine-binary='/usr/sbin/centengine' --engine-modules-dir='/usr/lib64/centreon-engine/' --engine-conf-dir='/etc/centreon-engine/' --engine-logs-dir='/var/log/centreon-engine/' --engine-var-lib-dir='/var/lib/centreon-engine/' --broker-conf-dir='/etc/centreon-broker/' --broker-modules-dir='/usr/share/centreon/lib/centreon-broker/' --broker-data-dir='/var/lib/centreon-broker' --broker-logs-dir='/var/log/centreon-broker/' --broker-cbmod-dir='/usr/lib64/nagios/' --broker-init-script='/etc/init.d/cbd' --broker-central-ip="10.30.2.34"

echo " ==== Creating resource macro === "
php external/bin/centreonConsole centreon-configuration:Resource:create --resource-name='$USER1$' --resource-line='/usr/lib/nagios/plugins' --resource-pollers='Central'

echo " ==== Creating timeperiods ==== "
php external/bin/centreonConsole centreon-configuration:Timeperiod:create --tp-name='24x7' --tp-alias='24x7' --tp-sunday='00:00-24:00' --tp-monday='00:00-24:00' --tp-tuesday='00:00-24:00' --tp-wednesday='00:00-24:00' --tp-thursday='00:00-24:00' --tp-friday='00:00-24:00' --tp-saturday='00:00-24:00'
php external/bin/centreonConsole centreon-configuration:Timeperiod:create --tp-name='Working hours' --tp-alias='Working hours' --tp-monday='09:00-18:00' --tp-tuesday='09:00-18:00' --tp-wednesday='09:00-18:00' --tp-thursday='09:00-18:00' --tp-friday='09:00-18:00'

echo " ==== Creating notif commands ==== "
php external/bin/centreonConsole centreon-configuration:Command:create --command-name='Send mail' --command-type=1 --command-line='mail -s test test'

echo " ==== Creating check commands ==== "
php external/bin/centreonConsole centreon-configuration:Command:create --command-name='check_centreon_ping' --command-type=2 --command-line='$USER1$/check_icmp -H $HOSTADDRESS$ -n $_SERVICEPACKETNUMBER$ -w $_SERVICEWARNING$ -c $_SERVICECRITICAL$'
php external/bin/centreonConsole centreon-configuration:Command:create --command-name='check-host-alive' --command-type=2 --command-line='$USER1$/check_icmp -H $HOSTADDRESS$ -n $_HOSTPACKETNUMBER$ -w $_HOSTWARNING$ -c $_HOSTCRITICAL$'

# TODO add check host alive
php external/bin/centreonConsole centreon-configuration:Command:create --command-name='OS-Linux-SNMP-load' --command-type=2 --command-line='$USER1$/centreon-plugins/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=load --hostname=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ $_HOSTSNMPEXTRAOPTIONS$ --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEEXTRAOPTIONS$'
php external/bin/centreonConsole centreon-configuration:Command:create --command-name='OS-Linux-SNMP-memory' --command-type=2 --command-line='$USER1$/centreon-plugins/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=memory --hostname=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ $_HOSTSNMPEXTRAOPTIONS$ --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEEXTRAOPTIONS$'
php external/bin/centreonConsole centreon-configuration:Command:create --command-name='OS-Linux-SNMP-cpu' --command-type=2 --command-line='$USER1$/centreon-plugins/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=cpu --hostname=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ $_HOSTSNMPEXTRAOPTIONS$ --warning="$_SERVICEWARNING$"  --critical="$_SERVICECRITICAL$" $_SERVICEEXTRAOPTIONS$'
php external/bin/centreonConsole centreon-configuration:Command:create --command-name='OS-Linux-SNMP-swap' --command-type=2 --command-line='$USER1$/centreon-plugins/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=swap --hostname=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ $_HOSTSNMPEXTRAOPTIONS$ --warning="$_SERVICEWARNING$" --critical="$_SERVICECRITICAL$" $_SERVICEEXTRAOPTIONS$'
php external/bin/centreonConsole centreon-configuration:Command:create --command-name='OS-Linux_SNMP-traffic-name' --command-type=2 --command-line='$USER1$/centreon-plugins/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=traffic --hostname=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ $_HOSTSNMPEXTRAOPTIONS$ --interface="$_SERVICEINTERFACENAME$" --name --warning-in="$_SERVICEWARNINGIN$" --critical-in="$_SERVICECRITICALIN$" --warning-out="$_SERVICEWARNINGOUT$" --critical-out="$_SERVICECRITICALOUT$" $_SERVICEEXTRAOPTIONS$'
php external/bin/centreonConsole centreon-configuration:Command:create --command-name='OS-Linux-SNMP-disk-name' --command-type=2 --command-line='$USER1$/centreon-plugins/centreon_plugins.pl --plugin=os::linux::snmp::plugin --mode=storage --hostname=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ $_HOSTSNMPEXTRAOPTIONS$ --storage "$_SERVICEDISKNAME$" --name --display-transform-src="$_SERVICETRANSFORMSRC$" --display-transform-dst="$_SERVICETRANSFORMDST$" --warning="$_SERVICEWARNING$" --critical="$_SERVICECRITICAL$" $_SERVICEEXTRAOPTIONS$'

# Windows
php external/bin/centreonConsole centreon-configuration:Command:create --command-name='OS-Windows-SNMP-memory' --command-type=2 --command-line='$USER1$/centreon-plugins/centreon_plugins.pl --plugin=os::windows::snmp::plugin --mode=memory --hostname=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ $_HOSTSNMPEXTRAOPTIONS$ --warning=$_SERVICEWARNING$ --critical=$_SERVICECRITICAL$ $_SERVICEEXTRAOPTIONS$'
php external/bin/centreonConsole centreon-configuration:Command:create --command-name='OS-Windows-SNMP-cpu' --command-type=2 --command-line='$USER1$/centreon-plugins/centreon_plugins.pl --plugin=os::windows::snmp::plugin --mode=cpu --hostname=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ $_HOSTSNMPEXTRAOPTIONS$ --warning="$_SERVICEWARNING$"  --critical="$_SERVICECRITICAL$" $_SERVICEEXTRAOPTIONS$'
php external/bin/centreonConsole centreon-configuration:Command:create --command-name='OS-Windows-SNMP-swap' --command-type=2 --command-line='$USER1$/centreon-plugins/centreon_plugins.pl --plugin=os::windows::snmp::plugin --mode=swap --hostname=$HOSTADDRESS$ --snmp-version=$_HOSTSNMPVERSION$ --snmp-community=$_HOSTSNMPCOMMUNITY$ $_HOSTSNMPEXTRAOPTIONS$ --warning="$_SERVICEWARNING$" --critical="$_SERVICECRITICAL$" $_SERVICEEXTRAOPTIONS$'

echo " ==== Creating service templates ==== "
php external/bin/centreonConsole centreon-configuration:ServiceTemplate:create --description='generic-service' 
php external/bin/centreonConsole centreon-configuration:ServiceTemplate:update --service-template='generic-service' --max-check-attempts=3 --timeperiod='24x7'

php external/bin/centreonConsole centreon-configuration:ServiceTemplate:create --description='ping-lan' --alias='ping' --template-model-stm='generic-service' --command='check-centreon-ping'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='ping-lan' --name='WARNING' --value='200,20%'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='ping-lan' --name='CRITICAL' --value='400,50%'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='ping-lan' --name='PACKETNUMBER' --value='5'

php external/bin/centreonConsole centreon-configuration:ServiceTemplate:create --description='OS-Linux-SNMP-load' --alias='load' --template-model-stm='generic-service' --command='os-linux-snmp-load'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-linux-snmp-load' --name='WARNING' --value='4,3,2'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-linux-snmp-load' --name='CRITICAL' --value='6,5,4'

php external/bin/centreonConsole centreon-configuration:ServiceTemplate:create --description='OS-Linux-SNMP-cpu' --alias='cpu' --template-model-stm='generic-service' --command='os-linux-snmp-cpu'
php external/bin/centreonConsole centreon-configuration:ServiceTemplate:update --service-template='os-linux-snmp-cpu' --domain='cpu'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-linux-snmp-cpu' --name='WARNING' --value='80'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-linux-snmp-cpu' --name='CRITICAL' --value='90'

php external/bin/centreonConsole centreon-configuration:ServiceTemplate:create --description='OS-Linux-SNMP-memory' --alias='memory' --template-model-stm='generic-service' --command='os-linux-snmp-memory'
php external/bin/centreonConsole centreon-configuration:ServiceTemplate:update --service-template='os-linux-snmp-memory' --domain='memory'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-linux-snmp-memory' --name='WARNING' --value='80'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-linux-snmp-memory' --name='CRITICAL' --value='90'

php external/bin/centreonConsole centreon-configuration:ServiceTemplate:create --description='OS-Linux-SNMP-swap' --alias='swap' --template-model-stm='generic-service' --command='os-linux-snmp-swap'
php external/bin/centreonConsole centreon-configuration:ServiceTemplate:update --service-template='os-linux-snmp-swap' --domain='swap'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-linux-snmp-swap' --name='WARNING' --value='10'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-linux-snmp-swap' --name='CRITICAL' --value='30'

php external/bin/centreonConsole centreon-configuration:ServiceTemplate:create --description='OS-Linux-SNMP-traffic-name' --alias='traffic-name' --template-model-stm='generic-service' --command='os-linux-snmp-traffic-name'
php external/bin/centreonConsole centreon-configuration:ServiceTemplate:update --service-template='os-linux-snmp-traffic-name' --domain='traffic'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-linux-snmp-traffic-name' --name='WARNINGIN' --value='80'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-linux-snmp-traffic-name' --name='CRITICALIN' --value='90'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-linux-snmp-traffic-name' --name='WARNINGOUT' --value='80'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-linux-snmp-traffic-name' --name='CRITICALOUT' --value='90'

php external/bin/centreonConsole centreon-configuration:ServiceTemplate:create --description='OS-Linux-SNMP-disk-name' --alias='disk-name' --template-model-stm='generic-service' --command='os-linux-snmp-disk-name'
php external/bin/centreonConsole centreon-configuration:ServiceTemplate:update --service-template='os-linux-snmp-disk-name' --domain='filesystem'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-linux-snmp-disk-name' --name='WARNING' --value='80'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-linux-snmp-disk-name' --name='CRITICAL' --value='90'

# Windows
php external/bin/centreonConsole centreon-configuration:ServiceTemplate:create --description='OS-Windows-SNMP-cpu' --alias='cpu' --template-model-stm='generic-service' --command='os-windows-snmp-cpu'
php external/bin/centreonConsole centreon-configuration:ServiceTemplate:update --service-template='os-windows-snmp-cpu' --domain='cpu'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-windows-snmp-cpu' --name='WARNING' --value='80'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-windows-snmp-cpu' --name='CRITICAL' --value='90'
 
php external/bin/centreonConsole centreon-configuration:ServiceTemplate:create --description='OS-Windows-SNMP-memory' --alias='memory' --template-model-stm='generic-service' --command='os-windows-snmp-memory'
php external/bin/centreonConsole centreon-configuration:ServiceTemplate:update --service-template='os-windows-snmp-memory' --domain='memory'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-windows-snmp-memory' --name='WARNING' --value='80'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-windows-snmp-memory' --name='CRITICAL' --value='90'
 
php external/bin/centreonConsole centreon-configuration:ServiceTemplate:create --description='OS-Windows-SNMP-swap' --alias='swap' --template-model-stm='generic-service' --command='os-windows-snmp-swap'
php external/bin/centreonConsole centreon-configuration:ServiceTemplate:update --service-template='os-windows-snmp-swap' --domain='swap'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-windows-snmp-swap' --name='WARNING' --value='10'
php external/bin/centreonConsole  centreon-configuration:ServiceTemplate:addMacro --service-template='os-windows-snmp-swap' --name='CRITICAL' --value='30'

echo " ==== Creating host templates ==== "
php external/bin/centreonConsole centreon-configuration:HostTemplate:create --name='generic-host' 
php external/bin/centreonConsole centreon-configuration:HostTemplate:update --host-template='generic-host' --max-check-attempts=3 --service-templates='ping-lan' --command='check-host-alive' --snmp-community='public' --snmp-version='2c'
php external/bin/centreonConsole centreon-configuration:HostTemplate:addMacro --host-template='generic-host' --name='WARNING' --value='3000,80%'
php external/bin/centreonConsole centreon-configuration:HostTemplate:addMacro --host-template='generic-host' --name='CRITICAL' --value='5000,100%'
php external/bin/centreonConsole centreon-configuration:HostTemplate:addMacro --host-template='generic-host' --name='PACKETNUMBER' --value='1'

php external/bin/centreonConsole centreon-configuration:HostTemplate:create --name='OS-Linux-SNMP'  --service-templates='os-linux-snmp-cpu' --service-templates='os-linux-snmp-load' --service-templates='os-linux-snmp-swap' --service-templates='os-linux-snmp-memory' --host-templates='generic-host'

php external/bin/centreonConsole centreon-configuration:HostTemplate:create --name='OS-Windows-SNMP'  --service-templates='os-windows-snmp-cpu' --service-templates='os-windows-snmp-swap' --service-templates='os-windows-snmp-memory' --host-templates='generic-host'

echo " ==== Creating hosts ==== "
php external/bin/centreonConsole centreon-configuration:Host:create --name='Centreon-export' --alias='Centreon-export' --address='10.30.2.87' --host-templates='generic-host' --poller='central'
php external/bin/centreonConsole centreon-configuration:Host:create --name='CES3-RWE-PP' --alias='CES3-RWE-PP' --address='10.30.2.127' --host-templates='os-linux-snmp' --poller='central'
php external/bin/centreonConsole centreon-configuration:Host:create --name='CES3-QDE-PP-CES22' --alias='CES3-QDE-PP-CES22' --address='10.50.1.84' --host-templates='os-linux-snmp' --poller='central'
php external/bin/centreonConsole centreon-configuration:Host:create --name='CES3-QDE-PP-CES3' --alias='CES3-QDE-PP-CES3' --address='10.50.1.85' --host-templates='os-linux-snmp' --poller='central'

php external/bin/centreonConsole centreon-configuration:Host:create --name='SRVI-WIN-TEST' --alias='SRVI-WIN-TEST' --address='10.50.1.158' --host-templates='os-windows-snmp' --poller='central'
php external/bin/centreonConsole centreon-configuration:Host:create --name='Terminal server GSO' --alias='Terminal server GSO' --address='10.41.1.28' --host-templates='os-windows-snmp' --poller='central'

echo " ==== Creating services  ==== "
php external/bin/centreonConsole centreon-configuration:Service:create --description='Traffic-eth0' --host='ces3-rwe-pp' --template-model-stm='OS-Linux-SNMP-traffic-name'
php external/bin/centreonConsole centreon-configuration:Service:addMacro --service='ces3-rwe-pp-traffic-eth0' --name='INTERFACENAME' --value='eth0' 

php external/bin/centreonConsole centreon-configuration:Service:create --description='Traffic-eth0' --host='ces3-qde-pp-ces22' --template-model-stm='OS-Linux-SNMP-traffic-name'
php external/bin/centreonConsole centreon-configuration:Service:addMacro --service='ces3-qde-pp-ces22-traffic-eth0' --name='INTERFACENAME' --value='eth0'

php external/bin/centreonConsole centreon-configuration:Service:create --description='Traffic-eth0' --host='ces3-qde-pp-ces3' --template-model-stm='OS-Linux-SNMP-traffic-name'
php external/bin/centreonConsole centreon-configuration:Service:addMacro --service='ces3-qde-pp-ces3-traffic-eth0' --name='INTERFACENAME' --value='eth0'

php external/bin/centreonConsole centreon-configuration:Service:create --description='Disk-/' --host='ces3-rwe-pp' --template-model-stm='OS-Linux-SNMP-disk-name'
php external/bin/centreonConsole centreon-configuration:Service:addMacro --service='ces3-rwe-pp-disk' --name='DISKNAME' --value='/'

php external/bin/centreonConsole centreon-configuration:Service:create --description='Disk-/' --host='ces3-qde-pp-ces22' --template-model-stm='OS-Linux-SNMP-disk-name'
php external/bin/centreonConsole centreon-configuration:Service:addMacro --service='ces3-qde-pp-ces22-disk' --name='DISKNAME' --value='/'

php external/bin/centreonConsole centreon-configuration:Service:create --description='Disk-/' --host='ces3-qde-pp-ces3' --template-model-stm='OS-Linux-SNMP-disk-name'
php external/bin/centreonConsole centreon-configuration:Service:addMacro --service='ces3-qde-pp-ces3-disk' --name='DISKNAME' --value='/'

echo " ==== Creating (global) tags  ==== "
# Targeting all hosts having the same template
php external/bin/centreonConsole centreon-configuration:HostTemplate:addTag --host-template='os-linux-snmp' --tag='Linux servers'
php external/bin/centreonConsole centreon-configuration:HostTemplate:addTag --host-template='os-windows-snmp' --tag='Windows servers'

# Host by host
php external/bin/centreonConsole centreon-configuration:Host:addTag --host='ces3-rwe-pp' --tag='Plugins Packs servers'
php external/bin/centreonConsole centreon-configuration:Host:addTag --host='ces3-qde-pp-ces22' --tag='Plugins Packs servers'
php external/bin/centreonConsole centreon-configuration:Host:addTag --host='ces3-qde-pp-ces3' --tag='Plugins Packs servers'
php external/bin/centreonConsole centreon-configuration:Host:addTag --host='srvi-win-test' --tag='Plugins Packs servers'

php external/bin/centreonConsole centreon-configuration:Host:addTag --host='ces3-rwe-pp' --tag='Centreon servers'
php external/bin/centreonConsole centreon-configuration:Host:addTag --host='ces3-qde-pp-ces22' --tag='Centreon servers'
php external/bin/centreonConsole centreon-configuration:Host:addTag --host='ces3-qde-pp-ces3' --tag='Centreon servers'

echo " ==== Creating KPI and BA ==== "
php external/bin/centreonConsole centreon-bam:BusinessActivity:create --name='BA sur les ping des machines des PP' --ba-type-id='business-unit' --level-w=70 --level-c=50

php external/bin/centreonConsole centreon-bam:Indicator:create --ba='ba-sur-les-ping-des-machines-des-pp' --type='service' --service-slug='ces3-rwe-pp-ping' --drop-warning='10' --drop-critical='50' --drop-unknown='30'
php external/bin/centreonConsole centreon-bam:Indicator:create --ba='ba-sur-les-ping-des-machines-des-pp' --type='service' --service-slug='ces3-qde-pp-ces22-ping' --drop-warning='10' --drop-critical='50' --drop-unknown='30'
php external/bin/centreonConsole centreon-bam:Indicator:create --ba='ba-sur-les-ping-des-machines-des-pp' --type='service' --service-slug='ces3-qde-pp-ces3-ping' --drop-warning='10' --drop-critical='50' --drop-unknown='30'

php external/bin/centreonConsole centreon-bam:BusinessActivity:create --name='BA sur les memory des machines des PP' --ba-type-id='business-unit' --level-w=70 --level-c=50
php external/bin/centreonConsole centreon-bam:Indicator:create --ba='ba-sur-les-memory-des-machines-des-pp' --type='service' --service-slug='ces3-rwe-pp-memory' --drop-warning='10' --drop-critical='50' --drop-unknown='30'
php external/bin/centreonConsole centreon-bam:Indicator:create --ba='ba-sur-les-memory-des-machines-des-pp' --type='service' --service-slug='ces3-qde-pp-ces22-memory' --drop-warning='10' --drop-critical='50' --drop-unknown='30'
php external/bin/centreonConsole centreon-bam:Indicator:create --ba='ba-sur-les-memory-des-machines-des-pp' --type='service' --service-slug='ces3-qde-pp-ces3-memory' --drop-warning='10' --drop-critical='50' --drop-unknown='30'

# Put the 2 BAs in a new BA
php external/bin/centreonConsole centreon-bam:BusinessActivity:create --name='BA ping + memory PP' --ba-type-id='business-unit' --level-w=70 --level-c=50
php external/bin/centreonConsole centreon-bam:Indicator:create --ba='ba-ping-memory-pp' --type='BA' --indicator-ba-slug='ba-sur-les-ping-des-machines-des-pp' --drop-warning='10' --drop-critical='50' --drop-warning='30'
php external/bin/centreonConsole centreon-bam:Indicator:create --ba='ba-ping-memory-pp' --type='BA' --indicator-ba-slug='ba-sur-les-memory-des-machines-des-pp' --drop-warning='10' --drop-critical='50' --drop-warning='30'

echo " ==== Generating Configuration ==== "

php external/bin/centreonConsole centreon-configuration:Config:generate --poller=central
php external/bin/centreonConsole centreon-configuration:Config:move --poller=central

echo " ==== Restarting Engine and Broker ==== "
php external/bin/centreonConsole centreon-configuration:Config:apply --poller=central --action=restart

echo " ==== That's all for now, we've already suffered so much to do it, please applause ==== "
