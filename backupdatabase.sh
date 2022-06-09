#!/bin/sh

echo "Create a directory name backup"
mkdir /opt/backups

echo "Date"
date=$(date '+%m-%d-%Y')

echo "Exporting database"
mysqldump -u root -proot12345 wordpress > wordpress${date}.sql

echo "Taping archive"
tar -cv wordpress${date}.sql > wordpress${date}.gz
~