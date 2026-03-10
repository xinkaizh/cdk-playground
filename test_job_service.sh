#!/usr/bin/env bash

set -euo pipefail

error() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || error "Required command not found: $1"
}

require_cmd curl
require_cmd jq

if [[ -z "${API_URL:-}" ]]; then
  error "API_URL is not set. Example: export API_URL='https://abcd1234.execute-api.us-west-2.amazonaws.com/prod/'"
fi

API_URL="${API_URL%/}"
TITLE="${TITLE:-hello}"
CONTENT="${CONTENT:-this is a test payload}"
MAX_POLLS="${MAX_POLLS:-20}"
SLEEP_SECONDS="${SLEEP_SECONDS:-2}"

echo "Using API_URL=$API_URL"
echo "Creating job..."

CREATE_RESPONSE="$(
  curl -sS -f -X POST "$API_URL/jobs" \
    -H "Content-Type: application/json" \
    -d "$(jq -nc --arg title "$TITLE" --arg content "$CONTENT" '{title:$title, content:$content}')"
)" || error "POST /jobs failed"

echo "Create response:"
echo "$CREATE_RESPONSE" | jq . || error "Create response is not valid JSON"

JOB_ID="$(echo "$CREATE_RESPONSE" | jq -r '.job_id // empty')"
STATUS="$(echo "$CREATE_RESPONSE" | jq -r '.status // empty')"

[[ -n "$JOB_ID" ]] || error "Missing job_id in create response"
[[ "$STATUS" == "PENDING" ]] || error "Expected initial status PENDING, got: $STATUS"

echo "Job created successfully: job_id=$JOB_ID"
echo "Polling job status..."

for ((i=1; i<=MAX_POLLS; i++)); do
  GET_RESPONSE="$(curl -sS -f "$API_URL/jobs/$JOB_ID")" || error "GET /jobs/$JOB_ID failed on attempt $i"

  echo "Poll #$i response:"
  echo "$GET_RESPONSE" | jq . || error "GET response is not valid JSON on attempt $i"

  CURRENT_STATUS="$(echo "$GET_RESPONSE" | jq -r '.status // empty')"
  [[ -n "$CURRENT_STATUS" ]] || error "Missing status in GET response on attempt $i"

  if [[ "$CURRENT_STATUS" == "COMPLETED" ]]; then
    TITLE_UPPER="$(echo "$GET_RESPONSE" | jq -r '.result.title_upper // empty')"
    CONTENT_LENGTH="$(echo "$GET_RESPONSE" | jq -r '.result.content_length // empty')"
    WORD_COUNT="$(echo "$GET_RESPONSE" | jq -r '.result.word_count // empty')"
    PROCESSED_AT="$(echo "$GET_RESPONSE" | jq -r '.result.processed_at // empty')"

    [[ -n "$TITLE_UPPER" ]] || error "Missing result.title_upper in completed response"
    [[ -n "$CONTENT_LENGTH" ]] || error "Missing result.content_length in completed response"
    [[ -n "$WORD_COUNT" ]] || error "Missing result.word_count in completed response"
    [[ -n "$PROCESSED_AT" ]] || error "Missing result.processed_at in completed response"

    echo "Job completed successfully."
    echo "job_id=$JOB_ID"
    echo "title_upper=$TITLE_UPPER"
    echo "content_length=$CONTENT_LENGTH"
    echo "word_count=$WORD_COUNT"
    echo "processed_at=$PROCESSED_AT"
    exit 0
  fi

  if [[ "$CURRENT_STATUS" == "FAILED" ]]; then
    ERROR_MESSAGE="$(echo "$GET_RESPONSE" | jq -r '.error_message // "unknown error"')"
    error "Job entered FAILED state: $ERROR_MESSAGE"
  fi

  if [[ "$CURRENT_STATUS" != "PENDING" ]]; then
    error "Unexpected job status on attempt $i: $CURRENT_STATUS"
  fi

  sleep "$SLEEP_SECONDS"
done

error "Job did not reach COMPLETED within ${MAX_POLLS} polls"