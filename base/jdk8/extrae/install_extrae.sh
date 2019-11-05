#! /bin/bash
EXTRAE_VERSION=3.6.1 
function usage {
	FORMAT="%-30s %-30s \n"
	echo ""
	echo " Usage: $0 <extrae_home> [options] "
	echo ""
	echo ""
	echo "Options:"
	printf "$FORMAT" "--with-java <aspectj_weaver>"	"Indicates to build Extrae with java wrapper. "
}

################################# ARGUMENTS ########################################
if [[ $# -lt 1 ]]; then 
	echo "[ERROR]: Missing $EXTRAE_HOME"	
	echo "[WARNING]: $EXTRAE_HOME should be writable"	
    usage
    exit -1
fi
EXTRAE_HOME=$1

################################## OPTIONS #############################################
shift
while [[ $# -gt 0 ]]; do
    key="$1"
	case $key in
	--with-java)
		MAX_JAVA_VERSION=9
		printf "Checking if java version < $MAX_JAVA_VERSION..."
		version=$("java" -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{print $1}')
		if (("$version" > "$MAX_JAVA_VERSION")); then       
		    echo "WARNING: not installing Extrae with java since java version is greater than $MAX_JAVA_VERSION"
			exit 0 # return 0 to allow docker to skip
		fi
		printf "OK\n"
		shift 
		if [[ $# -ne 1 ]]; then 
    		usage
    		exit -1
    	fi
		ASPECTJ_WEAVER=$1
		EXTRA_OPTS="--with-java-jdk=$JAVA_HOME --with-java-aspectj-weaver=$ASPECTJ_WEAVER"
		shift
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        echo "  ERROR: Bad option $key"
        shift
        usage   # unknown option
        exit 1
        ;;
    esac
done

### ========================== INSTALL ============================= ##
TMPFOLDER=/tmp/extrae_build/
LIBPAPI=$(dirname $(find /usr/lib | grep libpapi | head -1))

echo " [INFO] Installing extrae... "
echo "		EXTRAE_VERSION=$EXTRAE_VERSION"
echo " 		EXTRAE_HOME=$EXTRAE_HOME"
echo "		LIBPAPI=$LIBPAPI"
echo " [INFO] EXTRA_OPTS = $EXTRA_OPTS"

mkdir -p $TMPFOLDER && \
curl -SL https://github.com/bsc-performance-tools/extrae/archive/${EXTRAE_VERSION}.tar.gz | tar -xzC $TMPFOLDER --strip-components=1 && \
cd $TMPFOLDER && \
./bootstrap && \
./configure --prefix=$EXTRAE_HOME \
	--without-mpi \
	--without-unwind \
	--without-dyninst \
	--with-papi=/usr/share/papi \
	--with-papi-headers=/usr/include \
	--with-papi-libs=$LIBPAPI \
	--disable-openmp \
	--disable-smpss \
	$EXTRA_OPTS && \
make && \
make install && \
make distclean

### ========================== CLEAN ============================= ##
rm -r $TMPFOLDER

echo "Extrae $EXTRAE_VERSION installed!"
