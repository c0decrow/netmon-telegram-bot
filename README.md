# netmon-telegram-bot
[![Build Status](https://travis-ci.org/circa10a/device-monitor-dashboard.svg?branch=master)](https://travis-ci.org/circa10a/device-monitor-dashboard)
[![Docker Repository on Quay](https://quay.io/repository/circa10a/device-monitor-dashboard/status "Docker Repository on Quay")](https://quay.io/repository/circa10a/device-monitor-dashboard)
[![Docker Automated buil](https://img.shields.io/docker/automated/jrottenberg/ffmpeg.svg)](https://hub.docker.com/r/circa10a/device-monitor-dashboard/)
[![](https://images.microbadger.com/badges/image/circa10a/device-monitor-dashboard.svg)](https://microbadger.com/images/circa10a/device-monitor-dashboard "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/circa10a/device-monitor-dashboard.svg)](https://microbadger.com/images/circa10a/device-monitor-dashboard "Get your own version badge on microbadger.com")

Python script for network devices monitoring dashboard integrated with Telegram bot notifications. A lightweight monitoring and reporting solution using Telgram API functionality. The script does two things at the same time:
* Dynamically generates a monitoring dashboard web page which is periodically refreshed with current status of the devices in the list.
* Uses your own Telegram bot for notifications when a device changes its status (going from online to offline and vice versa).

This can be used for for servers, networking equipment, cameras, IOT devices, anything that has an IP address and is pingable.
Supports:
 * Linux
 * Windows
 * Raspberry Pi

The current version is developed and tested on Debian Linux, and the install script is working only on Debian based Linux distibutions (Debian, Ubuntu, Mint). However, it could be easily deployed on other OS types provided the following required software is installed:
* python (2.7 or 3.x)
* jinja2 (installed by python pip)
* nginx (optionally Apache)

The project could also be run inside a Docker container. 
Editted instructions will be provided.

Telegram bot brief instructions will be provided bellow.

### Live Demo:
[100% Devices Up](http://caleblemoine.dev/monitor/) / [Failing Devices](http://caleblemoine.dev/monitor/fail)


## Changelog
---
 - 21/1/2020: Project repository forked
 - 22/1/2020: Added IP address column on the dashboard, dynamic percentage of online devices in the page title. Green or red favicon for better visibility of the status.

## Easy Install
---

```bash
bash -c "$(curl -sL https://raw.githubusercontent.com/c0decrow/netmon-telegram-bot/master/install.sh)"
```

- Python and Nginx required for Easy Install
- Tested with Ubuntu 18.04.3 LTS / Nginx 1.14.0 / Python 2.7.17
- Just follow the prompts!

## Usage
---
- Edit the JSON file (hostnames.json) with the devices you want to monitor (values hostname, port, alias).
  - Example:

 ```json
[
    {
        "url": "www.github.com",
        "port": 443,
        "alias": "GitHub"
    },
    {
        "url": "www.python.org",
        "port": 443,
        "alias": "Python"
    },
    {
        "url": "telegram.org",
        "port": 443,
        "alias": "Telegram"
    },
    {
        "url": "192.168.0.1",
        "port": 80,
        "alias": "My Router"
    }
]
 ```

- Update the report.py script with your-Telegram-bot-token and your-Telegram-bot-chat-ID:
TOKEN = "<my_telegram_bot_token>"
CHAT_ID = "<my_telegram_bot_chat_id>"
This way the bot will know the destination chat to send you the notifications.
- Go to the project directory where the script is located:
cd /var/www/html/monitor/
- Run `python report.py`
- The output HTML file in generated in the project directory so it can find its web dependencies.
- Test are done every 120 seconds.
- Page automcatically reloads every 120 seconds.
- In order to minimize any false alarms and host 'flapping' there's a tollerance variable configured, which means that:
  - when UP, there must be two consecutive failed ping / connection tests to the device after which it will be declared DOWN and Telegram message will be sent.
  - when DOWN, there must be two consecutive successfull ping / connection tests to the device after which it will be declared UP and Telegram message will be sent.
  - That means that using the default settings notifications will be received 240 seconds after the corresponding event.

## Docker!
---

```bash
docker run -d -p 80:80 -v ~/path/to/your/hostnames.json:/usr/share/nginx/html/hostnames.json --name monitor circa10a/device-monitor-dashboard
```

**Note: Wait 5 min for cron job to execute and render an index.html**

### Build your own docker image:

```bash
git clone https://github.com/c0decrow/netmon-telegram-bot.git
cd Device-Monitor-Dashboard
```

- Edit your hostnames.json file add your website, servers, switches, devices, etc.
```bash
docker build -t myrepo/monitor
docker run --name device-monitor -d -p 80:80 myrepo/monitor
```

```diff
- Known issue: Docker for Mac pings any address and returns success giving false results.
```

## Automation
---
- Setup a web server
- Install a new cron job to run the report periodically `cd $path/to/project_directory/ && python report.py &> /dev/null`
- Set output path in python script to write out html report to web serving directory such as `/var/www/html`
- The page will automatically refresh every 60 seconds to reflect the new report generated by cron

## Screenshots
---
![alt text](https://i.imgur.com/dx3XabN.png)
![alt text](https://i.imgur.com/k49MfS4.png)
