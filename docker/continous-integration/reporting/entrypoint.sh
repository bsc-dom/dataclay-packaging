#!/bin/bash

# Install  keys
/appveyor-tools/secure-file -decrypt .appveyor/mn_deploy_key.enc -secret $MN_SECRET -salt $MN_SALT
/appveyor-tools/secure-file -decrypt .appveyor/github_deploy_key.enc -secret $GITHUB_SECRET -salt $GITHUB_SALT
mv .appveyor/mn_deploy_key $HOME/.ssh/mn_deploy_key
mv .appveyor/github_deploy_key $HOME/.ssh/github_deploy_key

# Configure ssh
chmod 600 "$HOME/.ssh/mn_deploy_key"
chmod 600 "$HOME/.ssh/github_deploy_key"
printf "%s\n" \
         "Host mn1.bsc.es" \
         "  IdentityFile $HOME/.ssh/mn_deploy_key" \
         "  StrictHostKeyChecking no" \
         "  UserKnownHostsFile=/dev/null" >> $HOME/.ssh/config
printf "%s\n" \
         "Host dt01.bsc.es" \
         "  IdentityFile $HOME/.ssh/mn_deploy_key" \
         "  StrictHostKeyChecking no" \
         "  UserKnownHostsFile=/dev/null" >> $HOME/.ssh/config
printf "%s\n" \
         "Host *" \
         "  StrictHostKeyChecking no" \
         "  UserKnownHostsFile=/dev/null" >> ~/.ssh/config
printf "%s\n" \
         "Host github.com" \
         "  IdentityFile $HOME/.ssh/github_deploy_key" \
         "  StrictHostKeyChecking no" \
         "  UserKnownHostsFile=/dev/null" >> $HOME/.ssh/config

git remote set-url origin git@github.com:bsc-dom/bsc-dom.github.io.git

# get test results
echo " ** Getting results ** "
mkdir -p /tmp/allure-results

scp -r dataclay@mn1.bsc.es:~/appveyor/testing-results/* /tmp/allure-results/

ls  /tmp/allure-results/
echo " ** Obtained results ** "

if [ "$(ls -A /tmp/allure-results/)" ]; then
	echo " ** Getting history ** "
	HISTORY_DIR="testing-report/history"
	if [ -d "$HISTORY_DIR" ]; then
		cp -R $HISTORY_DIR /tmp/allure-results/history
	fi
	echo " ** Obtained history ** "
	echo " ** Getting allure ** "
	# get modified allure version
	scp -r dataclay@mn1.bsc.es:~/appveyor/allure /tmp/allure
	echo " ** Obtained allure ** "
	echo " ** Generating executor ** "
	# generate executor 
	EXECUTOR='{
			"name":"Appveyor",
		 	"type":"appveyor",
			"url": "https://ci.appveyor.com/",
			"buildUrl": "https://ci.appveyor.com/"
			}'
	echo "$EXECUTOR" > /tmp/allure-results/executor.json
	echo " ** Generated executor ** "
	# remove previous report 
	echo " ** Removing previous report ** "
	git rm -rf testing-report/*
	echo " ** Removed previous report ** "
	
	# generate report 
	echo " ** Generating report ** "
	/tmp/allure/bin/allure generate /tmp/allure-results -o testing-report --clean
	echo " ** Generated report ** "

	# publish
	echo " ** Publishing ** "
	sed -i -e "s~base href=\"/\"~base href=\"/testing-report/\"~g" testing-report/index.html
	git add -A
	git commit -m "Updating test report from Appveyor"
	git push origin HEAD:master
	echo " ** Published ** "
	# remove last test results
	echo " ** Removing results ** "
	ssh dataclay@mn1.bsc.es "rm -rf appveyor/testing-results/*"
	echo " ** Removed results ** "
fi
