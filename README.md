# AndroidBuddy ![logo](https://github.com/Botspot/androidbuddy/blob/main/logo.png?raw=true)
Manage your Android phone from a Linux computer.  
File transfer, file browsing and in-place editing, screen control, tethering, reverse tethering, and an autostart feature when a phone is detected.

What do I use AndroidBuddy for?
- Reducing eye strain and improving posture by using the phone on a large screen that is farther away.
- Moving big videos to my computer to delete them from the phone
- Sharing my fast ethernet connection with my phone
- Using my phone's WiFi or mobile data connection, which is sometimes more reliable than my computer's built-in WiFi connection
- Responding to texts with a full size keyboard
- Copying and pasting links and other text between computer and phone

AndroidBuddy should work on any Debian-based distro regardless of CPU architecture, but it has been tested on ARM64 Raspberry Pi OS.  
If your system is Raspberry Pi or ARM Linux, just install it with the Pi-Apps store.  
[![badge](https://github.com/Botspot/pi-apps/blob/master/icons/badge.png?raw=true)](https://github.com/Botspot/pi-apps) <-- Pi-Apps lets you install AndroidBuddy with a few simple clicks.  

<details>
<summary><b>For advanced setup and manual installation straight from this repository: (click to expand)</summary>

```
sudo apt install yad adb
```
Some features require additional dependencies.
- To use reverse tethering, a minimal rust compilation toolchain is required in order for AndroidBuddy to compile `gnirehtet`.
    ```
    sudo apt install rustc cargo
    ```
    AndroidBuddy will try to install these if you click "Share internet to phone"
- To browse files, this package needs to be installed and configured: (On most distros it already is)
    ```
    sudo apt install gvfs-backends
    ```
    AndroidBuddy will try to install this if you click "Browse phone's files"
- To control the screen, you need Scrcpy, which is not available on the Debian repositories.  
  - If you have an ARM-based machine, just [install Scrcpy with Pi-Apps.](https://pi-apps.io/install-app/install-scrcpy-on-raspberry-pi/)  
  - Otherwise, follow the install instructions that can be found [here.](https://github.com/Genymobile/scrcpy/blob/master/doc/linux.md)  
- For AndroidBuddy to launch automatically when a phone is detected, your distro needs to be using udev. Most distros do, but if yours does not, you will need to enable that yourself.

</details>

## Download and run
```
git clone https://github.com/Botspot/androidbuddy
./androidbuddy/main.sh
```
AndroidBuddy is intended to be run as a normal user. When it needs escalated permissions, it will try to use passwordless sudo, and if that fails, it will fallback to a password prompt dialog.  

## Usage

1. Connect your favorite Android device to your Linux computer using a USB cable.  
    1.1. Make sure that **USB debugging** is enabled. If AndroidBuddy detects an Android device with USB debugging disabled, instructions will be displayed for how to enable it.  
    1.2. Be sure to use a USB cable that has communication pins. Some cheap cables only supply charging power, and cannot be used.  
2. Click the buttons.  
    ![20250105_14h24m58s_grim](https://github.com/user-attachments/assets/a465d0eb-0188-491f-b0bb-5d7622a4b7dc)
3. There is no step 3. This should be pretty self-explanatory. Hover the mouse over a button to learn more about it.
4. [Open an issue](https://github.com/Botspot/androidbuddy/issues/new/choose) if you encounter any problems or have a question.

## Uninstall
On first run, AndroidBuddy will copy its icon to the user's icons directory and create a menu launcher for convenient future usage. To remove these, run this command:
```
rm -f ~/.local/share/applications/androidbuddy.desktop ~/.local/share/icons/androidbuddy.png
```
If you used the reverse tethering feature: 
```
sudo rm -rf /usr/bin/gnirehtet /opt/gnirehtet
```

## Updates
AndroidBuddy will automatically keep itself updated using `git pull` when necessary.

## Configuration

There are no settings or options. This app follows the KISS principle. Change the script to your liking if you need to adjust its behavior. If you make a new useful feature and want to see it added, please [open a Pull Request!](https://github.com/Botspot/androidbuddy/pulls) I would love to add new features, such as bluetooth support, which should actually be fairly straightforward since adb and scrcpy support that.

## Similar projects and what's wrong with them
- [scrcpy-gui](https://github.com/Tomotoes/scrcpy-gui) - only deals with controlling the screen, and the project is abandoned
- [guiscrcpy](https://github.com/srevinsaju/guiscrcpy) - only deals with controlling the screen, and the project is abandoned
- [scrcpy-plus](https://github.com/Frontesque/scrcpy-plus) - only deals with controlling the screen
- [droidbuddy](https://gitlab.com/gazlene/droidbuddy) - only major features are file transfer, APK installation, and screen control, and the project is abandoned

Thanks for reading!  
-Botspot  
PS. It took me 4 hours to make AndroidBuddy for my own personal use because I was tired of using droidbuddy. If you want to chat or need help then consider joining [my Discord Server.](https://discord.gg/RXSTvaUvuu)
