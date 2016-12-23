#!/usr/bin/env python

##############################################################################
# Copyright 2014 Joseph Chilcote
#
#  Licensed under the Apache License, Version 2.0 (the "License"); you may not
#  use this file except in compliance with the License. You may obtain a copy
#  of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#  License for the specific language governing permissions and limitations
#  under the License.
##############################################################################

## Much of this code is forked from by Mike Lynn's work here:
## https://github.com/pudquick/pyMacWarranty/blob/master/getwarranty.py

'''
Apple warranty estimation script.

This script estimates whether a given serial number is under warranty.
Input can be one or more given serial numbers, or a text file listing serials.
Output can be standard out or a CSV file.

usage: warranty [-h] [-v] [--quit-on-error] [-i INPUT] [-o OUTPUT] ...

positional arguments:
  serials

optional arguments:
  -h, --help            show this help message and exit
  -v, --verbose         print output to console while writing to file
  --quit-on-error       if an error is encountered
  -i INPUT, --input INPUT
                        import serials from a file
  -o OUTPUT, --output OUTPUT
                        save output to a csv file

'''

import os
import sys
import subprocess
import plistlib
from dateutil import parser
import argparse
import urllib2
import datetime
import time
import xml.etree.ElementTree as ET

def get_asd_plist():
    '''Returns a dict containing model and asd version'''
    asd_plist = \
        'https://raw.githubusercontent.com/chilcote/warranty/master/com.github.chilcote.warranty.plist'
    response = urllib2.urlopen(asd_plist)
    return plistlib.readPlist(response)

def get_serial():
    '''Returns the serial number of this Mac'''
    '''print('Using this machine\'s serial number.')'''
    cmd = ['/usr/sbin/ioreg', '-c', 'IOPlatformExpertDevice', '-d', '2']
    output = subprocess.check_output(cmd)
    for line in output.splitlines():
        if 'IOPlatformSerialNumber' in line:
            return line.split(' = ')[1].replace('\"','')
    return None

def apple_year_offset(dateobj, years=0):
    # Convert to a maleable format
    mod_time = dateobj.timetuple()
    # Offset year by number of years
    mod_time = time.struct_time(tuple([mod_time[0]+years]) + mod_time[1:])
    # Convert back to a datetime obj
    return datetime.datetime.fromtimestamp(int(time.mktime(mod_time)))

def manufacture_date(serial, graceful=True):
    '''returns the estimated manufacture date of the Mac'''
    # http://www.macrumors.com/2010/04/16/apple-tweaks-serial-number-format-with-new-macbook-pro/
    est_date = u''
    if 10 < len(serial) < 13:
        if len(serial) == 11:
            # Old format
            year = serial[2].lower()
            est_year = 2000 + '   3456789012'.index(year)
            week = int(serial[3:5]) - 1
            year_time = datetime.date(year=est_year, month=1, day=1)
            if (week):
                week_dif = datetime.timedelta(weeks=week)
                year_time += week_dif
        else:
            # New format
            alpha_year = 'cdfghjklmnpqrstvwxyz'
            year = serial[3].lower()
            est_year = 2010 + (alpha_year.index(year) / 2)
            # 1st or 2nd half of the year
            est_half = alpha_year.index(year) % 2
            week = serial[4].lower()
            alpha_week = ' 123456789cdfghjklmnpqrtvwxy'
            est_week = alpha_week.index(week) + (est_half * 26) - 1
            year_time = datetime.date(year=est_year, month=1, day=1)
            if (est_week):
                week_dif = datetime.timedelta(weeks=est_week)
                year_time += week_dif
    return apple_year_offset(year_time).strftime('%Y-%m-%d')

def get_days_old(manufactured_date):
    today = datetime.datetime.now()
    manu = parser.parse(manufactured_date)
    return (today - manu).days

def get_model(serial):
    if (len(serial) == 11):
        snippet = serial[-3:]
    elif (len(serial) == 12):
        snippet = serial[-4:]
    elif (2 < len(serial) < 5):
        snippet = serial
    else:
        return None
    try:
        url = 'http://support-sp.apple.com/sp/product?cc=%s&lang=en_US' % snippet
        model = ET.fromstring(urllib2.urlopen(url).read()).find('configCode').text
    except:
        return None
    return model

def get_est_warranty(manufactured_date):
    return (u'' + apple_year_offset(parser.parse(manufactured_date), 3).strftime('%Y-%m-%d'),
            u'' + apple_year_offset(parser.parse(manufactured_date), 1).strftime('%Y-%m-%d'))

def get_est_status(est_date):
    if (datetime.datetime.now() > parser.parse(est_date)):
        return "EXPIRED"
    else:
        return "COVERED"

def file_output(file, warranty_info):
    with open(file, 'a') as f:
        f.write('{},"{}",{},{},{},{},{}\n'.format(
            warranty_info[0],
            warranty_info[1],
            warranty_info[2],
            warranty_info[3],
            warranty_info[4],
            warranty_info[5],
            warranty_info[6])
        )

def warranty_output(warranty_info):
    print('<result>{}</result>'.format(warranty_info[5]))
    # print('Serial Number:       {}'.format(warranty_info[0]))
    # print('Product Description: {}'.format(warranty_info[1]))
    # print('Est. Manufactured:   {}'.format(warranty_info[2]))
    # print('Est. AppleCare:      {}'.format(warranty_info[3]))
    # print('Est. Warranty:       {}'.format(warranty_info[4]))
    # print('Est. Days Old:       {}'.format(warranty_info[5]))
    # print('ASD Version:         {}\n'.format(warranty_info[6]))

def main():
    '''Main method'''
    serials = []
    warranty = []
    parser = argparse.ArgumentParser()
    parser.add_argument('-v', '--verbose', help='print output to console while writing to file', action='store_true')
    parser.add_argument('--quit-on-error', help='if an error is encountered', action='store_true')
    parser.add_argument('-i', '--input', help='import serials from a file')
    parser.add_argument('-o', '--output', help='save output to a csv file')
    parser.add_argument('serials', nargs=argparse.REMAINDER)
    args = parser.parse_args()

    if args.input:
        print('Importing serials from file: {}'.format(args.input))
        f = open(args.input, 'r')
        for line in f.read().splitlines():
            serials.append(line)
    elif args.serials:
        serials = args.serials
    else:
        serials.append(get_serial())
        if not serials[0]:
            print 'Error: Invalid or no serial number detected.'
            sys.exit(1)
    d = get_asd_plist()
    if args.output:
        print('Writing out to file: {}'.format(args.output))
        with open(args.output, 'w') as f:
            f.write('Serial Number,Product Description,Manufactured,Applecare,Warranty,Age,ASD Version\n')

    for serial in serials:
        if args.input:
            print('Processing: {}'.format(serial))
        date, status = manufacture_date(serial, not args.quit_on_error), ''
        est_days_old = get_days_old(date)
        model = get_model(serial)
        est_applecare, est_warranty = get_est_warranty(date)
        est_applecare_status = get_est_status(est_applecare)
        est_warranty_status = get_est_status(est_warranty)
        asd = 'Undetermined'
        for k, v in d.items():
            if model.upper() in k.upper():
                asd = v
                break
        warranty.append([serial.upper(), model, str(date).split(' ')[0], est_applecare_status, est_warranty_status, est_days_old, asd])
        if args.output:
            file_output(args.output, warranty[-1])
            if args.verbose:
                warranty_output(warranty[-1])
        else:
            warranty_output(warranty[-1])

if __name__ == '__main__':
    main()
