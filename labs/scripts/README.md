### SCRIPTS STRUCTURE
***
 **FILENAME** | _Description_ | Dependencies
:|:|:
 **tddi41.sh** | _Main script (SCT8)_ | tests.sh, SCT7.sh
 **tests.sh** | _Tests Branch_ | [XYZ]test.sh
 **SCT7.sh** | _SCT Task 7: add users_ | SCT7_funcs.sh
 **[XYZ]_funcs** | _Common functions for scripts related to task [XYZ]_ | common.sh
 **scpconfig.sh** | _rsyncs config files to project directory_ | common.sh
 **common.sh** | _Common functions for the project_ | bash version >= 4.0
***
