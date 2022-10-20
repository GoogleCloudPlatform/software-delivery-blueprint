# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

title_no_wait () {
    echo "${bold}# ${@}${normal}"
}

title_and_wait () {
    export CYAN='\033[1;36m'
    export YELLOW="\e[38;5;226m"
    export NC='\e[0m'
    echo "${bold}# ${@}"
    echo -e "${CYAN}--> Press ENTER to continue...${NC}"
    read -p ''
}

title_and_wait_step () {
    
    export RED='\e[1;31m'
    export NC='\e[0m'
    echo "${bold}# ${@}"
    echo -e "${RED}--> Press ENTER only if you completed the above instructions else the script will fail...${NC}"
    read -p ''
}

print_and_execute () {

    GREEN='\e[1;32m' # green
    NC='\e[0m'

    printf "${GREEN}\$ ${@}${NC}"
    printf "\n"
    eval "$@" ;
}

nopv_and_execute () {

    SPEED=210
    GREEN='\e[1;32m' # green
    NC='\e[0m'

    printf "${GREEN}\$ ${@}${NC}";
    printf "\n"
    eval "$@" ;
}

error_no_wait () {
    RED='\e[1;91m' # red
    NC='\e[0m'
    printf "${RED}# ${@}${NC}"
    printf "\n"
}

export -f print_and_execute
export -f title_no_wait
export -f title_and_wait
export -f nopv_and_execute
export -f error_no_wait
