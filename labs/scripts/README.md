### TDDI41 SCRIPTS by oscpe262 and matla782
***
*bash version >= 4.0 needed*
***
The scripts suite consists of a few different categories of files:

#### UI/Flow Control Scripts
There are three UI/Flow Control Scripts: [tddi41.sh](./tddi41.sh "Main Script"), which is the main script to be run directly, most of the time. It, in turn, sources the other two scripts in this category - [configs.sh](./configs.sh "Configuration Branch"), and [tests.sh](./tests.sh "Tests Branch"). The latter two won't run on their own.

#### XXX_test.sh
The test scripts are tests for each lab. Some require remote access to the UMLs (through ssh), some need to be run locally on the UML. Running the main script and uploading them therethrough however, will take care of it all seamlessly. To increase the performance, output apart from failure/success have been removed from most tests. Some labs (e.g. DNS) makes use of both a local (DNS_test.sh) test script that can (and should) be run from anywhere, and a remote script (DNS_remotetest.sh) which is run from the UMLs. All this is, again seamlessly done from the main script.

#### XXX_conf.sh
The conf scripts contain any persistent modifications to the labs. They are uploaded and run through the main script. There is a known bug with installation of some packages over SSH, this can be circumvented either by running them directly on the UMLs, or by manually installing the needed packages - there might be a separate script added for this later on.

#### Source Scripts
The source scripts, [common.sh](./common.sh "Support Functions"), and [configs.sh](./configs.sh "Configuration Branch") and [tests.sh](./tests.sh "Tests Branch"), the latter two mentioned earlier, are not actively run on their own. Their purpose is to support the rest of the scripts with functionality that is used across different scripts, such as global variables, interface functions and runtime flow control.

#### List Files
The list files are listings of files etc. that are used in the scripts, mainly for transfer purposes.

#### Script Made Files
The scripts create two files: [nodes.conf](), which contains the globally selected group, and [transfer.tar]() which is used to transfer files to the UMLs in one go per UML. The latter is usually removed upon transfer completion, but the earlier is kept, though it can be removed manually.
