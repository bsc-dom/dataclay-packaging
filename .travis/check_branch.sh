#!/bin/bash

if [[ $TRAVIS_BRANCH == 'master' ]]; then 
     echo "OK: Branch name accomplishes branch naming conventions [master]"
elif [[ $TRAVIS_BRANCH == 'develop' ]]; then 
     echo "OK: Branch name accomplishes branch naming conventions [develop]"
else
    valid_branch_regex="^(feature|bugfix|improvement|library|prerelease|release|hotfix)\/[a-z0-9._-]+$"
    if [[ ! $TRAVIS_BRANCH =~ $valid_branch_regex ]]; then
        echo "ERROR: There is something wrong with your branch name. Branch names in this project must adhere to this contract: $valid_branch_regex. Your PR will be rejected. You should rename your branch to a valid name and try again."
        exit 1
    else 
        echo "OK: Branch name accomplishes branch naming conventions"
    fi
fi
