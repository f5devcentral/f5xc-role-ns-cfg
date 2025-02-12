#!/bin/bash

# ----------------------------------------------------------------------------- #
# 1. Common Functions & Constants                                               #
# ----------------------------------------------------------------------------- #
source ./constants.sh
source ./utils.sh


# ----------------------------------------------------------------------------- #
# 2. Prerequisites : Display Title, Load & Validate Environment Variables       #
# ----------------------------------------------------------------------------- #
disp_title "Roles and Namespaces Retrival for XC"
load_and_validate_env_variables


# ----------------------------------------------------------------------------- #
# 3. Get User Roles & Namespaces                                                #
# ----------------------------------------------------------------------------- #
get_user_roles_ns_req "$API_PAYLOAD_DEBUG"
