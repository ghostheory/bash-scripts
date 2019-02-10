#!/usr/bin/python3

import multiprocessing
import os
from decimal import Decimal, ROUND_HALF_EVEN

core_count = float(multiprocessing.cpu_count())

fifteen_minute_load = os.getloadavg()[2]

if fifteen_minute_load > core_count:
    print("CPU demand is trending higher than core count")
else:
    print("CPU demand is less than core count")

print(fifteen_minute_load)
print(core_count)
