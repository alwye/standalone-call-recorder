#!/usr/bin/env bash

# MIT License
#
# Copyright (c) 2020 alwye
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Configuration: need changes
# Enter the IMEI of your 3G modem/dongle (digits only, no spaces).
# You can edit this later at /etc/asterisk/dongle.conf
DONGLE_IMEI="000000000000000"
# By default, the program will pick up every call.
# It is unlikely you want that. If you want to whitelist your phone number,
# enter it below in a local format (for example, starting with 0)
# You can edit this later at /etc/asterisk/recording_dialplan.conf
WHITELISTED_PHONE_NUMBER="00000000000"
# Configuration: end

# Constants: changes are unlikely required
ASTERISK_PACKAGE_VERSION=1:16.2.1~dfsg-1+deb10u1
ASTERISK_VERSION=16.2.1
# Constants: end

# Check the status of the previous command
# 0 = no errors, otherwise print "ERROR" and exit
function validate_failure() {
    if [[ $? -ne 0 ]]; then
        echo "ERROR"
        exit $?
    fi
}

# Action starts here
echo -e "Welcome to the Standalone Call Recorder installation.\n\
This tool is about to install Asterisk and chan_dongle.\n\
Make sure you made changes in the configuration, otherwise hit Ctrl+C to exit.\n\
If you run into any issues, open a new issue on GitHub: https://github.com/alwye/standalone-call-recorder.\n\n\
Disclaimer: Asterisk and chan_dongle are supported by their respective communities.\n\
By continuing to run this program, you understand and accept risks related to running open source software, \
as well as the conditions of the attached MIT license."

echo "Enter any character to accept and continue:"
read anykey

# Update package lists
sudo apt-get update || validate_failure

# Install dependencies
# libsqlite3-dev is a dependency for chan_dongle
sudo apt-get install -y asterisk=${ASTERISK_PACKAGE_VERSION} \
                        asterisk-dev=${ASTERISK_PACKAGE_VERSION} \
                        libsqlite3-dev \
                        autotools-dev \
                        automake || validate_failure

# Verify installation of asterisk
echo "Verify installation of asterisk"
which asterisk || validate_failure

# Download chan_dongle and unarchive it
wget https://github.com/wdoekes/asterisk-chan-dongle/archive/master.zip || validate_failure
unzip master.zip || validate_failure

echo "Installing chan_dongle..."
# Enter the chan_dongle directory to install it
cd asterisk-chan-dongle-master  || validate_failure
./bootstrap || validate_failure
./configure --with-astversion=${ASTERISK_VERSION} || validate_failure
make || validate_failure
sudo make install || validate_failure
cd .. || validate_failure

# Copy the chan_dongle config file to asterisk's config folder
sudo cp templates/dongle.conf /etc/asterisk/ || validate_failure
# Replace the template with your real IMEI
sudo sed -i "s/<imei>/${DONGLE_IMEI}/g" /etc/asterisk/dongle.conf || validate_failure

# Now, include the dialplan from the asterisk's extensions config
sudo cat templates/recorder_dialplan.conf | sudo tee -a /etc/asterisk/extensions.conf > /dev/null || validate_failure
# Replace the template with the whitelisted number
sudo sed -i "s/<whitelisted_number>/${WHITELISTED_PHONE_NUMBER}/g" /etc/asterisk/extensions.conf || validate_failure

# Restart Asterisk
echo "Restarting Asterisk..."
sudo asterisk -rx "core restart gracefully" || validate_failure
# Wait for 10 seconds TODO: too lazy to check the status, 10 sec should be enough
sleep 10

echo "We're done, congrats."
