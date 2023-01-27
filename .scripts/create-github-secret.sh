#! /usr/bin/env

# This script creates a GitHub secret named "fly-token" in the specified
# organization and repository. The value of the secret is taken from an
# environment variable named "FLY_TOKEN". If no organization or repository
# is specified, the script will try to determine them from the current
# directory or from the .git folder

# Define default values for organization and repository
org=
repo=

# Parse command line options
while getopts ":o:r:" opt; do
  case $opt in
    o) org="$OPTARG" ;;
    r) repo="$OPTARG" ;;
    \?) echo "Invalid option -$OPTARG" >&2 ;;
  esac
done

# If organization or repository is not specified, try to determine them
# from the current directory or from the .git folder
if [[ -z "$org" || -z "$repo" ]]; then
  if [[ -d ".git" ]]; then
    # Get remote origin URL
    origin_url=$(git remote get-url origin)

    # Extract organization and repository from remote origin URL
    if [[ $origin_url =~ ^https://github.com/([^/]+)/([^.]+)\.git$ ]]; then
      org="${BASH_REMATCH[1]}"
      repo="${BASH_REMATCH[2]}"
    fi
  fi

  # If organization or repository is still not determined, use the current directory
  if [[ -z "$org" || -z "$repo" ]]; then
    org="$USER"
    repo="$(basename $(pwd))"
  fi
fi

# Get the value of the secret from the environment variable "FLY_TOKEN"
secret_value="$FLY_TOKEN"

# Check if the secret value is set
if [[ -z "$secret_value" ]]; then
  echo "Error: environment variable FLY_TOKEN is not set" >&2
  exit 1
fi

# Create the GitHub secret
echo "Creating secret fly-token in $org/$repo with value *****..."
gh secret set fly-token --repo="$repo" --org="$org" --value="$secret_value"
