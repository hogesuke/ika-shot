#!/usr/bin/env bash

cd app/
bundle ex unicorn  -c ../config/unicorn.rb -E production -D
