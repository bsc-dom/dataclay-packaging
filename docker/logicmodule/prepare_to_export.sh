#!/bin/sh
sqlite3 /dataclay/storage/LM \
  "delete from executionenvironments"\
  "delete from logicmodule" \
  "delete from dsID" \
  "delete from objectMD" \
  "delete from storagelocations" \
  "delete from executionenvironments" \
  "delete from dataclays" \
  "delete from federatedobjects" \
  "delete from externalobjects" \
  "delete from sessioncontract" \
  "delete from sessioninterface" \
  "delete from sessionproperty" \
  "delete from sessionoperation" \
  "delete from sessionimpl" \
  "delete from sessiondatacontract" \
  "delete from sessioninfo" \
  "delete from extsessioninfo" \
  ".exit"