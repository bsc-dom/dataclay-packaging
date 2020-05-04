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
load("gcc/" .. GCC_VERSION)
if (not isloaded("python")) then load("python/" .. PYTHON_FULL_VERSION) end
-- if (not isloaded("EXTRAE/3.5.4")) then load("EXTRAE/3.5.4") end

prereq(atleast("python","3.6.1"))
load("singularity/" .. SINGULARITY_VERSION) 

-- Bind into dataClay containers
-- add here colon sepparated folders to bind into singularity containers. 
-- /usr/lib64 is used by INTEL python
setenv("DATACLAY_EXT_BIND", "/usr/lib64")

-- DATACLAY binaries
append_path("PATH", DATACLAY_HOME .. "/bin")
setenv("DATACLAY_HOME", DATACLAY_HOME)

-- For apps outside containers

-- javaclay
setenv("DATACLAY_JAR", DATACLAY_HOME .. "/javaclay/dataclay.jar")

-- pyclay
execute {cmd="export PYCLAY_PATH=$DATACLAY_HOME/pyclay/src:$(find /apps/DATACLAY/dependencies/pyenv$(python --version | awk '{print $2}')* -name site-packages)",modeA={"load"}}

-- COMPSs bindings
append_path("PATH", DATACLAY_HOME .. "/scripts")
setenv("COMPSS_STORAGE_HOME", DATACLAY_HOME)



