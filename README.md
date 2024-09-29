# CouchDB-Brute
 
## Prerequisites

Ensure that CouchDB is installed and bound to the IP address `0.0.0.0`.

### Tool Setup

Run the following command (replace /path/to/couchdb-brute.nse with the actual path to the file):
   
   ```bash
   sudo mv /path/to/couchdb-brute.nse /usr/share/nmap/scripts/
   ```

### Tool Usage

Run `couchdb-brute.sh` using the following syntax:

    ```bash
    ./couchdb-brute.sh <Target IP address> <Port> "<path_to_users.txt>" "<path_to_pass.txt>"
    ```

### Notes

1. CouchDB has a default port of 5984.
2. `users.txt` and `pass.txt` files should contain the word lists that will be used to test against the database.
3. If `users.txt` and/or `pass.txt` paths are not provided, the tool will use the default credentials:
    
    ```bash
    Username: admin
    Password: password
    ```