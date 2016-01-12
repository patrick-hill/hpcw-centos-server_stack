#!/usr/bin/env bash
#####################################################
#              VARIABLES							#
#####################################################
start=`date +%s`
boxes=${1:-'default'}
boxes=${1:-'proxy stack'}
replace_config=true
replace_roles=false

#####################################################
#              FUNCTIONS CODE BLOCK                 #
#####################################################
print() {
	echo '* * test.sh ==>'
	echo "* * test.sh ==> $@"
	echo '* * test.sh ==>'
}

in_list() {
	[[ $1 =~ $2 ]] && return 0 || return 1	
}

sed_replace() {
	sed -i '' "s|.*$1.*|$2|" ansible.cfg
}

vm_check_status() {
	name=$1
	$(vagrant status $name | grep "$name.*running") && return 0 || return 1
}

vm_start() {
	name=$1
    exitCode=1
    if $(in_list $name); then
        print "vm_start ==> Starting Box: $name"
        vagrant up --provider=virtualbox $name
        exitCode=$?
    fi
  [[ $exitCode == 0 ]] && return 0 || return 1
}

vm_destroy() {
	name=$1
    exitCode=1
	running=$(vagrant status $name | grep -ic "$name.*running")
	if [ "$running" == '1' ]; then
		print "vm_destroy ==> Destroying Box: $name"
		vagrant destroy -f $name
        exitCode=$?
	fi
  [[ $exitCode == 0 ]] && return 0 || return 1
}

vm_provision() {
	name=$1
	# Puppet:  Call Puppet Apply
	# Salt:    Done with Vagrant
	# Ansible: Done with Vagrant
}
#####################################################
#	 	PROJECT REQUIREMENTS # THIRD PARTY APPS   	#
#####################################################

# This project requires the use of the Vagrant HostManager Plugin
hostman_installed=$(vagrant plugin list | grep 'hostman*')
if [ "$hostman_installed" == '1' ]; then
	vagrant plugin install vagrant-hostmanager
fi

# Install Ansible
installed=$(which ansible && echo $?)
if [ "$installed" == '1' ]; then
	# Check for brew
	brew_installed=$(which brew && echo $?)
	if [ "$brew_installed" == '1' ]; then
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi
	brew install ansible
fi

# Template ansible.cfg
if [ $replace_config == true ]; then
	if [ ! -e 'ansible.cfg' ]; then
		# Remove ansible.cfg
		rm -f ansible.cfg
	fi
	# Download config
	curl -s https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg -o ansible.cfg
fi
#####################################################
#	 	MAIN CODE BLOCK # PLACE CUSTOM CODE HERE   	#
#####################################################

# ansible.cfg Settings
sed_replace '#roles_path' 'roles_path = ansible/roles'
sed_replace '#callback_plugins' 'callback_plugins = ansible/plugins' # Source: https://gist.github.com/cliffano/9868180

# Ansible Galaxy
if [ $replace_roles == true ]; then
	if [ ! -d 'ansible/roles' ]; then
		# Remove Ansible Roles
		rm -rf ansible/roles
	fi
	# Download desired Ansible Roles
	
fi

print "Boxes are: $boxes"
for box in $boxes
do
	vm_destroy $box
    if (vm_start $box && vm_provision $box); then
        vagrant reload $box
        print "!!! SCRIPT COMPLTED !!!"
    else
        print "!!! ERROR !!!    Unable to bring up box: $box    !!! ERROR !!!"
    fi
done
#####################################################
#	END CODE BLOCK # DO NOT PUT CODE BELOW HERE    	#
#####################################################
# Grab the current time and calculate how long all this took
end=`date +%s`
print "Total execution time: $((end-start)) seconds"
exit 0

