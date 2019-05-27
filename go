#!/usr/bin/env bash

[ -n "$GO_DEBUG" ] && set -x
set -e

project_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

verbose="no"
skip_checks="no"
skip_pre_flight="no"
skip_cloud_credentials="no"
offline="no"

missing_dependency="no"

[ -n "$GO_DEBUG" ] && verbose="yes"
[ -n "$GO_SKIP_CHECKS" ] && skip_checks="yes"
[ -n "$GO_SKIP_PRE_FLIGHT" ] && skip_pre_flight="yes"
[ -n "$GO_SKIP_CLOUD_CREDENTIALS" ] && skip_cloud_credentials="yes"
[ -n "$GO_OFFLINE" ] && offline="yes"


if [[ "$skip_checks" = "no" ]]; then
    echo "Checking for system dependencies."
    ruby_version="$(cat "$project_dir"/.ruby-version)"
    if ! type ruby >/dev/null 2>&1 || ! ruby -v | grep -q "$ruby_version"; then
        echo "This codebase requires Ruby $ruby_version."
        missing_dependency="yes"
    fi

    if [[ "$missing_dependency" = "yes" ]]; then
        echo "Please install missing dependencies to continue."
        exit 1
    fi

    echo "All system dependencies present. Continuing."
fi

if [[ "$skip_pre_flight" = "no" ]]; then
    echo "Installing git hooks."
    set +e && rm .git/hooks/prepare-commit-msg >/dev/null 2>&1 && set -e
    cp scripts/git/prepare-commit-msg .git/hooks/
    chmod +x .git/hooks/prepare-commit-msg

    if [[ "$skip_cloud_credentials" = "no" ]]; then
        echo "Sourcing cloud credentials."
        if grep -q true config/secrets/.unlocked; then
          source config/secrets/aws/tobyclemsons-account.sh
        fi
    fi

    if [[ "$offline" = "no" ]]; then
        echo "Installing bundler."
        if [[ "$verbose" = "yes" ]]; then
            gem install --no-document bundler
        else
            gem install --no-document bundler > /dev/null
        fi

        echo "Installing ruby dependencies."
        if [[ "$verbose" = "yes" ]]; then
            bundle install
        else
            bundle install > /dev/null
        fi
    fi
fi

echo "Starting rake."
if [[ "$verbose" = "yes" ]]; then
    time bundle exec rake --verbose "$@"
else
    time bundle exec rake "$@"
fi
