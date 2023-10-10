#!/usr/bin/env bash

rails db:create
rails db:migrate

# this is the command used to start our app's server
bundle exec rails s -b 0.0.0.0