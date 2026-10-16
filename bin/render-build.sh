#!/usr/bin/env bash

set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Render's free plan does not support a separate pre-deploy command.
bundle exec rails db:migrate
