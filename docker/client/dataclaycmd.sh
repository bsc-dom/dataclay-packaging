#!/bin/sh
set -e
usage() {
cat << EOF


 Usage: $TOOLNAME <operation> <argument1> <argument2> ...


 -------------------------------------------------------------------------------------------
| Basic            | Arguments                                                              |
 -------------------------------------------------------------------------------------------
 NewAccount         <new_user_name>  <new_user_pass>

 NewModel           <user_name>  <user_pass>  <namespace_name> <class_path> <$SUPPORTEDLANGS>
 GetStubs           <user_name>  <user_pass>  <namespace_name> <stubs_path>

 NewDataContract    <user_name>  <user_pass>  <dataset_name>   <beneficiary_user_name>


 ------------------------------------------------------------------------------------------
| Misc             | Arguments                                                             |
 ------------------------------------------------------------------------------------------
 GetBackends        <user_name>  <user_pass>  <$SUPPORTEDLANGS>

 NewNamespace       <user_name>  <user_pass>  <namespace_name> <$SUPPORTEDLANGS>
 GetNamespaces      <user_name>  <user_pass>

 NewDataset         <user_name>  <user_pass>  <dataset_name>   <$SUPPORTEDDSETS>
 GetDatasets        <user_name>  <user_pass>

 GetDataClayID    
 GetExtDataClayID   <dc_host> <dc_port>
 RegisterDataClay   <dc_host> <dc_port>
 ImportModelsFromExternalDataClay <dc_host> <dc_port> <namespace>
 WaitForDataClayToBeAlive	<max_retries> <retries_seconds>

EOF
exit 0
}

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

CONSOLE_BLUE="\033[1m \033[34m"
CONSOLE_NORMAL="\033[0m"
CONSOLE_RED="\033[1m \033[31m"

errorMsg() {
	printf "\n ${CONSOLE_RED} [dataClay] [ERROR] $1 ${CONSOLE_NORMAL} \n\n"
	exit 1
}

#shopt -s nocasematch # ignore case in case or if clauses
TOOLNAME=$0
SUPPORTEDLANGS="python | java"
SUPPORTEDDSETS="public | private"
printf " ${CONSOLE_BLUE} **  ᴅᴀᴛᴀCʟᴀʏ command tool ** ${CONSOLE_NORMAL} \n"

# WARNING: Note that this script must be located among with pom.xml

# Base ops commands
if [ -z "${DATACLAY_JAR}" ]; then
	errorMsg "ERROR: DATACLAY_JAR environemnt variable not defined."
	exit 1
fi

JAVA_OPSBASE="dataclay-java-entry-point"
PY_OPSBASE="dataclay-python-entry-point -m dataclay.tool"

# Check if aspects must be applied to Java 

# Basic operations
NEW_ACCOUNT="$JAVA_OPSBASE es.bsc.dataclay.tool.NewAccount"
GET_BACKENDS="$JAVA_OPSBASE es.bsc.dataclay.tool.GetBackends"
ACCESS_NS_MODEL="$JAVA_OPSBASE es.bsc.dataclay.tool.AccessNamespace"
GET_NAMESPACE_LANG="$JAVA_OPSBASE es.bsc.dataclay.tool.GetNamespaceLang"
GET_NAMESPACES="$JAVA_OPSBASE es.bsc.dataclay.tool.GetNamespaces"
NEW_DATACONTRACT="$JAVA_OPSBASE es.bsc.dataclay.tool.NewDataContract"
GET_DATASETS="$JAVA_OPSBASE es.bsc.dataclay.tool.GetDatasets"
NEW_DATASET="$JAVA_OPSBASE es.bsc.dataclay.tool.NewDataset"

# NewModel operations
NEW_NAMESPACE="$JAVA_OPSBASE es.bsc.dataclay.tool.NewNamespace"
JAVA_NEW_MODEL="$JAVA_OPSBASE es.bsc.dataclay.tool.NewModel"
PY_NEW_MODEL="$PY_OPSBASE register_model"

# Get stubs operations
JAVA_GETSTUBS="$JAVA_OPSBASE es.bsc.dataclay.tool.GetStubs"
PY_GETSTUBS="$PY_OPSBASE get_stubs"

# Federation
GET_DATACLAYID="$JAVA_OPSBASE es.bsc.dataclay.tool.GetCurrentDataClayID"
GET_EXT_DATACLAYID="$JAVA_OPSBASE es.bsc.dataclay.tool.GetExternalDataClayID"
REG_EXT_DATACLAY="$JAVA_OPSBASE es.bsc.dataclay.tool.NewDataClayInstance"
IMPORT_MODELS_FROM_EXT_DATACLAY="$JAVA_OPSBASE es.bsc.dataclay.tool.ImportModelsFromExternalDataClay"


WAIT_DATACLAY_ALIVE="$JAVA_OPSBASE es.bsc.dataclay.tool.WaitForDataClayToBeAlive"

if [ -z $1 ]; then
	usage
	exit 0
fi
OPERATION=$1
shift
PARAMS="$@"
case $OPERATION in
	'-h' | '--help' | '?' | 'help')
		usage
		;;
	'NewAccount')
		$NEW_ACCOUNT $PARAMS
#		proposal for defaults:
#		$NEW_NAMESPACE $PARAMS $2_java java
#		$NEW_NAMESPACE $PARAMS $2_py python
#		$NEW_DATACONTRACT $PARAMS $2_ds $2
		;;
	'GetBackends')
		$GET_BACKENDS $PARAMS
		;;
	'GetDatasets')
		$GET_DATASETS $PARAMS
		;;
	'NewDataset')
		$NEW_DATASET $PARAMS
		;;
	'NewDataContract')
		$NEW_DATACONTRACT $PARAMS
		;;
	'NewNamespace')
		$NEW_NAMESPACE $PARAMS
		;;
	'GetNamespaces')
		$GET_NAMESPACES $PARAMS
		;;
	'NewModel')
		FOLDER=$4
		if [ $# -lt 5 ]; then
			errorMsg "Missing arguments. Usage: NewModel <user_name> <user_pass> <namespace_name> <class_path> <$SUPPORTEDLANGS>"
		fi
		if [ ! -d $FOLDER ]; then
			errorMsg "Model path $FOLDER is not a valid directory."
		fi
		case $5 in
			'java')
				$NEW_NAMESPACE $1 $2 $3 java
				if [ $? -ge 0 ]; then
					INIT_PARAMS="$1 $2 $3 $4"
					if [ $# -gt 5 ]; then
						INIT_PARAMS="$INIT_PARAMS $6"
					fi
					$JAVA_NEW_MODEL $INIT_PARAMS
				fi
				;;
			'python')
				$NEW_NAMESPACE $1 $2 $3 python
				if [ $? -ge 0 ]; then
					if [ $# -gt 5 ]; then
						errorMsg "Prefetching is only supported in Java applications."
					fi
					$PY_NEW_MODEL $1 $2 $3 $4
				fi
				;;
			*)
				errorMsg "Missing or unsupported language: '$6'. Must be one of the supported languages: $SUPPORTEDLANGS."
				;;
		esac
		;;
	'GetStubs')
		FOLDER=$4
		if [ $# -ne 4 ]; then
			errorMsg "Missing arguments. Usage: GetStubs <user_name> <user_pass> <namespace_name> <stubs_path>"
		fi
		if [ ! -d $FOLDER ]; then
			errorMsg "Stubs path $FOLDER is not a valid directory."
		fi
		LANG=`$GET_NAMESPACE_LANG $1 $2 $3 | grep ^LANG`
		case $LANG in
			'LANG_JAVA')
				$ACCESS_NS_MODEL $1 $2 $3
				if [ $? -ge 0 ]; then
					$JAVA_GETSTUBS $1 $2 $3 $4
				fi
				;;
			'LANG_PYTHON')
				CONTRACTID=`$ACCESS_NS_MODEL $1 $2 $3 | tail -1`
				if [ $? -ge 0 ] && [ ! -z $CONTRACTID ]; then
					$PY_GETSTUBS $1 $2 $CONTRACTID $4
				fi
				;;
			*)
				errorMsg "Missing or unsupported language: '$5'. Must be one of the supported languages: $SUPPORTEDLANGS."
				;;
		esac
		;;
	'GetDataClayID')
		$GET_DATACLAYID $PARAMS
		;;
	'RegisterDataClay')
		$REG_EXT_DATACLAY $PARAMS
		;;
	'GetExtDataClayID')
		$GET_EXT_DATACLAYID $PARAMS
		;;
  'ImportModelsFromExternalDataClay')
    $IMPORT_MODELS_FROM_EXT_DATACLAY $PARAMS
    ;;
	'WaitForDataClayToBeAlive')
		$WAIT_DATACLAY_ALIVE $PARAMS
		;;
	*)
		errorMsg "[ERROR]: Operation $1 is not supported."
		usage
		exit 1
		;;
esac
