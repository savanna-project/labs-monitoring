#!/bin/bash

cd /usr/share/cacti/cli

HOST_INFO=$1
HOST_NAME=`echo $HOST_INFO | awk -F":" '{print $1}'`
HOST_IP=`echo $HOST_INFO | awk -F":" '{print $2}'`

HOST_TEMPLATE_ID=`php -q add_device.php \
  --list-host-templates |grep "Linux Host"|cut -f 1`

php -q add_device.php --description="$HOST_NAME" --ip="$HOST_IP" \
  --template=$HOST_TEMPLATE_ID --version=2 --community="public"

HOST_ID=`php -q add_graphs.php --list-hosts |grep $HOST_NAME|cut -f 1`

TREE_ID=`php -q add_tree.php --list-trees |grep "Default"|cut -f 1`

PARENT_MAIN_ID=`php -q add_tree.php --type=node --node-type=header \
  --tree-id=$TREE_ID --name="HOST: $HOST_NAME - Hardware stat" | grep -o "[0-9]*"`

PARENT_NETWORK_ID=`php -q add_tree.php --type=node --node-type=header \
  --tree-id=$TREE_ID --name="HOST: $HOST_NAME - Network stat" | grep -o "[0-9]*"`

php -q add_graphs.php --list-graph-templates \
  --host-template-id=$HOST_TEMPLATE_ID | \
  while read line
do
  if echo $line | grep "Known" >/dev/null || [ "$line" == "" ]
  then
    continue
  fi
  TEMPLATE_ID=`echo $line | cut -f 1 -d ' '`
  GRAPH_ID=`php -q add_graphs.php --host-id=$HOST_ID --graph-type=cg \
    --graph-template-id=$TEMPLATE_ID | grep -o "[0-9]*" | head -1`
  php -q add_tree.php --type=node --node-type=graph --tree-id=$TREE_ID \
    --graph-id=$GRAPH_ID --parent-node=$PARENT_MAIN_ID
done

function add_ds_graph {
  TEMPLATE_NAME=$1
  TYPE_NAME=$2
  FIELD_NAME=$3
  FIELD_VALUE=$4
  PARENT_ID=$5

  TEMPLATE_ID=`php -q add_graphs.php --list-graph-templates | \
    grep "$TEMPLATE_NAME"|cut -f 1`
  TYPE_ID=`php -q add_graphs.php --snmp-query-id=$SNMP_QUERY_ID \
    --list-query-types | grep "$TYPE_NAME"|cut -f 1`

  GRAPHS_ID=`php -q add_graphs.php --host-id=$HOST_ID --graph-type=ds \
    --graph-template-id=$TEMPLATE_ID --snmp-query-id=$SNMP_QUERY_ID \
    --snmp-query-type-id=$TYPE_ID --snmp-field=$FIELD_NAME \
    --snmp-value=$FIELD_VALUE |  grep -o "[0-9]*"`

  count=`echo $GRAPHS_ID | awk '{print NF}'`
  for ((i=1; i<$count;i+=2));
  do
       GRAPH_ID=`echo $GRAPHS_ID | awk -v i=$i '{print $i}'`
       php -q add_tree.php --type=node --node-type=graph --tree-id=$TREE_ID \
           --graph-id=$GRAPH_ID --parent-node=$PARENT_ID
  done
}

SNMP_QUERY_ID=`php -q add_graphs.php --host-id=$HOST_ID --list-snmp-queries | \
  grep "SNMP - Get Mounted Partitions"|cut -f 1`

add_ds_graph "Host MIB - Available Disk Space" "Available Disk Space" \
  "hrStorageDescr" "/" $PARENT_MAIN_ID

SNMP_QUERY_ID=`php -q add_graphs.php --host-id=$HOST_ID --list-snmp-queries | \
  grep "SNMP - Interface Statistics"|cut -f 1`

add_ds_graph "Interface - Traffic (bits/sec)" "In/Out Bits (64-bit Counters)" \
  "ifOperStatus" "Up" $PARENT_NETWORK_ID
add_ds_graph "Interface - Errors/Discards" "In/Out Errors/Discarded Packets" \
  "ifOperStatus" "Up" $PARENT_NETWORK_ID
add_ds_graph "Interface - Unicast Packets" "In/Out Unicast Packets" \
  "ifOperStatus" "Up" $PARENT_NETWORK_ID
add_ds_graph "Interface - Non-Unicast Packets" "In/Out Non-Unicast Packets" \
  "ifOperStatus" "Up" $PARENT_NETWORK_ID

#SNMP_QUERY_ID=`php -q add_graphs.php --host-id=$HOST_ID --list-snmp-queries | \
#  grep "ucd/net - Get IO Devices"|cut -f 1`

#add_ds_graph "ucd/net - Device IO - Operations" "IO Operations" \
#  "diskIODevice" "xvda"
#add_ds_graph "ucd/net - Device IO - Throughput" "IO Throughput" \
#  "diskIODevice" "xvda"

#add_ds_graph "ucd/net - Device IO - Operations" "IO Operations" \
#  "diskIODevice" "xvdc"
#add_ds_graph "ucd/net - Device IO - Throughput" "IO Throughput" \
#  "diskIODevice" "xvdc"
