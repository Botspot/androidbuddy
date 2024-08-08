# AndroidBuddy ![logo](https://github.com/Botspot/androidbuddy/blob/main/logo.png?raw=true)
Manage your Android phone from a Linux computer.  
File transfer, file browsing and in-place editing, screen control, tethering, reverse tethering, and an autostsrt feature when a phone is detected.

What do I use AndroidBuddy for?
- Move big videos to my computer and then delete them from the phone
- Share my fast ethernet connection with my phone
- Respond to texts with a full size keyboard
- Copy and paste links and other text between computer and phone

This should work on any Debian-based distro regardless of CPU architecture, but it has been tested on ARM64 Raspberry Pi OS.  
The dependencies to run are minimal.
```
sudo apt install yad adb
```
To use reverse tethering, a minimal rust compilation toolchain is required in order for AndroidBuddy to compile `gnirehtet`.
```
sudo apt install rustc cargo
```
To browse files, this package needs to be installed and configured: (On most distros it already is)
```
sudo apt install gvfs-backends
```
To control the screen, you need Scrcpy, which is not available on the Debian repositories.  
   If you have an ARM-based machine, just [install Scrcpy with Pi-Apps.](https://pi-apps.io/install-app/install-scrcpy-on-raspberry-pi/)  
   Otherwise, follow the install instructions that can be found [here.](https://github.com/Genymobile/scrcpy/blob/master/doc/linux.md)  
## Download and run
```
git clone https://github.com/Botspot/androidbuddy
./androidbuddy/main.sh
```
In a few days, AndroidBuddy will be added to Pi-Apps, and once that happens, if you have an ARM Linux device, just install it from there.  
[![badge](https://github.com/Botspot/pi-apps/blob/master/icons/badge.png?raw=true)](https://github.com/Botspot/pi-apps)  
AndroidBuddy is intended to be run as a normal user. When it needs escalated permissions, it will try to use passwordless sudo, and if that fails, it will fallback to a password prompt dialog.  

## Usage

1. Connect your favorite Android device to your Linux computer using a USB cable.  
    1.1. Make sure that USB debugging is enabled. If AndroidBuddy detects an Android device with USB debugging disabled, instructions will be displayed for how to enable it.  
    1.2. Be sure to use a USB cable that has communication pins. Some cheap cables only supply charging power, and cannot be used.  
2. Click the buttons.  
    ![20240808_01h20m17s_grim](https://github.com/user-attachments/assets/48d7f626-bf6b-42d1-81a5-da56bc13e667)
3. There is no step 3. This should be pretty self-explanatory. Hover the mouse over a button to learn more about it.
4. [Open an issue](https://github.com/Botspot/androidbuddy/issues/new/choose) if you encounter any problems or have a question.

## Uninstall
On first run, AndroidBuddy will copy its icon to the user's icons directory and create a menu launcher for convenient future usage. To remove these, run this command:
```
rm -f ~/.local/share/applications/androidbuddy.desktop ~/.local/share/icons/androidbuddy.png
```

## Updates
AndroidBuddy will automatically keep itself updated using `git pull` when necessary.

## Configuration

There are no settings or options. This app follows the KISS principle. Change the script to your liking if you need to adjust its behavior. If you make a new useful feature and want to see it added, please [open a Pull Request!](https://github.com/Botspot/androidbuddy/pulls)

Thanks for reading!  
-Botspot  
PS. I wrote this in 4 hours for my own personal use, and if you want to chat or need help then consider joining [my Discord Server.](https://discord.gg/RXSTvaUvuu)
