# log onto the AWS instance and execute the following commands
mysqldump --host=$RDS_HOSTNAME --port=$RDS_PORT --user=$RDS_USERNAME --password=$RDS_PASSWORD $RDS_DB_NAME > dump.sql
aws s3 cp dump.sql  s3://elasticbeanstalk-us-west-2-438197573219/Backups/dump.sql
# Then go to the S3 console and download the file
# https://console.aws.amazon.com/s3/home?region=us-west-2#&bucket=elasticbeanstalk-us-west-2-438197573219&prefix=Backups/
# Once the file is downloaded you can restore it.
mysql -u root -p ebmpro_development < ~/Downloads/dump.sql
