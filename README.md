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

## Thanks to
* Asterisk community with [its amazing project](https://github.com/asterisk/asterisk)
* bg111 for creating [chan_dongle](https://github.com/bg111/asterisk-chan-dongle) and Walter Doekes for maintaining [its up-to-date fork](https://github.com/wdoekes/asterisk-chan-dongle)

## Licensing

This code is licensed under the [MIT license](./LICENSE). Be aware that other pieces of software that this tool manages may be subject to additional license agreements.
