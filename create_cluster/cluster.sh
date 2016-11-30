#!/bin/bash

############
# GET OPTS #
############

function usage {
  echo "        -c <number> - Specifies how many clients to start up"
  echo "        -d <demo_name> - Canned Demo: 'core-cloud' 'core-ignition' 'centos'"
  echo "        -h - Brings up this help text"
  exit
}

while getopts ":c:d:h" opt; do
  case $opt in
    c)
      PXE_COUNT=$OPTARG
      ;;
    d)
      DEMO_NAME=$OPTARG
      ;;
    h)
      usage
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
  esac
done

START_MAC=1
case "$DEMO_NAME" in
  core-cloud)
    START_MAC=33
    PXE_COUNT=4
  ;;
  core-ignition)
    START_MAC=49
    PXE_COUNT=4
  ;;
  centos)
    START_MAC=65
    PXE_COUNT=1
  ;;
esac

######################
# DEPLOY PXE CLIENTS #
######################
if [ $PXE_COUNT > 0 ]
  check=$(VBoxManage list natnetworks | grep vaq)
  if [ -z "$check" ]; then
    VBoxManage natnetwork add --netname vaq --network "192.168.15.0/24" --enable --dhcp on
  fi
  then
    for (( i=0; i < $PXE_COUNT; i++ ))
      do
        vmName="boot-$i"

        isPresent=$(VBoxManage list vms | grep "$vmName")

        if [ ! -z "$isPresent" ];
        then
            VBoxManage controlvm $vmName poweroff;
            VBoxManage unregistervm $vmName --delete;
        fi

        mac=$(printf "%0.12x" "$START_MAC";);
        START_MAC=$((START_MAC+1))
        if [[ ! -e $vmName.vdi ]]; then # check to see if PXE vm already exists
            echo "deploying pxe: $i";
            VBoxManage createvm --name $vmName --register;
            VBoxManage createhd --filename $vmName --size 8192;
            VBoxManage storagectl $vmName --name "SATA Controller" --add sata --controller IntelAHCI ;
            VBoxManage storageattach $vmName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $vmName.vdi;
            VBoxManage modifyvm $vmName --boot1 net --memory 2048;

            VBoxManage modifyvm $vmName --nic1 natnetwork --nat-network1 vaq;
            VBoxManage modifyvm $vmName --nictype1 82543GC --nicbootprio1 4 --cableconnected1 on;


            VBoxManage modifyvm $vmName --nic2 intnet --intnet2 vaquero --nicpromisc2 allow-all;
            VBoxManage modifyvm $vmName --nictype2 82543GC  --macaddress2 $mac --nicbootprio2 1 --cableconnected2 on;

            VBoxManage modifyvm $vmName --boot1 disk --boot2 net

            VBoxManage startvm $vmName --type headless;
        fi
      done
fi
