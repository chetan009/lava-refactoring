#! /usr/bin/env python
""" Pipeline job submission script
"""

# -*- coding: utf-8 -*-
#
#  snagglepuss.py
#
#  Copyright 2015 Neil Williams <codehelp@debian.org>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#
#

import os
import yaml
import xmlrpclib
from lava_dispatcher.pipeline.utils.strings import substitute


# configurable details
class Config(object):
    """
    Alter to suit your local setup
    """
    token = u'kupfbyga9zoir49uxt3h5wu0b0pkykbqa6scg0brqezld8' +\
            'nw3csf05o6dhby89f6sulg4jcazlwe2a2cp00q9wu2kfty8' +\
            'wodkhhlwnjbfgwckzdsd7n84ztjcanpl8cr'
    host = {u'{SERVER}': u'snagglepuss.codehelp'}
    bundle = {u'{BUNDLE}': u'/anonymous/pipeline/'}
    targets = {
        u'fred': u'beaglebone-black',
        u'yogi': u'panda'
    }
    yaml_jobs = {
        u'beaglebone-black': [u'yaml/bbb-nfs.yaml'],
        u'panda': [u'yaml/panda-ramdisk.yaml']
    }
    image_prefix = {u'{PREFIX}': u'http://hobbes/images/'}

    def __init__(self):
        self.server = xmlrpclib.ServerProxy(
            "http://%s/RPC2" % self.host['{SERVER}'])
        self.__errors__ = []

    @property
    def errors(self):
        """ Errors caught during processing
        """
        return self.__errors__

    @errors.setter
    def errors(self, message):
        """
        Print errors and continue
        """
        print message
        self.__errors__.append(message)

    def prepare(self):
        """ 
        unused - was to be a way to substitute prefixes into YAML
        """
        dictionary = {}
        dictionary.update(self.host)
        dictionary.update(self.bundle)
        dictionary.update(self.image_prefix)

        for key, value in self.yaml_jobs.items():
            for filename in value:
                job_data = None
                if not os.path.exists(filename):
                    continue
                with open(filename, 'r') as data:
                    try:
                        job_data = yaml.load(data)
                    except yaml.parser.ParserError:
                        self.errors = "YAML parser error: %s" % filename
                        continue
                for line in job_data['actions']:
                    if 'deploy' in line:
                        for field, content in line.items():
                            for key, value in content.items():
                                if type(value) == str:
                                    content.update({key: substitute([value], dictionary)[0]})
                            line.update({field: content})
                print yaml.dump(job_data)

    def start(self):
        """ Starts submitting jobs
        """
        pass


def main():
    """
    Runs pipeline tests inside a dummy host on existing LAVA instances.
    """
    config = Config()
    config.prepare()
    return 0

if __name__ == '__main__':
    main()
