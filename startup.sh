#!/bin/bash
./hbase/bin/start-hbase.sh

$NUTCH_HOME/bin/nutch nutchserver > /dev/null &
$NUTCH_HOME/bin/nutch webapp

