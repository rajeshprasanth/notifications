# Notification Script (Telegram & Slack)

This Bash script sends notifications to **Telegram** and **Slack** based on the provided environment (`dev` or `prod`). It's useful for CI/CD pipelines, monitoring alerts, or system events.

> ⚠️ **Sensitive information (tokens/webhooks) are no longer hardcoded.** It's recommended to use environment variables or secret management in production.

---

## Features

- Sends custom messages to both:
  - Telegram Bot (Dev or Prod Chat ID)
  - Slack Webhook (Dev or Prod Channel)
- Logs all actions and responses to `/tmp/notification.log`
- Minimal dependencies (`curl`, `jq`)

---

## Usage

```bash
./notifications.sh [ENV] [MESSAGE]
````

### Example:

```bash
./notifications.sh dev "Build completed successfully!"
./notifications.sh prod "🚨 Deployment failed on production!"
```

> `ENV` should be either `dev` or `prod`. Any other value defaults to `dev`.

---

## Requirements

* `curl`
* `jq` (for JSON escaping in Slack)

### Install on Ubuntu/Debian:

```bash
sudo apt update && sudo apt install -y curl jq
```

### Install on RHEL/Fedora:

```bash
sudo dnf install -y curl jq
```

---

## Environment Variables (Recommended)

For security and flexibility, **do not hardcode** tokens or webhook URLs inside the script. Use environment variables or a `.env` file to provide them.

### Supported Variables

| Variable                 | Description                       |
| ------------------------ | --------------------------------- |
| `TELEGRAM_TOKEN`         | Telegram Bot API token            |
| `DEV_TELEGRAM_CHAT_ID`   | Telegram chat ID for development  |
| `PROD_TELEGRAM_CHAT_ID`  | Telegram chat ID for production   |
| `DEV_SLACK_WEBHOOK_URL`  | Slack webhook URL for development |
| `PROD_SLACK_WEBHOOK_URL` | Slack webhook URL for production  |

### Set Locally

Export variables in your shell before running the script:

```bash
export TELEGRAM_TOKEN="your_token"
export DEV_TELEGRAM_CHAT_ID="-4686855285"
export PROD_TELEGRAM_CHAT_ID="-4715779362"
export DEV_SLACK_WEBHOOK_URL="https://hooks.slack.com/services/your/dev/url"
export PROD_SLACK_WEBHOOK_URL="https://hooks.slack.com/services/your/prod/url"

./notifications.sh dev "Build completed successfully"
```

### Using a `.env` File

Place the variables in a `.env` file alongside the script:

```bash
TELEGRAM_TOKEN="your_token"
DEV_TELEGRAM_CHAT_ID="-4686855285"
PROD_TELEGRAM_CHAT_ID="-4715779362"
DEV_SLACK_WEBHOOK_URL="https://hooks.slack.com/services/your/dev/url"
PROD_SLACK_WEBHOOK_URL="https://hooks.slack.com/services/your/prod/url"
```

The script will load `.env` automatically if present.

### GitLab CI/CD Integration

Store these as protected masked variables in GitLab CI/CD settings. Use in `.gitlab-ci.yml` like:

```yaml
notify:
  stage: notify
  script:
    - ./notifications.sh prod "✅ Deployment on $CI_ENVIRONMENT_NAME succeeded"
  variables:
    TELEGRAM_TOKEN: "$TELEGRAM_TOKEN"
    PROD_TELEGRAM_CHAT_ID: "$PROD_TELEGRAM_CHAT_ID"
    PROD_SLACK_WEBHOOK_URL: "$PROD_SLACK_WEBHOOK_URL"
```

---

## Log Output

Logs are saved at:

```
/tmp/notification.log
```

Example:

```
2025-07-20 22:35:12 - Telegram: Notification POST started
2025-07-20 22:35:12 - Telegram: Request succeeded - HTTP Status 200
```

---

## Security Warning

Do **not** store sensitive tokens or webhook URLs directly in the script.

---

## License

Licensed under the [GNU GPLv3 License](https://www.gnu.org/licenses/gpl-3.0.html).

---

## Author

Rajesh Prashanth Anandavadivel
📧 [rajeshprasanth@rediffmail.com](mailto:rajeshprasanth@rediffmail.com)
