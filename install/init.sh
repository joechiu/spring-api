#!/bin/sh

DIR=/opt/dr
GIT=DR-Api

while true; do
    read -p "Do you cd to the git? Do you want to deploy[Y/n]? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "1. create the app work place"
[ -d $DIR ] || sudo mkdir -p $DIR

echo "2. backup the orignal codes"
sudo mv -f $DIR /tmp 

echo "3. download git repository"
git clone https://github.com/joechiu/$GIT.git

echo "4. deploy the git source to the workspace"
cd $GIT 
chmod 777 cache tmp logs
chmod 755 scripts scripts/dr-api.pl
sudo scp -rp . $DIR

echo "5. goto dr rest service for jar compile"
cd /opt/dr/dr-rest-service

echo "6. remove previous buildingsi if exists"
[ -d build ] && sudo rm -rf build 

echo "7. gradle build or gradle build clean could do the job"
./gradlew build --warning-mode=all

echo "8. dr web rest service source"
mv -f ./build/libs/dr-rest-service-0.0.1-SNAPSHOT.jar /opt/dr/bin/dr-rest-service.jar;

echo "9. create restful daemon"
sudo cp -f /opt/dr/install/bootrestfuld /etc/init.d/

echo "10. start daemon"
sudo /etc/init.d/bootrestfuld restart

echo "11. remove previous builds if exists"
[ -d build ] && rm -rf build 

