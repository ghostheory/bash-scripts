#!/usr/bin/python3

import multiprocessing
import os
from decimal import Decimal, ROUND_HALF_EVEN

# VARS
core_count = float(multiprocessing.cpu_count())
fifteen_minute_load = os.getloadavg()[2]
one_minute_load = os.getloadavg()[0]


# FUNCTIONS
def send_message(signal):
    if signal == 'load_high_but_falling':
        return "send message to slack"
        print('1')
    if signal == 'load_high_and_climbing':
        return "send alternative msg to slack"
        print('2')


#LOGIC
if fifteen_minute_load > core_count:
    if one_minute_load <= fifteen_minute_load:
        send_message('load_high_but_falling')
    else:
        send_message('load_high_and_climbing')
else:
    print("CPU demand is less than core count")

print(fifteen_minute_load)
print(core_count)
