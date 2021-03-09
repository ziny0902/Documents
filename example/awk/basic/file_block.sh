#!/usr/bin/bash
awk 'NR >= 238 && NR <= 244 {print}' test.lua
