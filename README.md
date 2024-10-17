**Application**

[iVentoy](https://www.iventoy.com/en/index.html)

**Description**

iVentoy is an enhanced version of the PXE server. With iVentoy you can boot and install OS on multiple machines at the same time through the network. iVentoy is extremely easy to use, without complicated configuration, just put the ISO file in the specified location and select PXE boot in the client machine. iVentoy supports x86 Legacy BIOS, IA32 UEFI, x86_64 UEFI and ARM64 UEFI mode at the same time. iVentoy support 110+ common types of OS (Windows/WinPE/Linux/VMware).

**Build notes**

Latest GitHub release.

**Usage**
```
docker run -d \
    --name=<container name> \
    -p <webui port>:26000 \
    -v <path for config files>:/config \
    -v /etc/localtime:/etc/localtime:ro
    -e UMASK=<umask for created files> \
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \
    binhex/arch-iventoy
```

Please replace all user variables in the above command defined by <> with the correct values.

**Access application**

`http://<host ip>:26000`

**Example**
```
docker run -d \
    --name=iventoy \
    -p 26000:26000 \
    -v /apps/docker/iventoy:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e UMASK=000 \
    -e PUID=0 \
    -e PGID=0 \
    binhex/arch-iventoy
```

**Notes**

User ID (PUID) and Group ID (PGID) can be found by issuing the following command for the user you want to run the container as:-

```
id <username>
```
___
If you appreciate my work, then please consider buying me a beer  :D

[![PayPal donation](https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=MM5E27UX6AUU4)

[Documentation](https://github.com/binhex/documentation) | [Support forum](https://forums.unraid.net/topic/174999-support-binhex-bitmagnet)