#!/usr/bin/env bash

sensors | awk '
    /Package id 0:/ {
        print $4
        found = 1
        exit
    }
    END {
        if (!found) {
            print "N/A"
        }
    }
'
