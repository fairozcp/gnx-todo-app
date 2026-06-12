#!/bin/bash

NAMESPACE=$1
WARNING=0

if [ -z "$NAMESPACE" ]; then
  echo "Usage: ./health-check.sh <namespace>"
  exit 1
fi

echo "Checking pods in namespace: $NAMESPACE"
echo "------------------------------------------"
printf "%-40s %-12s %-8s\n" "POD" "STATUS" "RESTARTS"

while read -r POD READY STATUS RESTARTS AGE; do
  printf "%-40s %-12s %-8s\n" "$POD" "$STATUS" "$RESTARTS"

  if [ "$RESTARTS" -gt 3 ]; then
    echo "WARNING: $POD has restarted $RESTARTS times"
    WARNING=1
  fi
done < <(kubectl get pods -n "$NAMESPACE" --no-headers)

echo "------------------------------------------"

if [ "$WARNING" -eq 1 ]; then
  echo "Warnings found."
  exit 1
else
  echo "All pods healthy."
  exit 0
fi