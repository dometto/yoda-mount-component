#!/bin/bash
ZENITY=$(/usr/bin/which zenity)
EXPECT=$(/usr/bin/which expect)
MOUNT=$(/usr/bin/which mount)
GREP=$(/usr/bin/which grep)
WHOAMI=$(/usr/bin/which whoami)
MKDIR=$(/usr/bin/which mkdir)

if [[ $# -eq 0 ]]; then
    echo "No arguments provided"
    exit 1
fi

USER=$(${WHOAMI})
MOUNT_DIR=$1
DRIVE_NAME=$2 || "WebDAV"
DRIVE_URL=$3 || ""

if [[ -z $DISPLAY ]]; then
  echo "No display found. This script uses the GUI to prompt for WebDAV credentials. To mount $MOUNT_DIR from the command line, try simply using 'mount $MOUNT_DIR'."
  exit 1
fi

if [[ ! -z $DRIVE_URL ]]; then
  DRIVE_URL="($DRIVE_URL)"
fi

if ! ${MKDIR} -p $MOUNT_DIR; then
  echo "Cannot create $MOUNT_DIR"
  exit 1
fi

if ${MOUNT} | ${GREP} -q "$MOUNT_DIR"; then
  echo "Already mounted"
  exit 0
fi

CREDENTIALS=$(${ZENITY} --forms --title="Login to $DRIVE_NAME" --text="Please enter your credentials to login to $DRIVE_NAME $DRIVE_URL" --add-entry "Username" --add-password="Password" --separator "FIELDSEP" )

if [[ $CREDENTIALS =~ (.*)FIELDSEP(.*) ]]; then 
    USERNAME=${BASH_REMATCH[1]}
    PASSWORD=${BASH_REMATCH[2]}
fi


if [[ -z $USERNAME || -z $PASSWORD ]]; then
  echo "Failed to obtain username or password"
  exit 1
fi

${EXPECT} -f - <<-EOF
  set timeout 20
  log_user 0
  spawn -ignore HUP sudo -u$USER $MOUNT $MOUNT_DIR
  expect "sername:"
  send -- "$USERNAME\r"
  expect "assword:"
  send -- "$PASSWORD\r"
  wait
  expect eof
EOF

if ! ${MOUNT} | ${GREP} -q "$MOUNT_DIR"; then
  ${ZENITY} --info --text="Failed to connect to $DRIVE_NAME $DRIVE_URL!"
  exit 1
fi

echo "Done"
