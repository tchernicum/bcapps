#!/usr/local/bin/python

import ephem
atlanta = ephem.Observer()
atlanta.pressure = 0
atlanta.horizon = '-0:34'
atlanta.lat, atlanta.lon = '70', '0'
atlanta.date = '2012/07/26 12:00'
# print atlanta.previous_rising(ephem.Sun())
print atlanta.next_setting(ephem.Sun())
