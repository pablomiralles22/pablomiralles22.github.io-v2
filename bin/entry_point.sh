#!/bin/bash

CONFIG_FILE=_config.yml 

OPTIONS=""
# OPTIONS="--future --unpublished --draft"

COMMAND="jekyll serve $OPTIONS --watch --port=8080 --host=0.0.0.0 --livereload --verbose --trace --force_polling"

/bin/bash -c "rm -f Gemfile.lock && exec $COMMAND"&

while true; do

  inotifywait -q -e modify,move,create,delete $CONFIG_FILE

  if [ $? -eq 0 ]; then
 
    echo "Change detected to $CONFIG_FILE, restarting Jekyll"

    jekyll_pid=$(pgrep -f jekyll)
    kill -KILL $jekyll_pid

    /bin/bash -c "rm -f Gemfile.lock && exec $COMMAND"&

  fi

done
