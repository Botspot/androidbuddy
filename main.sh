#!/bin/bash

scrcpyflags=(--legacy-paste --turn-screen-off --stay-awake --power-off-on-close)

error() { #red text and exit 1
  echo -e "\e[91m$1\e[0m" 1>&2
  exit 1
}

sudo_popup() { #just like sudo on passwordless systems like PiOS, but displays a password dialog otherwise. Avoids displaying a password prompt to an invisible terminal.
  if sudo -n true; then
    # sudo is available (within sudo timer) or passwordless
    sudo "$@"
  else
    # sudo is not available (not within sudo timer)
    pkexec "$@"
  fi
}

process_exists() { #return 0 if the $1 PID is running, otherwise 1
  [ -z "$1" ] && error "process_exists(): no PID given!"
  
  if [ -f "/proc/$1/status" ];then
    return 0
  else
    return 1
  fi
}

install_gnirehtet() {
  if [ ! -d /opt/gnirehtet ] || [ ! -f /usr/bin/gnirehtet ];then
    if ! command -v cargo >/dev/null ;then
      sudo_popup apt update
      sudo_popup apt install -y cargo || error "cargo is required but it failed to install."
    fi
    
    if ! command -v rustc >/dev/null ;then
      sudo_popup apt update
      sudo_popup apt install -y rustc || error "rustc is required but it failed to install."
    fi
    
    #get apk
    rm -rf /tmp/gnirehtet-java
    wget -O /tmp/gnirehtet-java.zip 'https://github.com/Genymobile/gnirehtet/releases/download/v2.5.1/gnirehtet-java-v2.5.1.zip' || error "Failed to download gnirehtet-java-v2.5.1.zip"
    unzip /tmp/gnirehtet-java.zip -d /tmp/gnirehtet-java || error "Failed to extract gnirehtet-java-v2.5.1.zip"
    sudo_popup rm -rf /opt/gnirehtet || error "Failed to remove /opt/gnirehtet"
    sudo_popup mkdir -p /opt/gnirehtet
    sudo_popup mv /tmp/gnirehtet-java/gnirehtet-java/gnirehtet.apk /opt/gnirehtet || error "Failed to move gnirehtet.apk to /opt/gnirehtet"
    rm -rf /tmp/gnirehtet-java
    
    #compile gnirehtet command
    rm -rf /tmp/gnirehtet
    cd /tmp
    git clone https://github.com/Genymobile/gnirehtet || error "Failed to download gnirehtet github repository"
    cd /tmp/gnirehtet/relay-rust
    cargo build --release || error "Failed to build gnirehtet with cargo and rust"
    cd
    sudo_popup mv /tmp/gnirehtet/relay-rust/target/release/gnirehtet /opt/gnirehtet || error "Failed to move gnirehtet to /opt/gnirehtet"
    rm -rf /tmp/gnirehtet
    
    #make command
    echo '#!/bin/bash
cd /opt/gnirehtet
/opt/gnirehtet/gnirehtet "$@"' > /tmp/gnirehtet
    chmod +x /tmp/gnirehtet || error "Failed to mark /tmp/gnirehte as executable!"
    sudo_popup mv -f /tmp/gnirehtet /usr/bin/gnirehtet || error "Failed to move /tmp/gnirehte to /usr/bin"
  fi
  
  if [ "$gnirehtet_installed" == false ];then
    gnirehtet install || error "Failed to install the gnirehtet.apk on your phone!"
    gnirehtet_installed=true
  fi
}

wait_for_reconnect() {
  for i in {1..20} ;do
    if adb shell pm list packages &>/dev/null ;then
      return 0
      break
    fi
    sleep 0.1
  done
}

scrcpy_daemon() {
  if ! command -v scrcpy >/dev/null ;then
    error "scrcpy not installed! Please use Pi-Apps to install scrcpy. https://github.com/Botspot/pi-apps"
  fi
  
  local exitcode
  local tries=0
  while true;do
    scrcpy "$@" &>/dev/null &
    local pid=$!
    trap "kill $pid" EXIT
    wait $pid
    exitcode=$?
    if [ $exitcode == 2 ] ;then
      tries=0
      #give the device 2 seconds to reconnect
      wait_for_reconnect || error "phone disconnected"
    elif [ $exitcode == 0 ];then
      #user closed scrcpy
      break
    else
      #exit code was 1
      tries=$((tries+1))
      [ $tries == 5 ] && error "scrcpy exited unexpectedly. Perhaps the phone disconnected."
      wait_for_reconnect || error "phone disconnected"
    fi
  done
}

#wait for phone to be plugged in
exitcode=first
echo -n "Waiting for phone... "
while [ $exitcode != 0 ];do
  [ "$exitcode" != first ] && sleep 5
  installed_apks="$(adb shell pm list packages 2>/dev/null)"
  exitcode=$?
done
echo Done

if ! command -v yad >/dev/null ;then
  sudo_popup apt update
  sudo_popup apt install -y yad || error "yad is required but it failed to install."
fi

my_pid=$$

gnirehtet_installed="$(grep -xFq "package:com.genymobile.gnirehtet" <<<"$installed_apks" && echo true || echo false)"
echo "gnirehtet_installed: $gnirehtet_installed"

yad --form --center --no-buttons --title=AndroidBuddy --auto-close \
  --field='Show/hide screen!!View and control phone screen with scrcpy':FBTN 'echo scrcpy' \
  --field='Share internet to phone!!Share my internet connection with the phone (reverse tethering)':FBTN 'echo gnirehtet' \
  --field='Use phone'\''s internet!!Have this computer use the phone'\''s mobile network connection (tethering)':FBTN 'echo tethering' \
  --field='Browse phone'\''s files!!View the filesystem of the phone in a file manager':FBTN 'echo mtp' \
  --field='Send files!!Quick-drop files into the phone'\''s Download folder':FBTN 'echo quickdrop' \
  --field='Run when phone detected!!Launch AndroidBuddy when an Android phone is plugged in':FBTN 'bash -c "echo autostart $YAD_PID"' | \
while read -r input; do
  echo "Received '$input'"
  
  case "$input" in
    scrcpy)
      #toggle scrcpy (kill it if found, otherwise run it)
      if [ ! -z "$scrcpy_daemon_pid" ] && process_exists "$scrcpy_daemon_pid" ;then
        echo "scrcpy running, killing it"
        kill "$scrcpy_daemon_pid"
      else
        scrcpy_daemon "${scrcpyflags[@]}" &
        scrcpy_daemon_pid=$!
      fi
      ;;
    gnirehtet)
        install_gnirehtet
        gnirehtet run || error "failed to run gnirehtet for reverse tethering"
      ;;
    tethering)
      adb shell settings put global tether_dun_required 0 || error "adb command failed"
      adb shell svc usb setFunctions rndis || error "adb command failed"
      ;;
    mtp)
      if [ ! -f /usr/libexec/gvfs-mtp-volume-monitor ];then
        sudo_popup apt update
        sudo_popup apt install -y gvfs-backends || error "gvfs-backends is required but it failed to install."
      fi
      adb shell svc usb setFunctions mtp || error "adb command failed"
      wait_for_reconnect
      
      #start mtp volume monitor if needed
      pgrep -f /usr/libexec/gvfs-mtp-volume-monitor >/dev/null || /usr/libexec/gvfs-mtp-volume-monitor &
      
      volmonpid=$!
      tries=0
      while [ ! -d /run/user/1000/gvfs/*/Phone ];do
        if [ "$tries" -lt 20 ];then
          sleep 0.2
        elif [ "$tries" -eq 20 ];then
          echo "Phone needs you to allow access to its files. Check the phone for a popup and tap \"Allow\"."
        else
          #wait for user to allow file access. Once permitted, the phone disables mtp, so enable it again
          adb shell dumpsys usb 2>/dev/null | grep -q 'kernel_function_list.*mtp' || adb shell svc usb setFunctions mtp 2>/dev/null
          sleep 1
        fi
        tries=$((tries+1))
        [ "$tries" == 20 ] && echo
      done
      #don't make the double-mount show up in file manager
      
      xdg-open /run/user/1000/gvfs/*/Phone || error "failed to open phone filesystem in file manager"
      ;;
    quickdrop)
      files="$(yad --dnd --width=400 --text="Drop files here to send them to the Download folder." --text-align=center --button=OK:0 | sed 's+file://++g')"
      IFS=$'\n'
      lastfile="$(tail -1 <<<"$files")"
      for file in $files ;do
        echo "#$(basename "$file")"
        adb push "$file" /sdcard/Download 1>&2
        #pause on last file so user can see progress
        [ "$file" == "$lastfile" ] && sleep 2
      done | yad --text="Transferring files..." --progress --pulsate --auto-close --auto-kill --enable-log --log-expanded --width 400 --button=Cancel:1
      ;;
    autostart*)
      if [ -f ~/.config/autostart/androidbuddy.desktop ];then
        rm -f ~/.config/autostart/androidbuddy.desktop
        ps aux | grep -x "/bin/bash $(dirname $0)/autostart.sh" | grep -v grep | awk '{print $2}' | xargs kill 2>/dev/null
        yad --width=400 --text="Removed the autostart file."$'\n'"From now on, AndroidBuddy will no longer launch when an Android phone is plugged in." --button=OK:0
      else
        mkdir -p ~/.config/autostart
        echo "[Desktop Entry]
Name=AndroidBuddy USB service
Exec="\""$(dirname $0)/autostart.sh"\""
Terminal=false
Type=Application
X-GNOME-Autostart-enabled=true
Hidden=false
NoDisplay=false" > ~/.config/autostart/androidbuddy.desktop
        ps aux | grep -x "/bin/bash $(dirname $0)/autostart.sh" | grep -v grep | awk '{print $2}' | xargs kill 2>/dev/null
        setsid "$(dirname $0)/autostart.sh" &
        yad --width=400 --text="Added the autostart file."$'\n'"From now on, AndroidBuddy will launch when an Android phone is plugged in." --button=OK:0
        kill $(echo "$input" | awk '{print $2}') #kill yad and exit
        break
      fi
      ;;
    *)
      error "unknown input '$input'"
      ;;
  esac
done
