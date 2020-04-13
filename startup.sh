#!/bin/bash
./hbase/bin/start-hbase.sh

nutch nutchserver > /dev/null &
nutch webapp

