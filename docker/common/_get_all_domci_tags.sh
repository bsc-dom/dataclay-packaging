#!/bin/bash

function list_all_tags() {
  name=$1
  curl -X GET https://dom-ci.bsc.es/v2/${name}/tags/list

}

list_all_tags "bscdataclay/logicmodule"
list_all_tags "bscdataclay/dsjava"
list_all_tags "bscdataclay/dspython"
list_all_tags "bscdataclay/client"
list_all_tags "bscdataclay/initializer"