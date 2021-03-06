# Artemis Development Platform
This is a containerized development platform for Artemis / Apollo3. A Docker image is provided to unify the experience across operating systems.

Based on concept from [**electron**vector.com](http://www.electronvector.com/blog/simple-embedded-build-environments-with-docker)

## General Information
A script is provided to run the development environment. 
Access to serial ports is not supported by Docker so after building you will need a separate upload step

## Install Docker
* Install [Docker](https://hub.docker.com/?overlay=onboarding)
   * When the Docker installer asks, you will need Linux containers
   * You will need to allow access to your file system
   * The install may require you to log out and log back in or reboot your machine

## Getting Started
### Initial Steps: 
* set your working directory environment variable
* navigate to your working directory
* set your ADP_NAME environment variable
    * choose a local name for this repo 
    * this will also be the name of the Docker image 
    * the name of the variable does not matter as long as you are consistent (but you do need to use snake_case) 
    * optionally you might choose to make this a permanent fixture of your bash environment
* recursively clone this repo
* enter the root of repo
* perform initial setup of environment (build Docker image)


Bash
```
WORK_DIR=< your_working_directory >
cd ${WORK_DIR}
ADP_NAME=artemis_dev_platform
git clone --recursive https://github.com/sparkfun/artemis_dev_platform $ADP_NAME
cd $ADP_NAME
./ev
```


Cmd Prompt
```
set WORK_DIR=< your_working_directory >
cd %WORK_DIR%
set ADP_NAME=artemis_dev_platform
git clone --recursive https://github.com/sparkfun/artemis_dev_platform %ADP_NAME%
cd %ADP_NAME%
ev.bat
```

### Using the Interactive Container
The interactive container is the easiest way to get started with the development platform.
No matter what host OS you are using the container will present a standardized environment that you can use to build examples and custom projects.

* -it starts an interactive session with a bash shell
* --mount creates a bridge between the container and the host filesystems
    * source="$(pwd)" specifies the current working directory as the host (source) side of the bridge
    * target=/app specifies the /app dir in the container as the destination
    * /app is the default/working directory in the container
* $ADP_NAME specifies which image to use and should have been set in Getting Started

Bash
```
    cd $ADP_NAME  # if you haven't already entered the artemis_dev_platform root
    docker run -it --mount type=bind,source="$(pwd)",target=/app $(basename $(pwd))
```

Cmd Prompt
```
    docker run -it --mount type=bind,source="%cd%",target=/app %ADP_NAME%
```

## Building Examples
At the bash shell provided by the interactive container follow these instructions:
``` bash
cd /app/                          # begin at the app root space
BOARD=redboard_artemis_atp        # or: edge, artemis_thing_plus, artemis_redboard_nano, artemis_redboard_atp etc...
EXAMPLE=hello_world_uart          # or: ble_freertos_tag, blinky, tensorflow_micro_speech or other applicable example for board
cd AmbiqSuiteSDK/boards_sfe/common/examples/$EXAMPLE/gcc # go to the example Makefile
make BOARD=$BOARD                                             # builds for default bootloader (equivalent to 'make asb')
make BOARD=$BOARD asb                                         # builds for Ambiq Secure Bootloader (protected + always avaialable)
make BOARD=$BOARD svl                                         # builds for SparkFun Variable Loader (can be overwritten + must be flashed to board first)
```

## Building New Projects
You can make your own projects from scratch. The main requirement is that the files are available through the bridge. Here's an example.

In the container 
``` bash
PROJNAME=myproj        # choose a name for the project
mkdir -p $PROJNAME/gcc # make a directory for your project w/ a gcc build folder
mkdir $PROJNAME/src    # make a src directory
# copy the makefile template
cp AmbiqSuiteSDK/boards_sfe/common/tools_sfe/templates/makefile_template.mk $PROJNAME/gcc/Makefile
# copy the main template
cp AmbiqSuiteSDK/boards_sfe/common/tools_sfe/templates/main_template.c $PROJNAME/src/main.c
BOARD=redboard_artemis # choose the board to use
cd $PROJNAME/gcc       # enter the gcc build directory
# build the project by specifying which BSP to use
make BOARDPATH=/app/AmbiqSuiteSDK/boards_sfe/$BOARD

# alternately you can specify the bootloader that will be used - this selects the appropriate linker script
make asb BOARDPATH=/app/AmbiqSuiteSDK/boards_sfe/$BOARD # build for Ambiq Secure Bootloader
make svl BOARDPATH=/app/AmbiqSuiteSDK/boards_sfe/$BOARD # build for SparkFun Variable Loader
```

The result will be a ```.bin``` file that appears on your host computer under the ```gcc``` directory of your project.

## Uploading Built Binaries
Since Docker does not standardize access to serial ports (COM on Windows and /de/tty* on *nix) you will need to use the uploader tools:

* Install Python3
* Install Pip3
* Install required Python modules
  * ```pip3 install --upgrade pycryptodome```
  * ```pip3 install --upgrade pyserial```
* ```BINPATH=$path_to_compiled_binary```
* Choose either the ASB or SVL uploader (match the option you used to compile)
  * ```python3 AmbiqSuiteSDK/boards_sfe/common/tools_sfe/artemis/artemis_svl.py -f $BINPATH -b $BAUD_RATE port $SERIAL_PORT```
  * ```python3 AmbiqSuiteSDK/boards_sfe/common/tools_sfe/ambiq/ambiq_bin2board.py --bin $BINPATH --load-address-blob 0x20000 --magic-num 0xCB -o ./temporary --version 0x0 --load-address-wired 0xC000 -i 6 --options 0x1 -b $BAUD_RATE -port $SERIAL_PORT -r 2```

## Debugging with VSC
You can use an in-chip-debugger like a SEGGER J-link to do step-by-step debugging of your code. One easy way to do this is to use the Visual Studio Code ```cortex-debug``` extension. You'll need to set up a [Launch Configuration](https://code.visualstudio.com/docs/editor/debugging#_launch-configurations) along these lines:

```
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "type": "cortex-debug",
            "request": "launch",
            "name": "Cortex Debug",
            "cwd": "${workspaceRoot}", // workspaceRoot refers to the VSCode root workspace
            "executable": "${workspaceRoot}/path_to_elf/compiled_program.elf",
            "serverpath": "C:/Program Files (x86)/SEGGER/JLink_V642/JLinkGDBServerCL.exe", // This needs to point to your GDB Server - this example shows one for SEGGER J-Link
            "servertype": "jlink",
            "device": "AMA3B1KK-KBR",
            "interface": "swd", // or "jtag" - but usually "swd"
            "serialNumber": "", //if you have more than one J-Link probe add the serial number here 
            "runToMain": true,
            "svdFile": "C:/Users/path_to_Ambiq_device_firmware_pack/AmbiqMicro.Apollo_DFP.1.1.0/SVD/apollo3.svd",
        }
    ]
}
```

Then you should be able to launch debugging with ```F5```. Note that things will be very confusing if the code you have flashed to the baord does not match the executable that you list in the launch configuration. 
