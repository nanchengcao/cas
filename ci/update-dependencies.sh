#!/bin/bash
source ./ci/functions.sh

runBuild=false
echo "Reviewing changes that might affect the Gradle build..."
currentChangeSetAffectsDependencies
retval=$?
if [ "$retval" == 0 ]
then
    echo "Found changes that affect project dependencies."
    runBuild=true
else
    echo "Changes do NOT affect project dependencies."
    runBuild=false
fi

if [ "$runBuild" = false ]; then
    exit 0
fi

echo -e "***********************************************"
echo -e "Build started at `date`"
echo -e "***********************************************"

echo -e "Installing renovate-bot...\n"
npm install -g renovate

waitloop="while sleep 9m; do echo -e '\n=====[ Build is still running ]====='; done &"
eval $waitloop
waitRetVal=$?

renovate --git-fs=https --token=${GH_TOKEN} --dry-run=true apereo/cas

echo -e "***************************************************************************************"
echo -e "Build finished at `date` with exit code $retVal"
echo -e "***************************************************************************************"

if [ $retVal == 0 ]; then
    echo "Gradle build finished successfully."
    exit 0
else
    echo "Gradle build did NOT finish successfully."
    exit $retVal
fi

