# General Tips

## Enter UEFI/BIOS configuration:

- select `Windows menu key > Power > Hold Shift + Restart`.

- then select `Troubleshoot > Advanced Options > UEFI Firmware Settings`.

  <img src="./images/restart-choose-an-option.png" alt="restart choose an option" height="300px"/>
  <img src="./images/restart-troubleshoot.png" alt="restart troubleshoot" height="300px"/>
  <br/>
  <img src="./images/restart-advanced-options.png" alt="restart advanced options" height="300px"/>

See [How to enter BIOS configuration?](https://www.asus.com/support/faq/1013015/) or [How to Access UEFI BIOS in Windows 10](https://www.cocosenor.com/articles/windows-10/access-uefi-bios-in-windows-10.html) for alternative methods.

## Troubleshooting

If, for any reason, the system does not boot and prompt you to Arch emergency shell:

```
Error: unable to find root device 'UUID=<uuid>'
You are now being dropped into a emergency shell.
```

1.  Reboot the system

1.  Insert an Arch Linux installer USB drive.

1.  Using the GRUB interface, enter the UEFI/BIOS configuration:

    - if available, select the "firmware setup" option
    - type `c` to go to GRUB command line and run `fwsetup`

1.  From the UEFI/BIOS select the USB drive

1.  Access and edit your Linux file system from the USB drive using the `mnt` and `arch-chroot` commands