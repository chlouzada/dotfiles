{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    jq

    (pkgs.writeShellScriptBin "ask" ''
      #!/bin/bash

      TOKEN_FILE="$HOME/.config/ask"

      # Ensure the cfg file exists and contains a token
      if [ ! -f "$TOKEN_FILE" ]; then
        touch "$TOKEN_FILE"
      fi

      token=$(< "$TOKEN_FILE")
      if [ -z "$token" ]; then
        read -p "No token found, provide one: " token
        echo "$token" > "$TOKEN_FILE"
      fi

      get_system_prompt() {
        local input="$1"
        echo "SHELL. Provide only fish commands for Linux without any description. If there is a lack of details, provide the most logical solution. Ensure the output is a valid shell command. If multiple steps are required, try to combine them. Request: $input. Command: "
      }

      system=$(get_system_prompt "$1")
      system_json=$(jq -Rs '.' <<< "$system")

      response=$(curl -X POST "https://api.openai.com/v1/chat/completions" \
        -s \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $token" \
        -d "{
          \"temperature\": 0,
          \"model\": \"gpt-3.5-turbo\",
          \"messages\": [
              {\"role\": \"system\", \"content\": $system_json}
          ]
      }")
        
      cmd=$(jq -r '.choices[0].message.content' <<< "$response")
      echo $cmd
    '')
  ];
}
