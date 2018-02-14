#!/bin/bash

# USAGE SEE PROVISION_CONFLUENCE_DS_VERSIONS.md

####################################################################################
# MIT License
# Copyright (c) 2018 Bernhard Grünewaldt
# See https://github.com/codeclou/docker-atlassian-confluence-data-center/blob/master/LICENSE
####################################################################################

set -e

####################################################################################
#
# VARS
#
####################################################################################

# script params
ACTION=$1
LAST_VERSION=$2
NEW_VERSION=$3

# internal vars
script_version="2018-02-13 19:19"
NEW_VERSION_NO_DOTS=${NEW_VERSION//[.]/}
LAST_VERSION_NO_DOTS=${LAST_VERSION//[.]/}

####################################################################################
#
# COLORS
#
####################################################################################

export CLICOLOR=1
C_RED='\x1B[31m'
C_CYN='\x1B[96m'
C_GRN='\x1B[32m'
C_MGN='\x1B[35m'
C_RST='\x1B[39m'

####################################################################################
#
# FUNCTIONS
#
####################################################################################

# Used to be able to use pass-by-reference in bash
#
#
return_by_reference() {
    if unset -v "$1"; then
        eval $1=\"\$2\"
    fi
}

# Replace str1 in file by str2
#
# @param $1 {string} str1
# @param $2 {string} str2
# @param $3 {string} file
function replace_in_file {
  str1=$1
  str2=$2
  file=$3
  echo -e $C_GRN"   replace   : ${C_CYN}${str1}${C_RST} by ${C_CYN}${str2}${C_RST} in ${C_CYN}${file}${C_RST}${C_RST}"
  # Usage with .bak is compatible to macOS and normal linux
  sed -i .bak "s/${str1}/${str2}/g" ${file}
  rm -f ${file}.bak
}

# Rename oldFileName by newFileName
#
# @param $1 {string} oldFileName
# @param $2 {string} newFileName
function rename_file {
  oldFileName=$1
  newFileName=$2
  echo -e $C_GRN"   renaming  : ${C_CYN}${oldFileName}${C_RST} to ${C_CYN}${newFileName}${C_RST}${C_RST}"
  mv ${oldFileName} ${newFileName}
}

# Clone folder dirToClone to dirNameToCloneTo
#
# @param $1 {string} dirToClone
# @param $2 {string} dirNameToCloneTo
function clone_dir {
  dirToClone=$1
  dirNameToCloneTo=$2
  echo -e $C_GRN"   clone dir : ${C_CYN}${dirToClone}${C_RST} to ${C_CYN}${dirNameToCloneTo}${C_RST}${C_RST}"
  cp -r ${dirToClone} ${dirNameToCloneTo}
}


# Print action header
#
# @param $1 {string} actionname
function print_action_header {
  echo -e $C_MGN">>${C_RST}"
  echo -e $C_MGN">> ACTION: ${1} >  ${LAST_VERSION} -> ${NEW_VERSION} ${C_RST}"
  echo -e $C_MGN">>${C_RST}"
  echo ""
}

# Checks if branchName exists
#
# @param $1 {string} branchName
# @param $2 {int} return value passByReference
function does_branch_exist {
  branchName=$1
  local ret_value=-1
  local DOES_BRANCH_EXIST=$(git branch -a | grep $branchName | wc -l | awk '{print $1}')
  if [ "$DOES_BRANCH_EXIST" != "0" ]
  then
    ret_value=1
  fi
  local "$2" && return_by_reference $2 $ret_value
}

# Checks out branchName (you must check if exists before!)
#
# @param $1 {string} branchName
function checkout_branch {
  branchName=$1
  git checkout ${branchName} > /dev/null 2>&1
}

# Git
#
# @param $1 {string} branchName
function branch_must_exist {
  branchName=$1
  does_branch_exist_result=-1
  does_branch_exist ${branchName} does_branch_exist_result
  if [ "$does_branch_exist_result" == "1" ]
  then
    echo -e $C_GRN"   branch ${branchName} exists. CONTINUE.${C_RST}"
  else
    echo -e $C_RED"   branch ${branchName} does not exist (must exist to continue). EXIT.${C_RST}"
    exit 1
  fi
}

# Git
#
# @param $1 {string} branchName
function branch_must_not_exist {
  branchName=$1
  does_branch_exist_result=-1
  does_branch_exist ${branchName} does_branch_exist_result
  if [ "$does_branch_exist_result" == "1" ]
  then
    echo -e $C_RED"   branch ${branchName} exists (must not exist to continue). EXIT.${C_RST}"
    exit 1
  else
    echo -e $C_GRN"   branch ${branchName} does not exists. CONTINUE.${C_RST}"
  fi
}

#
# SCRIPT HEADER
#
echo ""
echo -e $C_MGN'°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸'$C_RST
echo ""
echo -e $C_GRN'  Create new versions of Confluence® Data Center management scripts and docker images'$C_RST
echo -e $C_MGN'  github  https://git.io/vA3GE'$C_RST
echo -e $C_CYN"  version $script_version"$C_RST
echo ""
echo -e $C_MGN'°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°°º¤ø,¸¸,ø¤º°`°º¤ø,¸,ø¤°º¤ø,¸¸,ø¤º°`°º¤ø,¸¸,ø¤º°`°º¤ø,¸'$C_RST
echo ""





####################################################################################
#
# ACTION: management-scripts
#
####################################################################################
if [ "$ACTION" == "management-scripts" ]
then
####################################################################################

  print_action_header $ACTION
  echo -e $C_CYN">> trying to clone management scripts on master branch${C_RST}"
  cd ~/.provision-confluence-ds-versions-workdir/
  if [ -d "docker-atlassian-confluence-data-center___management-scripts" ]
  then
    rm -rf docker-atlassian-confluence-data-center___management-scripts
  fi
  git clone https://github.com/codeclou/docker-atlassian-confluence-data-center.git docker-atlassian-confluence-data-center___management-scripts
  cd docker-atlassian-confluence-data-center___management-scripts
  git checkout master > /dev/null 2>&1
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  if [ "$current_branch" == "master" ]
  then
    echo -e $C_GRN"   we are on master branch ...${C_RST}"
  else
    echo -e $C_RED"   we are NOT on master branch. EXIT${C_RST}"
    exit 1
  fi

  echo ""
  echo -e $C_CYN">> trying to create new version ${NEW_VERSION} from old version ${LAST_VERSION}.${C_RST}"

  if [ -d "${NEW_VERSION}" ]
  then
    echo -e $C_RED"   new version ${NEW_VERSION} already exists. EXIT${C_RST}"
    exit 1
  else
    echo -e $C_GRN"   new version ${NEW_VERSION} does not yet exist. CONTINUE${C_RST}"
  fi
  echo ""

  clone_dir ${LAST_VERSION} ${NEW_VERSION}

  cd ${NEW_VERSION}
  rename_file     manage-confluence-cluster-${LAST_VERSION}.sh             manage-confluence-cluster-${NEW_VERSION}.sh
  rename_file     manage-confluence-cluster-${LAST_VERSION}-version.txt    manage-confluence-cluster-${NEW_VERSION}-version.txt
  replace_in_file ${LAST_VERSION}           ${NEW_VERSION}           manage-confluence-cluster-${NEW_VERSION}.sh
  replace_in_file ${LAST_VERSION}           ${NEW_VERSION}           README.md
  replace_in_file ${LAST_VERSION_NO_DOTS}   ${NEW_VERSION_NO_DOTS}   manage-confluence-cluster-${NEW_VERSION}.sh
  replace_in_file ${LAST_VERSION_NO_DOTS}   ${NEW_VERSION_NO_DOTS}   README.md
  cd ..

  function management_scripts_do_git_push {
      git add ./${NEW_VERSION}
      git commit -m "automated creation of version ${NEW_VERSION}"
      echo -e $C_GRN"   adding new files and pushing to GitHub"${C_RST}
      git push
  }
  function management_scripts_cancel_git_push {
    echo -e $C_RED"   skipping push. no files changed on remote."${C_RST}
  }
  git status
  echo -e $C_CYN">> Do you wish to push changes to GitHub?${C_RST}"
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) management_scripts_do_git_push; break;;
          No ) management_scripts_cancel_git_push; exit;;
      esac
  done

  # cleanup
  rm -rf docker-atlassian-confluence-data-center___management-scripts
  echo ""

####################################################################################
fi
####################################################################################



####################################################################################
#
# ACTION: BASE-IMAGE
#
####################################################################################
if [ "$ACTION" == "base-image" ]
then
####################################################################################

  print_action_header $ACTION
  echo -e $C_CYN">> trying to clone atlassian-base-images repo${C_RST}"
  cd ~/.provision-confluence-ds-versions-workdir/
  if [ -d "docker-atlassian-base-images___confluence" ]
  then
    rm -rf docker-atlassian-base-images___confluence
  fi
  git clone https://github.com/codeclou/docker-atlassian-base-images.git docker-atlassian-base-images___confluence
  cd docker-atlassian-base-images___confluence
  pwd
  branch_must_exist "confluence-${LAST_VERSION}"
  branch_must_not_exist "confluence-${NEW_VERSION}"
  checkout_branch conluencenode-${LAST_VERSION}


####################################################################################
fi
####################################################################################







#echo -e $C_CYN">> trying to clone confluencenode-${LAST_VERSION} branch${C_RST}"
#git checkout confluencenode-${LAST_VERSION} > /dev/null 2>&1
#current_branch=$(git rev-parse --abbrev-ref HEAD)
#if [ "$current_branch" == "confluencenode-${LAST_VERSION}" ]
#then
#  echo -e $C_GRN"   we are on confluencenode-${LAST_VERSION} branch ...${C_RST}"
#else
#  echo -e $C_RED"   we are NOT on confluencenode-${LAST_VERSION} branch. EXIT${C_RST}"
#  exit 1
#fi
