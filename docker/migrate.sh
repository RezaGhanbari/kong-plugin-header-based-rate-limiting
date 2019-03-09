#!/usr/bin/env bash

./wait-for-it.sh kong-database:9042 -t 0

kong migrations up