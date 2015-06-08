__author__ = 'shaon'
import json


def print_json(data, appendkey=None):
    temp = appendkey
    for k, v in data.iteritems():
        temp = temp + "['" + k + "']"
        if type(v) is dict:
            print_json(v, temp)
        else:
            print "{0} = {1}".format(temp, v)
            temp = appendkey

with open('datafile.json') as data_file:
    data1 = json.loads(data_file.read())
data1 = data1['default_attributes']
for d in data1:
    appkey = "default['" + d + "']"
    print print_json(data1[d], appkey)
