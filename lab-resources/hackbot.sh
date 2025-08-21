#!/bin/bash

# File to store the token
TOKEN_FILE="auth_token.txt"

export CONTROLLER_URL="https://$HOSTNAME/api/controller"
echo $CONTROLLER_URL

# Colors for robot-like appearance
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Check if CONTROLLER_URL is set
if [ -z "$CONTROLLER_URL" ]; then
    echo -e "${RED}🤖 ERROR: The environment variable CONTROLLER_URL is not set. Please set it before running this script.${RESET}"
    echo "Example: export CONTROLLER_URL=https://api.example.com"
    exit 1
fi

# Function to execute curl with error handling
function execute_curl() {
    local job_template_id=$1
    local action_name=$2
    
    echo -e "${CYAN}🤖 Sending POST request to AAP API...${RESET}"
    sleep 2
    
    # Capture both stdout and stderr, and get the exit code
    local temp_file=$(mktemp)
    local http_code
    local exit_code
    
    http_code=$(curl -k -w "%{http_code}" -X POST "$CONTROLLER_URL/v2/job_templates/$job_template_id/launch" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $AUTH_TOKEN" \
        -o "$temp_file" 2>&1)
    exit_code=$?
    
    # Check if curl command itself failed (network issues, invalid URL, etc.)
    if [ $exit_code -ne 0 ]; then
        echo -e "${RED}🤖 ERROR: Failed to connect to the API server!${RESET}"
        echo -e "${RED}   - Check your network connection${RESET}"
        echo -e "${RED}   - Verify CONTROLLER_URL: $CONTROLLER_URL${RESET}"
        echo -e "${RED}   - Exit code: $exit_code${RESET}"
        rm -f "$temp_file"
        return 1
    fi
    
    # Check HTTP response codes
    case $http_code in
        200|201|202)
            echo -e "${GREEN}🤖 SUCCESS: $action_name completed successfully! (HTTP $http_code)${RESET}"
            ;;
        401)
            echo -e "${RED}🤖 ERROR: Authentication failed (HTTP 401)${RESET}"
            echo -e "${RED}   - Your authorization token may be invalid or expired${RESET}"
            echo -e "${RED}   - Please check your token and try again${RESET}"
            ;;
        403)
            echo -e "${RED}🤖 ERROR: Access forbidden (HTTP 403)${RESET}"
            echo -e "${RED}   - You don't have permission to execute this job template${RESET}"
            ;;
        404)
            echo -e "${RED}🤖 ERROR: Job template not found (HTTP 404)${RESET}"
            echo -e "${RED}   - Job template ID $job_template_id doesn't exist${RESET}"
            ;;
        500)
            echo -e "${RED}🤖 ERROR: Internal server error (HTTP 500)${RESET}"
            echo -e "${RED}   - The API server encountered an error${RESET}"
            ;;
        *)
            echo -e "${YELLOW}🤖 WARNING: Unexpected response (HTTP $http_code)${RESET}"
            echo -e "${YELLOW}   - The request may have partially succeeded${RESET}"
            ;;
    esac
    
    # Show response content if there's an error (for debugging)
    if [[ ! "$http_code" =~ ^2[0-9][0-9]$ ]]; then
        if [ -s "$temp_file" ]; then
            echo -e "${YELLOW}🤖 Server response:${RESET}"
            cat "$temp_file" | head -3  # Show first few lines of response
        fi
    fi
    
    rm -f "$temp_file"
    
    # Return success only for 2xx codes
    if [[ "$http_code" =~ ^2[0-9][0-9]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Prompt for the token and confirm it
function get_auth_token() {
    while true; do
        echo -n -e "${CYAN}🤖 Hello! I am your co-worker simulator S.E.A.N - Please provide your authorization token: ${RESET}"
        read -s AUTH_TOKEN
        echo -e "\n${CYAN}🤖 You entered: ${GREEN}$AUTH_TOKEN${RESET}"
        echo -n -e "${CYAN}🤖 Is this correct? (yes/no): ${RESET}"
        read answer
        if [[ "$answer" == "yes" ]]; then
            break
        else
            echo -e "${RED}🤖 Let's try again.${RESET}"
        fi
    done
    echo "$AUTH_TOKEN" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"  # Restrict file permissions for security
    echo -e "${CYAN}🤖 Token saved to file.${RESET}"
}

# Validate token format (basic check)
function validate_token() {
    if [ -z "$AUTH_TOKEN" ]; then
        echo -e "${RED}🤖 ERROR: Authorization token is empty!${RESET}"
        return 1
    fi
    
    # Basic token format validation (adjust regex based on your token format)
    if [[ ! "$AUTH_TOKEN" =~ ^[A-Za-z0-9._-]+$ ]]; then
        echo -e "${YELLOW}🤖 WARNING: Token format looks unusual. This might cause authentication issues.${RESET}"
    fi
    
    return 0
}

# Check if the token file exists
if [ -f "$TOKEN_FILE" ]; then
    # Load the token from the file
    AUTH_TOKEN=$(<"$TOKEN_FILE")
    echo -e "${CYAN}🤖 Token loaded from file.${RESET}"
else
    # Prompt for a new token
    get_auth_token
fi

# Validate the loaded/entered token
if ! validate_token; then
    echo -e "${RED}🤖 Exiting due to token validation failure.${RESET}"
    exit 1
fi

# Display menu
function show_menu() {
    echo -e "${GREEN}"
    echo "1. Simulate the faulty Web Change"
    echo "2. Reset Web Application Config"
    echo "3. Break the network!"
    echo "4. Patch in a new device"
    echo "5. Exit"
    echo -e "${RESET}"
}

# Perform action based on user choice
function perform_action() {
    case $1 in
        1)
            execute_curl 15 "Faulty Web Change Simulation"
            ;;
        2)
            execute_curl 14 "Web Application Config Reset"
            ;;
        3)
            execute_curl 11 "Network Break Operation"
            ;;
        4)
            execute_curl 13 "New Device Patching"
            ;;
        5)
            echo -e "${RED}🤖 Shutting down... Goodbye, Co-Worker!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}🤖 Invalid choice. Please select a valid option.${RESET}"
            return 1
            ;;
    esac
}

# Main loop
while true; do
    show_menu
    echo -n -e "${CYAN}🤖 What would you like me to do? Enter your choice: ${RESET}"
    read choice
    
    if perform_action $choice; then
        echo -e "${CYAN}🤖 Task complete!${RESET}"
    else
        echo -e "${RED}🤖 Task encountered issues. Please check the error messages above.${RESET}"
    fi
    
    echo ""
    echo -e "${CYAN}Press Enter to continue...${RESET}"
    read
done


#########################################OLD
# # File to store the token
# TOKEN_FILE="auth_token.txt"

# export CONTROLLER_URL="https://$HOSTNAME/api/controller"
# echo $CONTROLLER_URL

# # Colors for robot-like appearance
# GREEN='\033[0;32m'
# CYAN='\033[0;36m'
# RED='\033[0;31m'
# RESET='\033[0m'

# # Check if CONTROLLER_URL is set
# if [ -z "$CONTROLLER_URL" ]; then
#     echo -e "${RED}🤖 ERROR: The environment variable CONTROLLER_URL is not set. Please set it before running this script.${RESET}"
#     echo "Example: export CONTROLLER_URL=https://api.example.com"
#     exit 1
# fi

# # Prompt for the token and confirm it
# function get_auth_token() {
#     while true; do
#         echo -n -e "${CYAN}🤖 Hello! I am your co-worker simulator S.E.A.N - Please provide your authorization token: ${RESET}"
#         read -s AUTH_TOKEN
#         echo -e "\n${CYAN}🤖 You entered: ${GREEN}$AUTH_TOKEN${RESET}"
#         echo -n -e "${CYAN}🤖 Is this correct? (yes/no): ${RESET}"
#         read answer
#         if [[ "$answer" == "yes" ]]; then
#             break
#         else
#             echo -e "${RED}🤖 Let's try again.${RESET}"
#         fi
#     done
#     echo "$AUTH_TOKEN" > "$TOKEN_FILE"
#     chmod 600 "$TOKEN_FILE"  # Restrict file permissions for security
#     echo -e "${CYAN}🤖 Token saved to file.${RESET}"
# }

# # Check if the token file exists
# if [ -f "$TOKEN_FILE" ]; then
#     # Load the token from the file
#     AUTH_TOKEN=$(<"$TOKEN_FILE")
#     echo -e "${CYAN}🤖 Token loaded from file.${RESET}"
# else
#     # Prompt for a new token
#     get_auth_token
# fi

# # Display menu
# function show_menu() {
#     echo -e "${GREEN}"
#     echo "1. Simulate the faulty Web Change"
#     echo "2. Reset Web Application Config"
#     echo "3. Break the network!"
#     echo "4. Patch in a new device"
#     echo "5. Exit"
#     echo -e "${RESET}"
# }

# # Perform action based on user choice
# function perform_action() {
#     case $1 in
#         1)
#             echo -e "${CYAN}🤖 Sending POST request to AAP API...${RESET}"
#             sleep 5
#             curl -k -X POST "$CONTROLLER_URL/v2/job_templates/15/launch" -H "Content-Type: application/json" -H "Authorization: Bearer $AUTH_TOKEN" > /dev/null 2>&1 & clear
#             ;;

#         2)
#             echo -e "${CYAN}🤖 Sending POST request to AAP API...${RESET}"
#             sleep 5
#             curl -k -X POST "$CONTROLLER_URL/v2/job_templates/14/launch" -H "Content-Type: application/json" -H "Authorization: Bearer $AUTH_TOKEN" > /dev/null 2>&1 & clear
#             ;;

#         3)
#             echo -e "${CYAN}🤖 Sending POST request to AAP API...${RESET}"
#             sleep 5
#             curl -k -X POST "$CONTROLLER_URL/v2/job_templates/11/launch" -H "Content-Type: application/json" -H "Authorization: Bearer $AUTH_TOKEN" > /dev/null 2>&1 & clear
#             ;;

#         4)
#             echo -e "${CYAN}🤖 Sending POST request to AAP API...${RESET}"
#             sleep 5
#             curl -k -X POST "$CONTROLLER_URL/v2/job_templates/13/launch" -H "Content-Type: application/json" -H "Authorization: Bearer $AUTH_TOKEN" > /dev/null 2>&1 & clear
#             ;;

#         5)
#             echo -e "${RED}🤖 Shutting down... Goodbye, Co-Worker!${RESET}"
#             exit 0
#             ;;
#         *)
#             echo -e "${RED}🤖 Invalid choice. Please select a valid option.${RESET}"
#             ;;
#     esac
# }

# # Main loop
# while true; do
#     show_menu
#     echo -n -e "${CYAN}🤖 What would you like me to do? Enter your choice: ${RESET}"
#     read choice
#     perform_action $choice
#     echo -e "${CYAN}🤖 Task complete!${RESET}"
#     echo ""
# done




# # #!/bin/bash

# # export CONTROLLER_URL="https://$HOSTNAME.$_SANDBOX_ID.instruqt.io/api/controller"
# # echo $CONTROLLER_URL

# # # Colors for robot-like appearance
# # GREEN='\033[0;32m'
# # CYAN='\033[0;36m'
# # RED='\033[0;31m'
# # RESET='\033[0m'

# # # # Check if CONTROLLER_URL is set
# # if [ -z "$CONTROLLER_URL" ]; then
# #     echo -e "${RED}🤖 ERROR: The environment variable CONTROLLER_URL is not set. Please set it before running this script.${RESET}"
# #     echo "Example: export CONTROLLER_URL=https://api.example.com"
# #     exit 1
# # fi

# # echo -n -e "${CYAN}🤖 Hello! i am your co-worker simulator S.E.A.N - Please provide your authorization token: ${RESET}"
# # read -s AUTH_TOKEN
# # echo -e "\n${CYAN}🤖 Token received. Preparing to execute commands.${RESET}"

# # # Display the token for debugging purposes
# # echo -e "${GREEN}🤖 The Token you supplied is: ${AUTH_TOKEN}${RESET}"

# # # Display menu
# # function show_menu() {
   
# #     echo -e "${GREEN}"
# #     echo "1. Simulate the faulty Web Change"
# #     echo "2. Reset Web Application Config"
# #     echo "3. Break the network!"
# #     echo "4. Patch in a new device"
# #     echo "5. Exit"
# #     echo -e "${RESET}"
# # }

# # # Perform action based on user choice
# # function perform_action() {
# #     case $1 in
# #         1)
# #             echo -e "${CYAN}🤖 Sending POST request to AAP API...${RESET}"
# #             sleep 5
# #             curl -k -X POST "$CONTROLLER_URL/v2/job_templates/15/launch" -H "Content-Type: application/json" -H "Authorization: Bearer $AUTH_TOKEN" > /dev/null 2>&1 & clear
# #             ;;

# #         2)
# #             echo -e "${CYAN}🤖 Sending POST request to AAP API...${RESET}"
# #             sleep 5
# #             curl -k -X POST "$CONTROLLER_URL/v2/job_templates/14/launch" -H "Content-Type: application/json" -H "Authorization: Bearer $AUTH_TOKEN" > /dev/null 2>&1 & clear
# #             ;;


# #         3)
# #             echo -e "${CYAN}🤖 Sending POST request to AAP API...${RESET}"
# #             sleep 5
# #             curl -k -X POST "$CONTROLLER_URL/v2/job_templates/11/launch" -H "Content-Type: application/json" -H "Authorization: Bearer $AUTH_TOKEN" > /dev/null 2>&1 & clear
# #             ;;

# #         4)
# #             echo -e "${CYAN}🤖 Sending POST request to AAP API...${RESET}"
# #             sleep 5
# #             curl -k -X POST "$CONTROLLER_URL/v2/job_templates/13/launch" -H "Content-Type: application/json" -H "Authorization: Bearer $AUTH_TOKEN" > /dev/null 2>&1 & clear
# #             ;;

# #         5)
# #             echo -e "${RED}🤖 Shutting down... Goodbye, Co-Worker!${RESET}"
# #             exit 0
# #             ;;
# #         *)
# #             echo -e "${RED}🤖 Invalid choice. Please select a valid option.${RESET}"
# #             ;;
# #     esac
# # }

# # # Main loop
# # while true; do
# #     show_menu
# #     echo -n -e "${CYAN}🤖 What would you like me to do? Enter your choice: ${RESET}"
# #     read choice
# #     perform_action $choice
# #     echo -e "${CYAN}🤖 Task complete!${RESET}"
# #     echo ""
# # done
