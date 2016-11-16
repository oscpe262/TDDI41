### SCRIPTS STRUCTURE
***

| **FILENAME** | _Description_ | Includes Dependency |
|:---|:---|:---|
| **tddi41.sh** | _Main script (SCT8)_ | tests.sh, configs.sh, common.sh |
| **tests.sh** | _Tests Branch_ | [XYZ]test.sh |
| **configs.sh** | _Configuration Branch_ | [XYZ][N].sh |
| **[XYZ][N].sh** | _Lab [XYZ][Task] Script_ | [XYZ][N]_funcs.sh |
| **[XYZ][N][test].sh** | _Lab [XYZ][Task] Test Script_ | ( [XYZ][N]_funcs.sh ) |
| **[XYZ][N]_[node]conf.sh** | _Conf for lab XYZ_ | |
| **[XYZ]_funcs** | _Common functions for scripts related to task [XYZ]_ | |
| **remotetest.sh** | _Main executive script on remote hosts_ | common.sh |
| **scpconfig.sh** | _rsyncs config files to project directory_ | common.sh |
| **common.sh** | _Common functions for the project_ | |

*bash version >= 4.0 needed*
***
*The table above might be out of date at any specific point in time.*
