#!/bin/bash

SUBSCRIPTION_TYPE=pubsub
SCHEDULER_JOB_NAME=bleckmann-stock-sync-trigger-pubsub
SCHEDULE="*/5 * * * *"
TARGET=bleckmann-inventory-pubsub-trigger
MESSAGE_BODY="{}"
PROJECT_ID=allsaints-cloud-dev
LOCATION=europe-west3

# Check if all required parameters are set & not empty
if [[ -z "${SUBSCRIPTION_TYPE}" ]]; then
    echo ">>> (Infra) | Critical: <subscription-type> one of: (http|pubsub) parameter is not set! Aborting..."
    exit 1
elif [[ -z "${SCHEDULER_JOB_NAME}" ]]; then
    echo ">>> (Infra) | Critical: <scheduler-job-name> parameter is not set! Aborting..."
    exit 1
elif [[ -z "${SCHEDULE}" ]]; then
    echo ">>> (Infra) | Critical: <schedule> parameter is not set! Aborting..."
    exit 1
elif [[ -z "${TARGET}" ]]; then
    echo ">>> (Infra) | Critical: <target> parameter is not set! Aborting..."
    exit 1
elif [[ -z "${PROJECT_ID}" ]]; then
    echo ">>> (Infra) | Critical: <project-id> parameter is not set! Aborting..."
    exit 1
elif [[ -z "${SUBSCRIPTION_TYPE}" ]]; then
    echo ">>> (Infra) | Critical: <subscription-type> parameter is not set! Aborting..."
    exit 1
elif [[ -z "${LOCATION}" ]]; then
    echo ">>> (Infra) | Critical: <location> parameter is not set! Aborting..."
    exit 1
fi

RESULT=$(
    gcloud scheduler jobs describe \
        --project=$PROJECT_ID \
        --location=$LOCATION \
        --filter="name.scope(jobs)=$SCHEDULER_JOB_NAME" \
        --format="value(name)" 2>/dev/null
)

if [[ "${RESULT}" == "" ]]; then
    if [[ "${SUBSCRIPTION_TYPE}" == "http" ]]; then
        echo ">>> (Infra) | Creating <$SCHEDULER_JOB_NAME> scheduler of type http for <$TARGET> URI..."
        gcloud scheduler jobs create http $SCHEDULER_JOB_NAME \
            --project=$PROJECT_ID \
            --location=$LOCATION \
            --schedule="$SCHEDULE" \
            --uri="$TARGET" \
            --http-method=GET
    elif [[ "${SUBSCRIPTION_TYPE}" == "pubsub" ]]; then
        echo ">>> (Infra) | Creating <$SCHEDULER_JOB_NAME> scheduler of type pubsub for <$TARGET> topic name..."

        if [[ -z "${MESSAGE_BODY}" ]]; then
            echo ">>> (Infra) | Critical: <message-body> parameter is not setm but it's required for pubsub subscription! Aborting..."
            exit 1
        fi
        gcloud scheduler jobs create pubsub $SCHEDULER_JOB_NAME \
            --project=$PROJECT_ID \
            --location=$LOCATION \
            --schedule="$SCHEDULE" \
            --topic=$TARGET \
            --message-body="$MESSAGE_BODY"
    else
        echo ">>> (Infra) | Critical: invalid scheduler type provided $SUBSCRIPTION_TYPE! Aborting..."
        exit 1
    fi
else
    echo ">>> (Infra) | Scheduler <$SCHEDULER_JOB_NAME> already exists in the <$PROJECT_ID> project. Skipping..."
fi
