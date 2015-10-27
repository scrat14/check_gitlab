#!/bin/bash

#######################################################
#                                                     #
#  Name:    check_gitlab                              #
#                                                     #
#  Version: 1.0                                       #
#  Created: 2015-04-29                                #
#  License: GPLv3 - http://www.gnu.org/licenses       #
#  Copyright: (c)2015 René Koch                       #
#  Author:  René Koch <rkoch@rk-it.at>                #
#  URL: https://github.com/scrat14/check_gitlab       #
#                                                     #
#######################################################

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Changelog:
# * 1.0.1 - Tue Oct 27 2015 - Rene Koch <rkoch@rk-it.at>
# - Fixed permissions for sudoers file.
# * 1.0.0 - Wed Apr 29 2015 - René Koch <rkoch@rk-it.at>
# - This is the first release of new plugin check_gitlab

# Configuration
GITLAB_CTL="/usr/bin/gitlab-ctl"
SUDO="/usr/bin/sudo"

# Variables
PROG="check_gitlab"
VERSION="1.0.1"
VERBOSE=0
STATUS=3

# Icinga/Nagios status codes
STATUS_WARNING=1
STATUS_CRITICAL=2
STATUS_UNKNOWN=3


# function print_usage()
print_usage(){
  echo "Usage: ${0} [-v] [-V]"
}


# function print_help()
print_help(){
  echo ""
  echo "Gitlab plugin for Icinga/Nagios version ${VERSION}"
  echo "(c)2015 - Rene Koch <rkoch@rk-it.at>"
  echo ""
  echo ""
  print_usage
  cat <<EOT
Options:
 -h, --help
    Print detailed help screen
 -V, --version
    Print version information
 -v, --verbose
    Show details for command-line debugging (Nagios may truncate output)
Send email to rkoch@rk-it.at if you have questions regarding use
of this software. To sumbit patches of suggest improvements, send
email to rkoch@rk-it.at
EOT

exit ${STATUS_UNKNOWN}

}


# function print_version()
print_version(){
  echo "${PROG} ${VERSION}"
  exit ${STATUS_UNKNOWN}
}


# The main function starts here

# Parse command line options
while test -n "$1"; do
  
  case "$1" in
    -h | --help)
      print_help
      ;;
    -V | --version)
      print_version
      ;;
    -v | --verbose)
      VERBOSE=1
      shift
      ;;
    *)
      echo "Unknown argument: ${1}"
      print_usage
      exit ${STATUS_UNKNOWN}
      ;;
  esac
  shift
      
done


# Get status of Gitlab services
if [ ${VERBOSE} -eq 1 ]; then
  echo "[V]: Output of gitlab-ctl status:"
  echo "`${SUDO} ${GITLAB_CTL} status`"
fi

GITLAB=(`${SUDO} ${GITLAB_CTL} status | awk '{ print $1,$2 }' | tr -d ':'`)
if [ $? -ne 0 ]; then
	echo "Gitlab UNKNOWN: ${GITLAB[*]}"
	exit ${STATUS_UNKNOWN}
else
  # loop through array
  for INDEX in ${!GITLAB[*]}; do
    # even number in array is status of service
    # odd number is service itself
    if [ $(( ${INDEX}%2 )) -eq 0 ]; then
      # status needs to be "run", otherwise the service isn't running
      if [ ${GITLAB[${INDEX}]} != "run" ]; then
        STATUSTEXT="${STATUSTEXT} ${GITLAB[$((INDEX+1))]} is ${GITLAB[${INDEX}]},"
        STATUS=${STATUS_CRITICAL}
      fi
   fi
  done
fi

if [ -n "${STATUSTEXT}" ]; then
  # chop last ","
  STATUSTEXT="`echo ${STATUSTEXT} | awk '{print substr($0,1,length($0)-1)}'`" 
fi

if [ ${STATUS} -ne ${STATUS_CRITICAL} ]; then
  # Gitlab is OK
  echo "Gitlab OK: All services are running!"
  STATUS=${STATUS_OK}
else
  echo "Gitlab CRITICAL: ${STATUSTEXT}"
fi

exit ${STATUS}
