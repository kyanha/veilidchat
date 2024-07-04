#!/bin/bash
cat "/Users/$USER/Library/Containers/com.veilid.veilidchat/Data/Library/Application Support/com.veilid.veilidchat/VeilidChat.folded" | inferno-flamegraph -c purple --fontsize 8 --height 24 --title "VeilidChat" --factor 0.000000001 --countname secs > /tmp/veilidchat.svg
cat "/Users/$USER/Library/Containers/com.veilid.veilidchat/Data/Library/Application Support/com.veilid.veilidchat/VeilidChat.folded" | inferno-flamegraph --reverse -c aqua --fontsize 8 --height 24 --title "VeilidChat Reverse" --factor 0.000000001 --countname secs > /tmp/veilidchat-reverse.svg
