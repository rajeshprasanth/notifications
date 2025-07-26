#!/bin/bash
#
#-----------------------------------------------------------------------
# Setup for Telegram
#------------------------------------------------------------------------
export TELEGRAM_TOKEN="8058519179:AAHNEzcL_VgnJlJEtSORpNZoJN1onpSI0sc"
# Direct Message
#TELEGRAM_CHAT_ID="6530269766"
# Group chat Message (Development)
export TELEGRAM_CHAT_ID="-4533856645"
# Group chat Message (Production)
#export TELEGRAM_CHAT_ID="-4521800817"
#
LOGFILE="/tmp/notification.log"

# Function to log messages
log_message() {
    local MESSAGE="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $MESSAGE" >> "$LOGFILE"
}

# Usage function to display help
usage() {
    echo "Usage: $0 [OPTIONS] MESSAGE"
    echo
    echo "Send a message to a Telegram bot."
    echo
    echo "Options:"
    echo "  -h, --help        Display this help message and exit"
    echo
    echo "MESSAGE should be the message you want to send."
}

# Check if no arguments were provided
if [ "$#" -eq 0 ]; then
    echo "Error: No message provided."
    usage
    exit 1
fi

# Parse command-line options
while [[ "$1" == -* ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Error: Invalid option '$1'"
            usage
            exit 1
            ;;
    esac
    shift
done

# The remaining argument is the message
export MESSAGE="$*"

# Send the message using curl
notify_telegram () {
log_message "Telegram: Notification POST started"

output=$(curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
    -w "%{http_code}" \
    -d chat_id="$TELEGRAM_CHAT_ID" \
    -d text="$MESSAGE")
http_status="${output: -3}"  # Get the last 3 characters as HTTP status
output="${output::-3}"        # Get everything except the last 3 characters

log_message "Telegram: $output"
# Check the HTTP status code
if [[ "$http_status" -eq 200 ]]; then
    log_message "Telegram: Request succeeded - HTTP Status $http_status"
elif [[ "$http_status" -eq 404 ]]; then
    log_message "Telegram: Not Found - HTTP Status $http_status"
else
    log_message "Telegram: Request failed - HTTP Status $http_status"
fi
log_message "Telegram: Notification POST completed"

}

notify_slack () {
WEBHOOK_URL="https://hooks.slack.com/services/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"


log_message "Slack: Notification POST started"

# Send the message using curl
output=$(curl -s -w "%{http_code}" -X POST -H 'Content-type: application/json' --data "{\"text\":\"$MESSAGE\"}" "$WEBHOOK_URL")
http_status="${output: -3}"  # Get the last 3 characters as HTTP status
output="${output::-3}"        # Get everything except the last 3 characters

log_message "Slack: $output"
# Check the HTTP status code
if [[ "$http_status" -eq 200 ]]; then
    log_message "Slack: Request succeeded - HTTP Status $http_status"
elif [[ "$http_status" -eq 404 ]]; then
    log_message "Slack: Not Found - HTTP Status $http_status"
else
    log_message "Slack: Request failed - HTTP Status $http_status"
fi
log_message "Slack: Notification POST completed"

}

notify_telegram
notify_slack
