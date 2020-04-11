# Standalone Call Recorder

## What is this project?

iPhone doesn’t support recording phone calls, so the only way to record audio during the phone conversations is to basically add a third party to the call who can record whatever is being said.

Now, there is a number of available options including Google Voice and what not, but I wanted to build an independent and more privacy-centred one, and have fun with the project.

Effectively, all you need is a Raspberry Pi, a 3G/GSM dongle and a second SIM card (check Pay As You Go plans in your country).

I have not created the underlying technologies myself, but rather merely created an automated setup and configurator for easier use.

## Disclaimer 1: obey the law

A lot of people expressed their concern about legal implications when I first posted this project on Reddit.

Indeed, many countries oblige you to notify the other party about the fact you're recording the call.

I am not a lawyer, so do your own research of your local legislation, obey it and get a legal advice if required.

If in doubt, avoid recording phone calls.

## Disclaimer 2: treat this project as a proof of concept

**TL;DR: I built this tool for fun as a proof of concept and did not intend for it to work perfectly.**

This code does nothing but installs and configures third-party software (Asterisk PBX and chan_dongle).

As a matter of fact, that software may get compromised (or have been), may be faulty, buggy or might even render your hardware unusable.

On top of that, I have not done much bash scripting in my life.

I built this as a fun DIY project, and think of it as simply a proof of concept at this stage. The hardware I used is a Raspberry Pi, an old 3G dongle I got for free a decade ago and a free SIM card, so I couldn't care less about any issues.

On top of that, 3G modems often need a lot more current than a Pi can give. Can this damage either the Pi or the dongle? Absolutely.

Feel free to make suggestions or contribute to the project.

## Prerequisite

* A Linux computer.
    * I used a cheap Raspberry Pi 2, and tested it on Raspian Buster Lite (kernel 4.19)
* 3G USB modem. **Important:** not all of them support voice transmition. The older ones (circa 2010) should, the newer ones reportedly only support data transmition. Do your research.
* Any SIM card that fits that 3G dongle. Any "Pay As You Go" SIM should cut it.

## How to run this tool

Clone this repository to your Raspberry Pi.

Edit the values of `DONGLE_IMEI` and `WHITELISTED_PHONE_NUMBER` in the "Configuration" section in `install.sh`, then execute it as a user (without sudo):

```
./install.sh
```

You can open the Asterisk terminal with:

```
sudo asterisk -rvvvvv
```

The `vvvvv` bit makes the output more verbose, so you should be able to see when your call is received, picked up and routed to a correct context and extension.

Your call recordings will be available at: 

```
/var/spool/asterisk/monitor/
```

You can copy the recordings from the computer by running an `scp` command, using a shared folder or putting some automation in place. 

When you play a recording, you may notice a very sharp sound at the very beginning. I haven't looked into removing it yet and most likely won't, although feel free to submit a pull request with a fix.

## Making a recorded call

You will need to make a 3-way conference call.

Different phones do it differently. Below is the description for iOS:

1. Open your contacts or phone app and make a call to your recording line.

2. When asterisk picks up, tap "Add Call". This will bring up the contact list.

3. Select a contact or enter a phone number. During that call the asterisk line will be put on hold.

4. Once connected with the other party, click "Merge" to create a three-way conference call.

5. Once successfully merged you should be able to hear the other party, and asterisk will record both parties.

6. Make sure to let the other party know you're recording the call.

7. When you hang up, asterisk will stop the recording and save it in a folder of your preference.

## FAQ

Q: Can other people abuse my line?

A: If you properly set up the white list, only your calls will be picked up.

Q: Can I have multiple whitelisted numbers?

A: Yes, you may add something like ```exten => _+X.,1,GotoIf($[${CALLERID(num)} = 00000000000 | ${CALLERID(num)} = 00000000000]?allow:reject)``` to whitelist two numbers (in `/etc/asterisk/externsions.conf`). Following the same principle, you can add even more numbers. You will need to restart asterisk by running ```sudo asterisk -x "core restart gracefully"```

Q: Can I use a different directory to store my recordings?

A: Yes. Find the line ```same  => n, MixMonitor(${CALLERID(num)}-${STRFTIME(${EPOCH},,%d-%m-%Y-%H-%M-%S)}-${UNIQUEID}.wav)``` in `/etc/asterisk/extensions.conf`. The argument in `MixMonitor` is a file name. If you prefix that with an absolute path to the folder you want to store your recordings in, just add that before the file name. For example: `/var/recordings/${CALLERID(num)}-${STRFTIME(${EPOCH},,%d-%m-%Y-%H-%M-%S)}-${UNIQUEID}.wav`. Make sure asterisk has rights to write into that folder.


## Thanks to
* Asterisk community with [its amazing project](https://github.com/asterisk/asterisk)
* bg111 for creating [chan_dongle](https://github.com/bg111/asterisk-chan-dongle) and Walter Doekes for maintaining [its up-to-date fork](https://github.com/wdoekes/asterisk-chan-dongle)

## Licensing

This code is licensed under the [MIT license](./LICENSE). Be aware that other pieces of software that this tool manages may be subject to additional license agreements.
