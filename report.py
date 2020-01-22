#!/usr/bin/python

import os
import datetime
import sys
import platform
import socket
import json
import time
import requests
import logging

from jinja2 import Environment, FileSystemLoader

TOKEN = "<my_telegram_bot_token>"
CHAT_ID = "<my_telegram_bot_chat_id>"
URL = "https://api.telegram.org/bot{}/sendMessage?chat_id={}&text=".format(TOKEN, CHAT_ID)

env = Environment(
    loader=FileSystemLoader('template')
)

template = env.get_template('template.html.j2')

def pinghost(hostname):
    # Check os type to determine which ping command to use
    os_type = platform.platform()
    if "Windows" in os_type:
        response = os.system("ping -n 1 {0}".format(hostname))
    else:
        response = os.system("ping -c 1 {0}".format(hostname))
    return True if response == 0 else False

def checksock(hostname, port):
    if not isinstance(port, int):
        try:
            port = int(port)
        except ValueError:
            print('Port number is not numeric!')
            sys.exit()
    try:
        socket.create_connection((hostname, port), 2)
        return True
    except socket.error:
        return False

def parsehost(hostfile):
    servers = []
    with open(hostfile, "r") as f:
        data = json.load(f)
        for item in data:
                if not isinstance(item["port"], int):
                    print("%s Port: %s is not a number!" % (item["url"], item["port"]))
                    sys.exit()

                if item["alias"]:
                    servers.append({"hostname": item["url"], "port": item["port"], "name": item["alias"]})
                else:
                    servers.append({"hostname": item["url"], "port": item["port"], "name": item["url"]})
    return servers

def createhtml(output_file_name, host_dict):
    refresh_rate = "60"
    today = (datetime.datetime.now())
    now = today.strftime("%m/%d/%Y %H:%M:%S")
    servers_up = 0.00
    servers_down = 0.00
    servers_percent = 0.00
    for h in host_dict:
        if h.get("status") == "up":
            servers_up += 1
        else:
            servers_down += 1
    server_total = (servers_up + servers_down)
    servers_percent = str(round((((server_total) - servers_down) / (server_total)), 2))
    servers_percent_m = int(round((((server_total) - servers_down) * 100 / (server_total)), 2))

    template.stream(refresh_rate=refresh_rate,
                    today=today, now=now,
                    servers_up=servers_up,
                    servers_down=servers_down,
                    servers_percent=servers_percent,
                    servers_percent_m=servers_percent_m,
                    server_total=server_total,
                    host_dict=host_dict).dump('index.html')

def main():
    logging.basicConfig(filename='status.log',level=logging.INFO, format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %H:%M')
    names_list = "hostnames.json"
    # put the path that you would like the report to be written to
    output_file_name = "index.html"
    hosts = parsehost(names_list)
    online = {}
    tolerance = {}
    for h in range(len(hosts)):
        online[hosts[h].get("hostname")] = "1"
        tolerance[hosts[h].get("hostname")] = "1"
    print("Online init:")
    print(online)
    print("Tolerance init:")
    print(tolerance)
    while True:
        for h in hosts:
            if h.get("port"):
                alive = checksock(h.get("hostname"), h.get("port"))
            else:
                alive = pinghost(h.get("hostname"))
            if alive:
                h.update(status="up")
                if tolerance[h.get("hostname")] == "0":
                    tolerance[h.get("hostname")] = "1"
                    logging.info('Tolerance of %s:  1', h.get("hostname"))
                    print("Tolerance of {}: 1".format(h.get("hostname")))
                else:
                    if online[h.get("hostname")] == "0":
                        message = "Host {} up".format(h.get("hostname"))
                        logging.info('Host %s:  UP', h.get("hostname"))
                        print(message)
                        online[h.get("hostname")] = "1"
                        try:
                            requests.get(URL + message, timeout=10)
                        except requests.exceptions.ConnectionError:
                            logging.info('API connection failed!')
                            print('API connection failed!')
            else:
                h.update(status="down")
                if tolerance[h.get("hostname")] == "1":
                    tolerance[h.get("hostname")] = "0"
                    logging.info('Tolerance of %s:  0', h.get("hostname"))
                    print("Tolerance of {}: 0".format(h.get("hostname")))
                    continue
                else:
                    if online[h.get("hostname")] == "1":
                        message = "Host {} down".format(h.get("hostname"))
                        logging.info('Host %s:  DOWN', h.get("hostname"))
                        print(message)
                        online[h.get("hostname")] = "0"
                        try:
                            requests.get(URL + message, timeout=10)
                        except (requests.exceptions.ConnectionError, requests.exceptions.ReadTimeout) as error:
                            logging.info('API connection failed!')
                            print('API connection failed!')
        createhtml(output_file_name, hosts)
        time.sleep(120)

if __name__ == "__main__":
    main()
