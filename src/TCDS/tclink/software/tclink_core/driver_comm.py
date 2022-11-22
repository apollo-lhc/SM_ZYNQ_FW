#!/usr/bin/env python

import socket
import logging

# -------------------------------------------------------------
#  -------------- Class DriverComm (driver-layer) ------------
# -------------------------------------------------------------


class DriverComm:

    def __init__(self, ip='192.168.1.2', port=9001, logger_name=None):
        self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.s.connect((ip, port))
        self.logger = logging.getLogger(logger_name)
        self.logger.debug('Opening socket at port:' + str(port) + ", ip:" + ip)

    def send(self, data):
        data=data.encode('utf-8')
        self.s.send(data)

    def recv(self):
        r = ' '
        data = ''
        while r != '\n':
            data += self.s.recv(4 * 1024)
            r = data[-1]
        return data[:-1]

    def query(self, data):
        self.send(data)
        return self.s.recv(4096)