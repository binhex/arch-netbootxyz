#!/usr/bin/dumb-init /bin/bash
# shellcheck shell=bash

function setup() {

	bootloader_path="/config/netbootxyz/bootloaders"
	dnsmasq_config_path="/config/netbootxyz/dnsmasq"
	dnsmasq_config_filepath="/etc/dnsmasq.conf"

	mkdir -p "${dnsmasq_config_path}" "${bootloader_path}"

}

function check_for_new_release() {

	# TODO check if release version changes if so download, needs to be in a loop
	# TODO define another env var where the user decides how often to check and if to check for new netbootxyz releases
	download="yes" # REMOVE THIS!!!

	if [[ "${download}" == "yes" ]]; then
		download_netbootxyz
	fi

}

function download_netbootxyz() {

	# download netboot.xyz bootloader for bios and uefi
	github.sh --install-path "${bootloader_path}" --github-owner 'netbootxyz' --github-repo 'netboot.xyz' --query-type 'release' --download-branch 'main' --download-assets 'netboot.xyz.efi,netboot.xyz.kpxe'

}

function set_bootloader() {

	BOOTLOADER_TYPE="uefi" # REMOVE THIS!!
	if [[ -z "${BOOTLOADER_TYPE}" ]]; then
		echo "Bootloader type not set via env var 'BOOTLOADER_TYPE', exiting script..."
		exit 1
	fi

	if [[ "${BOOTLOADER_TYPE}" == 'bios' ]]; then
		bootloader_image_file="netboot.xyz.kpxe"
	elif [[ "${BOOTLOADER_TYPE}" == 'uefi' ]]; then
		bootloader_image_file="netboot.xyz.efi"
	else
		echo "Bootloader type '${BOOTLOADER_TYPE}' incorrect, valid options are 'bios|uefi', exiting script..."
		exit 1
	fi

}

function run_dnsmasq() {

	# copy default netmasq config file to /config
	if [[ ! -f "${dnsmasq_config_path}" ]]; then
		cp "${dnsmasq_config_filepath}" "${dnsmasq_config_path}"
	fi

	/usr/sbin/dnsmasq --enable-tftp "--tftp-root=${bootloader_path}" "--dhcp-boot=${bootloader_image_file}" "--conf-dir=${dnsmasq_config_path}" --port=0

}

function main() {

	setup
	check_for_new_release
	set_bootloader
	run_dnsmasq

}

# kickoff
main
