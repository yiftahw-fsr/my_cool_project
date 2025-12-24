#!/bin/bash

apt update

runuser -u ubuntu renovate --custom-managers jsonata
