#!/usr/bin/dumb-init /bin/bash
# shellcheck shell=bash

function setup() {

	bootloader_path="/config/netbootxyz/bootloaders"
	bootloader_path_bios="${bootloader_path}/bios"
	bootloader_path_uefi="${bootloader_path}/uefi"
	mkdir -p "${bootloader_path_bios}" "${bootloader_path_uefi}"
	# TODO expose /etc/dnsmaq.conf to /config

}

function check_netboot_release_version() {

	# TODO check if release version changes if so download, needs to be in a loop
	download="yes" # REMOVE THIS!!!

	if [[ "${download}" == "yes" ]]; then
		download_netbootxyz
	fi

}

function download_netbootxyz() {

	# download netboot.xyz bootloader for bios and uefi
	github.sh --install-path "${bootloader_path}" --github-owner 'netbootxyz' --github-repo 'netboot.xyz' --query-type 'release' --download-branch 'main' --download-assets 'netboot.xyz.efi,netboot.xyz.kpxe'

	# move bootloaders to the correct folders
	mv "${bootloader_path}/netboot.xyz.kpxe" "${bootloader_path_bios}/netboot.xyz.kpxe"
	mv "${bootloader_path}/netboot.xyz.efi" "${bootloader_path_uefi}/netboot.xyz.efi"

}

function configure_netmasq() {

	BOOTLOADER_TYPE="uefi" # REMOVE THIS!!
	if [[ -z "${BOOTLOADER_TYPE}" ]]; then
		echo "Bootloader type not set via env var 'BOOTLOADER_TYPE', exiting script..."
		exit 1
	fi

	if [[ "${BOOTLOADER_TYPE}" == 'bios' ]]; then
		bootloader_image_file="netboot.xyz.kpxe"
		bootloader_image_path="${bootloader_path_bios}"
	elif [[ "${BOOTLOADER_TYPE}" == 'uefi' ]]; then
		bootloader_image_file="netboot.xyz.efi"
		bootloader_image_path="${bootloader_path_uefi}"
	else
		echo "Bootloader type '${BOOTLOADER_TYPE}' incorrect, valid options are 'bios|uefi', exiting script..."
		exit 1
	fi

	dnsmasq_config_filepath="/etc/dnsmasq.conf"

	# edit dnsmasq config to enable tftpm set dhcp-boot file, and disable dns
	sed -i -e 's~^#enable-tftp.*~enable-tftp~g' "${dnsmasq_config_filepath}"
	sed -i -e "s~^#tftp-root=.*~tftp-root=${bootloader_image_path}~g" "${dnsmasq_config_filepath}"
	sed -i -e "s~^#dhcp-boot=.*~dhcp-boot=${bootloader_image_file}~g" "${dnsmasq_config_filepath}"
	sed -i -e 's~^#port=.*~port=0~g' "${dnsmasq_config_filepath}"

}


function run_dnsmasq() {
	/usr/sbin/dnsmasq
}

function main() {

	setup
	check_netboot_release_version
	configure_netmasq
	run_dnsmasq

}

# kickoff
main
