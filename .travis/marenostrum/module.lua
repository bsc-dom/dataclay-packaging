-- Information
whatis("Version: SET_VERSION_HERE")
whatis("Keywords: Storage, dataClay, data distribution")
whatis("Description: dataClay active objects across the network")

-- lua mod file for dataClay
PROG_NAME = "DATACLAY"
PROG_VERSION = "SET_VERSION_HERE"
PROG_HOME = "/apps/" .. PROG_NAME .. "/" .. PROG_VERSION
DATACLAY_HOME = PROG_HOME

-- Dependencies
SINGULARITY_VERSION = "3.5.2"
PYTHON_VERSION = "3.7"
PYTHON_FULL_VERSION = "3.7.4"
GCC_VERSION = "8.1.0"

-- Module dependencies
-- load("java/8u131")
load("gcc/" .. GCC_VERSION)
load("python/" .. PYTHON_FULL_VERSION)
load("singularity/" .. SINGULARITY_VERSION) 

-- Bind into dataClay containers
-- add here colon sepparated folders to bind into singularity containers. 
-- /usr/lib64 is used by INTEL python
setenv("DATACLAY_EXT_BIND", "/usr/lib64")

-- DATACLAY binaries
append_path("PATH", DATACLAY_HOME .. "/bin")
setenv("DATACLAY_HOME", DATACLAY_HOME)

-- For apps outside containers
PYCLAY_PATH = DATACLAY_HOME .. "/client/pyclay/lib/python" .. PYTHON_VERSION .. "/site-packages"
DATACLAY_JAR = DATACLAY_HOME .. "/client/javaclay/dataclay.jar"
setenv("PYCLAY_PATH", PYCLAY_PATH)
setenv("DATACLAY_JAR", DATACLAY_JAR)

-- COMPSs bindings
append_path("PATH", DATACLAY_HOME .. "/scripts")
setenv("COMPSS_STORAGE_HOME", DATACLAY_HOME)
append_path("PYTHONPATH", PYCLAY_PATH)

-- Extrae 
-- setenv("DATACLAY_EXTRAE_WRAPPER_LIB", DATACLAY_HOME .. "/client/pyclay/pyextrae/dataclay_extrae_wrapper.so")
-- setenv("EXTRAE_CONFIG_FILE", DATACLAY_HOME .. "/client/pyclay/pyextrae/extrae_python.xml")
-- setenv("EXTRAE_SKIP_AUTO_LIBRARY_INITIALIZE", "1")



