#!/bin/bash

########################################
# File to store the token
TOKEN_FILE="auth_token.txt"
export CONTROLLER_URL="https://$HOSTNAME/api/controller"
echo $CONTROLLER_URL

# Colors for robot-like appearance
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RESET='\033[0m'

# Check if CONTROLLER_URL is set
if [ -z "$CONTROLLER_URL" ]; then
    echo -e "${RED}🤖 ERROR: The environment variable CONTROLLER_URL is not set. Please set it before running this script.${RESET}"
    echo "Example: export CONTROLLER_URL=https://api.example.com"
    exit 1
fi

# Clear token function - removes the token file
function clear_token() {
    if [ -f "$TOKEN_FILE" ]; then
        rm "$TOKEN_FILE"
        echo -e "${CYAN}🤖 Token file cleared successfully.${RESET}"
    else
        echo -e "${RED}🤖 No token file found to clear.${RESET}"
    fi
}

# Clear token and restart script
function clear_token_and_restart() {
    clear_token
    echo -e "${CYAN}🤖 Restarting script...${RESET}"
    sleep 2
    exec "$0" "$@"
}

# Prompt for the token and confirm it
function get_auth_token() {
    while true; do
        echo -n -e "${CYAN}🤖 Hello! I am your co-worker simulator S.E.A.N v4 - Please provide your authorization token: ${RESET}"
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

# Check if the token file exists
if [ -f "$TOKEN_FILE" ]; then
    # Load the token from the file
    AUTH_TOKEN=$(<"$TOKEN_FILE")
    echo -e "${CYAN}🤖 Token loaded from file.${RESET}"
else
    # Prompt for a new token
    get_auth_token
fi

# Display menu
function show_menu() {
    echo -e "${GREEN}"
    echo "1. Simulate the faulty Web Change - (Break Web-Application template)"
    echo "2. Reset Web Application Config - (Restore Web-Application template)"
    echo "3. Break the network! - (Disable Port template)"
    echo "4. Patch in a new device - (Make Port Active template)"
    echo "5. Clear stored token"
    echo "6. Clear token and restart script"
    echo "7. Exit"
    echo -e "${RESET}"
}

# Perform action based on user choice
function perform_action() {
    case $1 in
        1)
            echo -e "${CYAN}🤖 Sending POST request to AAP API...${RESET}"
            sleep 5
            curl -k -X POST "$CONTROLLER_URL/v2/job_templates/15/launch" -H "Content-Type: application/json" -H "Authorization: Bearer $AUTH_TOKEN" > /dev/null 2>&1 & clear
            ;;
        2)
            echo -e "${CYAN}🤖 Sending POST request to AAP API...${RESET}"
            sleep 5
            curl -k -X POST "$CONTROLLER_URL/v2/job_templates/14/launch" -H "Content-Type: application/json" -H "Authorization: Bearer $AUTH_TOKEN" > /dev/null 2>&1 & clear
            ;;
        3)
            echo -e "${CYAN}🤖 Sending POST request to AAP API...${RESET}"
            sleep 5
            curl -k -X POST "$CONTROLLER_URL/v2/job_templates/11/launch" -H "Content-Type: application/json" -H "Authorization: Bearer $AUTH_TOKEN" > /dev/null 2>&1 & clear
            ;;
        4)
            echo -e "${CYAN}🤖 Sending POST request to AAP API...${RESET}"
            sleep 5
            curl -k -X POST "$CONTROLLER_URL/v2/job_templates/13/launch" -H "Content-Type: application/json" -H "Authorization: Bearer $AUTH_TOKEN" > /dev/null 2>&1 & clear
            ;;
        5)
            clear_token
            ;;
        6)
            clear_token_and_restart
            ;;
        7)
            echo -e "${RED}🤖 Shutting down... Goodbye, Co-Worker!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}🤖 Invalid choice. Please select a valid option.${RESET}"
            ;;
    esac
}

# Main loop
while true; do
    show_menu
    echo -n -e "${CYAN}🤖 What would you like me to do? Enter your choice: ${RESET}"
    read choice
    perform_action $choice
    echo -e "${CYAN}🤖 Task complete!${RESET}"
    echo ""
done
