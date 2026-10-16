#!/usr/bin/env bash

set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Render's free plan does not support a separate pre-deploy command.
bundle exec rails db:migrate

# Seeds are idempotent: they keep converters current and create the initial
# administrator when it does not exist. This must run on every deploy because
# Render's initialDeployHook only runs once per service.
bundle exec rails db:seed
