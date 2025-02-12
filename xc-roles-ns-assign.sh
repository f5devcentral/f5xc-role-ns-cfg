#!/bin/bash

# ----------------------------------------------------------------------------- #
# 1. Common Functions & Constants                                               #
# ----------------------------------------------------------------------------- #
source ./constants.sh
source ./utils.sh


# ----------------------------------------------------------------------------- #
# 2. Prerequisites : Display Title, Load & Validate Environment Variables       #
# ----------------------------------------------------------------------------- #
disp_title "Assign Roles and Namespaces for XC"
load_and_validate_env_variables


# ----------------------------------------------------------------------------- #
# 3. Assign User Roles & Namespaces                                             #
# ----------------------------------------------------------------------------- #
arg_api_req_file=$1
if [ -z "$arg_api_req_file" ]; then
    msg="The argument of API request file name is empty or not set!\n"
    example="  example: bash xc-roles-ns-assign.sh assign_user_roles_user_1.json"
    err_msg="$msg\n$example"
    disp_error_and_exit "$err_msg"
fi
get_payload_from_file "$arg_api_req_file"

title="Assigning user roles & namespaces..."
upsert_user_roles_ns_req "$title" "$xc_payload" "$API_PAYLOAD_DEBUG"
