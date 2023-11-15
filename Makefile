wifi_host=rem# you can also use the network ip address here
#Here is my config in ~/.ssh/config file
#Host rem
#  HostName [IP_ADDRESS]
#  AddKeysToAgent yes
#  UseKeychain yes
#  IdentityFile [YOUR_PUBLIC_KEY]
#  User root
usb_host=10.11.99.1

define install
	# make sure ssh agent is running
	eval $(shell ssh-agent -s)

	# Sending the PNG files to reMarkable
	scp templates/pngs/*.png root@$1:/usr/share/remarkable/templates

	# Receiving the current templates.json to add our custom templates
	scp root@$1:/usr/share/remarkable/templates/templates.json ./templates.json

	# Adding the custom templates to templates.json
	jq -n '{ templates: [ inputs.templates ] | add | unique_by([.name, .landscape])}' templates.json templates.addition.json > templates.merged.json

	# Taking a backup of the templates.json in any case
	ssh root@$1 "cp /usr/share/remarkable/templates/templates.json /usr/share/remarkable/templates/templates.backup.json"

	# Replacing the templates.json on the device with merged one
	scp templates.merged.json root@$1:/usr/share/remarkable/templates/templates.json

	# Restarting the GUI service
	ssh root@$1 "systemctl restart xochitl"

endef


install_usb:
	$(call install,$(usb_host))

install_wifi:
	$(call install,$(wifi_host))
