#!/bin/bash
#
#-----------------------------------------------------------------------
# notifications.sh - Send notifications to Telegram and Slack
# Version: 1.0
# Author: Rajesh Prashanth Anandavadivel
# Email: rajeshprasanth@rediffmail.com
#-----------------------------------------------------------------------

VERSION="1.0"
LOGFILE="/tmp/notification.log"
# Load environment variables from .env if it exists

usage() {
    cat << EOF
notifications.sh - Send notification messages to Telegram and Slack

Usage: $0 ENV MESSAGE

ENV must be one of:
  dev       Send message to development Telegram chat and Slack webhook (default)
  prod      Send message to production Telegram chat and Slack webhook

MESSAGE
  The notification message text to send. It can contain multiple words and should be quoted.

Options:
  -h, --help    Display this help and exit
  -v, --version Output version information and exit

Environment variables:
  TELEGRAM_TOKEN           Telegram Bot API token (loaded from .env or env)
  DEV_TELEGRAM_CHAT_ID     Telegram chat ID for development (loaded from .env or env)
  PROD_TELEGRAM_CHAT_ID    Telegram chat ID for production (loaded from .env or env)
  DEV_SLACK_WEBHOOK_URL    Slack webhook URL for development (loaded from .env or env)
  PROD_SLACK_WEBHOOK_URL   Slack webhook URL for production (loaded from .env or env)

Examples:
  $0 dev "Deployment completed successfully"
  $0 prod "Alert: Service down on production server"

Exit status:
  0   if messages are sent successfully (note: logs status, no exit code on failures)
  1   if invalid arguments or no message is provided

Report bugs to: rajeshprasanth@rediffmail.com
EOF
}

version() {
    echo "notifications.sh version $VERSION"
}

log_message() {
    local MESSAGE="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $MESSAGE" >> "$LOGFILE"
}

# Handle help/version flags
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    usage
    exit 0
elif [[ "$1" == "--version" || "$1" == "-v" ]]; then
    version
    exit 0
fi

# Validate input arguments
if [ "$#" -lt 2 ]; then
    echo "Error: Insufficient arguments."
    usage
    exit 1
fi

ENV="$1"
shift
MESSAGE="$*"

if [[ "$ENV" != "dev" && "$ENV" != "prod" ]]; then
    echo "Error: ENV must be 'dev' or 'prod'."
    usage
    exit 1
fi

echo "$(date +'%Y-%m-%d %H:%M:%S') - -----NOTIFICATION BEGIN-----" >> "$LOGFILE"

echo "$(date +'%Y-%m-%d %H:%M:%S') - Searching for .env file." >> "$LOGFILE"

if [ -f .env ]; then
    # shellcheck disable=SC1091

    echo "$(date +'%Y-%m-%d %H:%M:%S') - .env file found." >> "$LOGFILE"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Loading .env file." >> "$LOGFILE"
    source .env
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Loading completed." >> "$LOGFILE"
else
    echo "$(date +'%Y-%m-%d %H:%M:%S') - .env file not found." >> "$LOGFILE"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Terminating the script !!" >> "$LOGFILE"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - -----NOTIFICATION END-----" >> "$LOGFILE"
    exit 1
fi

if [ "$ENV" == "prod" ]; then
    TELEGRAM_CHAT_ID="$PROD_TELEGRAM_CHAT_ID"
    SLACK_WEBHOOK_URL="$PROD_SLACK_WEBHOOK_URL"
else
    TELEGRAM_CHAT_ID="$DEV_TELEGRAM_CHAT_ID"
    SLACK_WEBHOOK_URL="$DEV_SLACK_WEBHOOK_URL"
fi


notify_telegram() {
    log_message "Telegram: Notification POST started"
    output=$(curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -w "%{http_code}" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="$MESSAGE")
    http_status="${output: -3}"
    output="${output::-3}"
    log_message "Telegram: $output"
    if [[ "$http_status" -eq 200 ]]; then
        log_message "Telegram: Request succeeded - HTTP Status $http_status"
    else
        log_message "Telegram: Request failed - HTTP Status $http_status"
    fi
    log_message "Telegram: Notification POST completed"
}

notify_slack() {
    log_message "Slack: Notification POST started"
    escaped_message=$(echo "$MESSAGE" | jq -R .)
    payload="{\"text\": $escaped_message}"

    output=$(curl -s -w "%{http_code}" -X POST -H 'Content-type: application/json' \
        --data "$payload" "$SLACK_WEBHOOK_URL")
    http_status="${output: -3}"
    output="${output::-3}"
    log_message "Slack: $output"
    if [[ "$http_status" -eq 200 ]]; then
        log_message "Slack: Request succeeded - HTTP Status $http_status"
    else
        log_message "Slack: Request failed - HTTP Status $http_status"
    fi
    log_message "Slack: Notification POST completed"
}

# Run notifications
notify_telegram
notify_slack
echo "$(date +'%Y-%m-%d %H:%M:%S') - -----NOTIFICATION END-----" >> "$LOGFILE"
exit 0
