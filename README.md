[![Gem Version](https://badge.fury.io/rb/sync_stage.svg)](http://badge.fury.io/rb/SyncStage)

# SyncStage
Syncs back your Rails-app based production data to staging (or anywhere and vice versa)


The usual Rails deployment is done via capistrano and a specific deployment user.

This helper enables you to sync your typical Rails-App between given staging-servers.


## Install

`gem install sync_stage`

or use in Gemfile: 

`gem 'sync_stage'`

## Example:

```
cd /source/dir/rails_app
sync_stage -i
```
initializes `sync_stage.yml` in given directory.

adopt this file to your needs.


```
sync_stage -r 
```
dumps your database and packs your shared/public and copies it over to the destination host

running `sync_stage` without `-r` complains. 

just to be sure...


```
sync_stage -r --restore
```

dumps database, packs shared/public, copies it to destination, 

restores postgres dump, and unpacks shared/public to destinations shared/public

restoring is done by `sudo -u postgres`

```
sync_stage -r --restore --explain
```

prints out what would happen, but not actually executes anything.


## Prerequisites

* expects your app to be deployed via capistrano (or at least has some shared/public directory)
* expects only postgres database
* expects you have a deployment user
* expects your deployment user is a sudoer
* expects your postgres password is available via .pgpass (see:  http://www.postgresql.org/docs/9.3/static/libpq-pgpass.html )


