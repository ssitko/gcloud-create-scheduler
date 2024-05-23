# gcloud create scheduler

This repository contains Github action for creating google _scheduler_ using **gcloud** utility.

# how to use

1. Make sure that **google-github-actions/auth** and **google-github-actions/setup-gcloud** actions are running before this github action in your manifest
2. Add following lines to you github action:

your-gh-manifest.yaml

```
- name: Use gcloud create scheduler action
  uses: ssitko/gcloud-create-scheduler@v0.1
  with:
    project-id: "your-project-id"
    scheduler-name: "your-scheduler-name"
    subscription-type: "http" // Also pubsub is supported
    schedule: "*/5 * * * *"
    target: "https://test-functions.cloudfunctions.net/cf" // Alternatively, if pubsub scheduler type, use topic name instead
    message-body: "{\"some\": \"data\"}" // This is optional and works only for pubsub scheduler type
```

### Szymon Sitko @ 2024
