#!/bin/sh

#export LD_LIBRARY_PATH=/usr/local/lib
#ldconfig

#service postgresql start
#/usr/bin/redis-server /etc/redis/redis-openvas.conf

sudo -u postgres createuser -DRS root
sudo -u postgres createdb -O root gvmd
sudo -u postgres psql -d gvmd -f gvmd.sql


#mkdir -p /var/run/ospd
#chmod 777 /var/run/ospd

#mkdir -p /usr/local/var/run/
#mkdir -p /usr/local/var/run/
#chmod 777 /usr/local/var/run/
#chmod 777 /usr/local/var/run/gvmd.sock

if [ -z $OPENVAS_ADMIN_PASSWORD ]; then
  OPENVAS_ADMIN_PASSWORD=hello
fi

echo Create Admin user
gvmd --create-user=admin --password=$OPENVAS_ADMIN_PASSWORD --role="Super Admin"

echo Set up feed 
UID=`gvmd --get-users --verbose | grep admin | awk '{print $2}'`
echo UID: $UID
gvmd --modify-setting 78eceaec-3385-11ea-b237-28d24461215b --value $UID


greenbone-nvt-sync 
sleep 3
greenbone-feed-sync --type GVMD_DATA
sleep 3
greenbone-feed-sync --type SCAP
sleep 3
greenbone-feed-sync --type CERT
sleep 3
gvmd --rebuild
