#!/bin/bash

### Report: Automated tests that show that the NIS server is running and contains the appropriate data.
### When testing NIS at this point, when you have no clients, you may need to use the ypbind command manually to bind to the server. The ypcat command is useful to read the contents of a NIS map. The ypwhich command shows which server the client is bound to.

### Report: Automated tests that show that the clients bind to the NIS server at startup. At this point your clients are NIS clients but do not use NIS for anything.

### Report: Automated tests that show that the clients are now using NIS as expected. Answer to the question above.
