#!/bin/bash

# Ask for the target URL
echo "Please enter the target URL:"
read target_url

# Ask for the IO Designer password
echo "Please enter the IO Designer password:"
read -s io_designer_password

# Define the list of services to call
services=("purgelogs" "purgejobs" "purgesupervisions" "purgerecyclebin" "purgeexports" "purgetempfiles")

# Loop through each service and make the curl request
for service in "${services[@]}"; do
    echo "Calling service: $service"
    curl -u designer:"$io_designer_password" --form service=$service "$target_url/io"
    echo # Print a newline for readability
done
