#
# Common Utils
#

function disp_title() {
  local title="$1"
  local width=69
  printf "${GREEN}+-----------------------------------------------------------------------+\n"
  printf "| %-${width}s |\n" "$title"
  printf "+-----------------------------------------------------------------------+${NC}\n\n"
}

function disp_error_and_exit() {
  local error_message="$1"
  printf "${RED}+ $error_message ${NC}\n\n"
  exit 1
}

function disp_warn() {
  local warn_message="$1"
  printf "${MAGENTA}+ $warn_message ${NC}\n\n"
}

function disp_start_step() {
  local message="$1"
  printf "${CYAN}+ $message ${NC}\n"
}

function disp_result() {
  local message="$1"
  printf "${GREEN}+ $message ${NC}\n\n"
}

# Function: load_and_validate_env_variables
# Description: Load and validate environment variables for XC-SSO configuration.
# Arguments: N/A
# Returns: N/A
function load_and_validate_env_variables() {
  printf "${CYAN}+ Loading environment variables from .env file...${NC}\n"
  if [ ! -f .env ]; then
    disp_error_and_exit ".env file not found!"
  fi
  source .env

  if [ -z "$API_KEY" ]; then
    disp_error_and_exit "The API_KEY is empty or not set!"
  else
    echo "  | API_KEY                 : The API_KEY is correctly set"
  fi

  if [ -z "$XC_FQDN" ]; then
    disp_error_and_exit "The XC_FQDN is empty or not set!"
  else
    echo "  | XC_FQDN                 : $XC_FQDN"
  fi

  if [ -z "$XC_TENANT_NAME" ]; then
    disp_warn "The XC_TENANT_NAME is empty or not set!"
  else
    echo "  | XC_TENANT_NAME          : $XC_TENANT_NAME"
  fi

  disp_result "Loaded environment variables from .env file!"
}


# Function: get_payload_from_file
# Description: Get API payload from a JSON file
# Arguments:
#   $1: JSON payload file
# Returns:
#   $xc_payload: JSON payload
function get_payload_from_file() {
  local json_file="$1"
  if [ -z "$json_file" ]; then
    disp_error_and_exit "The argument of json_file is empty or not set!"
  fi
  xc_payload=$(cat "$json_file")
}


# Function: disp_status_code_resp_body
# Description: Display status_code and payload from the API response
# Arguments: N/A
#   $1: The status code from the API response
#   $2: API response body
#   $3: Option to debug response body
# Returns: N/A
function disp_status_code_resp_body() {
  local status_code="$1"
  local resp_body="$2"
  local resp_body_debug="$3"

  echo "  | HTTP Status Code: $status_code"
  if [[ $resp_body_debug == 1 ]]; then
    echo "  | Response Body   : "
    echo "$resp_body" | sed 's/^/    /'
  fi
}


# Function: upsert_user_roles_ns_req
# Description: Request to either assign or delete user roles & namespaces via POST API.
# Arguments:
#   $1: Payload to either assign or delete user roles & namespaces
#   $2: Option to debug response body
# Returns: N/A
function upsert_user_roles_ns_req() {
  local title="$1"
  local payload="$2"
  local res_body_debug="$3"
  disp_start_step "$title"

  # Make the PUT request and capture the response and HTTP status code
  local url="https://$XC_FQDN/api/web/custom/namespaces/system/user_roles"
  echo "  | PUT -X $url"
  local response=$(curl -s -w "%{http_code}"  \
    -k -X PUT "$url"                          \
    -H "Authorization: APIToken $API_KEY"     \
    -H "Content-Type: application/json"       \
    -H "Accept: application/json"             \
    -d "$payload")

  local status_code="${response: -3}"
  local response_body="${response:0:${#response}-3}"
  disp_status_code_resp_body "$status_code", "$response_body", "$res_body_debug"

  # Check if the request was successful (status code 2xx)
  if [[ "$status_code" -ge 200 && "$status_code" -lt 300 ]]; then
    disp_result "Requested to update user roles & namespaces!"
  else
    disp_error_and_exit "Failed to update user roles & namespaces!"
  fi
}


# Function: get_user_roles_ns_req
# Description: Request to get user roles and namespaces via GET API.
# Arguments:
#   $1: Option to debug response body
# Returns:
#   Result of whether the information is found or not.
function get_user_roles_ns_req() {
  disp_start_step "Retrieving user roles/namespaces configuration..."

  local res_body_debug="$1"

  # Make the GET request and capture the response and HTTP status code
  local url="https://$XC_FQDN/api/web/custom/namespaces/system/user_roles"
  local response=$(curl -s -w "%{http_code}"  \
    -k -X GET "$url"                          \
    -H "Authorization: APIToken $API_KEY"     \
    -H "Accept: application/json")

  local status_code="${response: -3}"
  local response_body="${response:0:${#response}-3}"
  disp_status_code_resp_body "$status_code", "$response_body", "$res_body_debug"

  if [[ "$status_code" -ge 200 && "$status_code" -lt 300 ]]; then
    disp_result "XC user roles/namespaces has been retrieved!"
    return "$FOUND"
  fi
  disp_error_and_exit "Failed to get user roles/namespaces!"
  return "$NOT_FOUND"
}
