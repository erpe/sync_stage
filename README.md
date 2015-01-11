# sync_stage
Syncs back your Rails-app based production data to staging (or anywhere and vice versa)


The usual Rails deployment is done via capistrano and a specific deployment user.

This helper enables you to sync your typical Rails-App between given staging-servers.

## Example:

```
sync_stage -r 
```
dumps your database and packs your shared/public and copies it over to the destination host


```
sync_stage -r --restore
```

dumps database, packs shared/public, copies it to destination, 
restores postgres dump, and unpacks shared/public to destinations shared/public
restoring is done by `sudo -u postgres`

```
sync_stage -r --restores --explain
```

prints out what would happen, but not actually executes anything.



## Prerequisites

* expects your app to be deployed via capistrano
* expects only postgres database
* expects you have a deployment user
* expects you're deployment user is a sudoer
* expects your postgres password is available via .pgpass (see:  http://www.postgresql.org/docs/9.3/static/libpq-pgpass.html )


