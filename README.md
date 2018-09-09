# Device-Monitor-Dashboard
[![Build Status](https://travis-ci.org/circa10a/Device-Monitor-Dashboard.svg?branch=master)](https://travis-ci.org/circa10a/Device-Monitor-Dashboard)
[![Docker Repository on Quay](https://quay.io/repository/circa10a/device-monitor-dashboard/status "Docker Repository on Quay")](https://quay.io/repository/circa10a/device-monitor-dashboard)
[![Docker Automated buil](https://img.shields.io/docker/automated/jrottenberg/ffmpeg.svg)](https://hub.docker.com/r/circa10a/device-monitor-dashboard/)
[![](https://images.microbadger.com/badges/image/circa10a/device-monitor-dashboard.svg)](https://microbadger.com/images/circa10a/device-monitor-dashboard "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/circa10a/device-monitor-dashboard.svg)](https://microbadger.com/images/circa10a/device-monitor-dashboard "Get your own version badge on microbadger.com")

Python script to generate material design html report of devices' online/offline status. A cheap/fun reporting solution.
This can be used for for servers, networking equipment, IOT devices, anything that's "pingable".
Supports:

 * Linux
 * Windows
 * Raspberry Pi


### Live Demo:
[100% Devices Up](http://caleblemoine.me/monitor/) / [Failing Devices](http://caleblemoine.me/monitor/fail)


## Changelog
---
 - (9/9/2018) Replace txt file format with json
 - (1/30/2018) Replace trunicates with jinja templating engine
 - (1/27/2018) Added python 3 compatibility
 - (10/27/2017) Updated UI, noty.js
 - (9/25/2017) Add support for custom names
 - (6/3/2017) Now providing a docker image instead of building your own
 - (5/27/2017) - Please see https://github.com/shaggyloris/Device-Monitor-Dashboard for extended functionality.
   - Integrated SQLite DB, all controlled via web UI, API functionality to return JSON.
 - (5/6/17) Added validation of OS for script to run
 - (2/26/17) Update Easy Install to automatically install packages
 - (2/25/17) Added support for vertically scrolling table, adjusts circle size if on mobile device.
 - (2/24/17) Combined ping function to single file, added ability to check other ports. Also converted script to be more in line with python norms. Table rows now act as hyperlinks to address listed and will auto detect port if specified.
 - (2/20/17) Updated noty,jquery, notifications UI, mobile UI
 - (2/18/17) Added support to build custom docker container
 - (2/4/17) Easy Install script now supports Node.js, update wheel color
 - (2/3/17) Change status from online/offline text to colored orb indicators

## Easy Install
---

```bash
bash -c "$(curl -sL https://raw.githubusercontent.com/circa10a/Device-Monitor-Dashboard/master/install.sh)"
```

- Nginx and Python required for Easy Install
- Tested with Ubuntu 16.04.3 / Nginx 1.10.3 / Python 2.7
- Follow the prompts!

## Usage
---
- Have a JSON file(array of objects) with hostnames, port, alias
  - Example JSON file

 ```json
[
    {
        "url": "www.github.com",
        "port": 443,
        "alias": "GitHub"
    },
    {
        "url": "www.reddit.com",
        "port": 443,
        "alias": "Reddit"
    },
    {
        "url": "www.google.com",
        "port": 80,
        "alias": "Google"
    },
    {
        "url": "www.apple.com",
        "port": 80,
        "alias": null
    }
]
 ```

- Update the python script (variable at the top) with the path/name of your file with hostnames and output file path.(default hostnames= `./hostnames.json   default output= `./index.html`)
- Run `python report.py`
- Ensure that you place the output HTML file in the project directory so it can find its web dependencies
  - Page automcatically reloads every 60 seconds.

## Docker!
---

```bash
docker run -d -p 80:80 -v ~/path/to/your/hostnames.json:/usr/share/nginx/html/hostnames.json --name monitor circa10a/device-monitor-dashboard
```

**Note: Wait 5 min for cron job to execute and render an index.html**

### Build your own docker image:

```bash
git clone https://github.com/circa10a/Device-Monitor-Dashboard.git
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
