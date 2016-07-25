# -*- coding: utf-8 -*-
"""
Created on Fri Feb 14 22:43:04 2014

@author: Administrator
"""
import csv

reader = csv.reader(open("D:\sas\CHEN\quantlife\loan_credit_total1.csv"), "r", dialect="excel")
data = [line in reader]

print(data[2])

