#!/usr/bin/env bash
start=`date +%s`
# This script will prep the host from the ground up for this project


#####################################################
#              VARIABLES							#
#####################################################
boxes=${1:-'default'}
boxes=${1:-'proxy stack'}
replace_config=1
replace_roles=1

#####################################################
#              FUNCTIONS CODE BLOCK                 #
#####################################################
print() {
	echo 'Test.sh =>'
	echo "Test.sh => $1"
	echo 'Test.sh =>'
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
	print "vm_start ==> Starting Box: $name"
	vagrant up -p virtualbox $name
	print "vm_start ==> Box Started: $name"
}

vm_destroy() {
	name=$1
	running=$(vagrant status $name | grep "$name.*running") && return 0 || return 1
	if [ $running == 0 ]; then
		print "vm_destroy ==> Destroying Box: $name"
		vagrant box destroy -f $name
		print "vm_destroy ==> Destroyed Box: $name"
	fi
}

vm_provision() {
	name=$1
	# Puppet
	# Salt
	# Ansible
}

check_installed() {
	
}

#####################################################
#	 	PROJECT REQUIREMENTS # THIRD PARTY APPS   	#
#####################################################

# This project requires the use of the Vagrant HostManager Plugin
hostman_installed=$(vagrant plugin list | grep 'hostman*')
if [ -z "$hostman_installed" ]; then      # -z: true if var is len 0
	vagrant plugin install vagrant-hostmanager
fi

# Install Ansible
installed=$(which ansible && echo $?)
if [ $installed == '1' ]; then
	# Check for brew
	brew_installed=$(which brew && echo $?)
	if [ $brew_installed == '1' ]; then
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi
	brew install ansible
fi

#####################################################
#	 	MAIN CODE BLOCK # PLACE CUSTOM CODE HERE   	#
#####################################################

# Template ansible.cfg
if [ $replace_config == 1]; then
	if [ ! -e 'ansible.cfg' ]; then
		# Remove ansible.cfg
		rm -f ansible.cfg
	fi
	# Download config
	curl -s https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg -o ansible.cfg
fi

# New Settings
sed_replace '#roles_path' 'roles_path = ansible/roles'

# Ansible Galaxy
if [ $replace_roles == 1 ]; then
	if [ ! -d 'ansible/roles' ]; then
		# Remove Ansible Roles
		rm -rf ansible/roles
	fi
	# Download desired Ansible Roles
	
fi

print "Boxes are: $boxes"
for box in $boxes; do
	vm_destroy $box
	vm_start $box
	vm_provision $box
done

#####################################################
#	END CODE BLOCK # DO NOT PUT CODE BELOW HERE    	#
#####################################################

print "!!! SCRIPT COMPLTED !!!"
# Grab the current time and calculate how long all this took
end=`date +%s`
print "Total execution time: $((end-start)) seconds"
exit 0

