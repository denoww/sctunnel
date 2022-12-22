params=$1

USAR_NGROK=false

function get_config {
  config=$(jq -r '' "config.json")
  echo $config | jq '.'$1''
}

function get_params {
  echo $params | jq '.'$1'' | tr -d '"'
}

HOST=$(get_config "sc_stream_server.host" | tr -d '"')

STREAM_ID=$(get_params "stream_id")
STREAM_CHANNEL_ID=$(get_params "stream_channel_id")

# LOCAL CAMERA ACCESS
CAMERA_USER=$(get_params "camera_user")
CAMERA_USER_PASS=$(get_params "camera_user_pass")
CAMERA_ADRESS_IP=$(get_params "camera_adress_ip")
CAMERA_ADRESS_PORTA=$(get_params "camera_adress_porta")
CAMERA_CHANNEL=$(get_params "camera_channel")

FORWARDS_TO="$CAMERA_ADRESS_IP:$CAMERA_ADRESS_PORTA"

function get_sc_tunnel_obj {
  resp=$(get_config "sc_tunnel[\"$FORWARDS_TO\"]")

  if [[ $resp == null ]]; then
    # Com NGROK
    if [[ $USAR_NGROK == true ]]; then
      echo "com ngrok"
      resp=$(ngrok api tunnels list | jq '.tunnels[0]')
    else
      # Com sctunnel
      public_ip="23.22.12.192"

      pid=$(ps aux | grep "$porta:$FORWARDS_TO ubuntu@$public_ip" | awk '{print $2}')
      $(kill -9 $pid > /dev/null &)

      porta=$(ssh -i "~/portaria_staging_ssh_pem_key.pem" ubuntu@$public_ip 'bash -s' < find_unused_port.sh)
      ssh -N -o ServerAliveInterval=20 -i "~/portaria_staging_ssh_pem_key.pem" -R $porta:$FORWARDS_TO ubuntu@$public_ip > /dev/null &

      public_url="$public_ip:$porta"
      resp="{\"public_url\": \"$public_url\", \"forwards_to\": \"$FORWARDS_TO\"}"
    fi

    # salvando nova configuração
    sc_tunnel=$(get_config "sc_tunnel" | jq '.')

    new_sc_tunnel=$(echo "{}" | jq --arg key "$FORWARDS_TO" --argjson val "$resp" '.[$key] = $val')
    new_sc_tunnel=$(echo ''$new_sc_tunnel' '$sc_tunnel'' | jq -s add)

    new_config=$(get_config | jq --argjson val "$new_sc_tunnel" '.sc_tunnel = $val')
    echo $new_config | jq '.' > config.json
  fi

  echo $resp
}

function mount_current_url {
  current_url=$(echo $1 | jq '.public_url' | tr -d '"' | sed -e "s/tcp:[/][/]//")

  url_controller=$(get_params "camera_adress_url_controller")
  if [[ url_controller == null ]]; then
    url_controller="cam/realmonitor?channel=$CAMERA_CHANNEL&subtype=1"
  fi

  current_url="rtsp://$CAMERA_USER:$CAMERA_USER_PASS@$current_url/$url_controller"

  echo $current_url
}

function get_current_stream_obj {
  current_str_obj=$(curl -s --request GET $HOST/stream/$STREAM_ID/channel/$STREAM_CHANNEL_ID/info )

  echo $current_str_obj
}

current_tunnel_obj=$(get_sc_tunnel_obj)
current_stream_obj=$(get_current_stream_obj)

current_url=$(mount_current_url "$current_tunnel_obj")
current_stream_url=$(echo $current_stream_obj | jq '.payload.url?' | tr -d '"')

if [[ $USAR_NGROK ]]; then
  if [[ "$current_url" != "$current_stream_url" ]]; then
    forwards_to=$(echo $current_tunnel_obj | jq '.forwards_to' | tr -d '"')
    if [[ "$FORWARDS_TO" != "$forwards_to" ]]
    then
      # Destruindo serviços antigos
      killall ngrok

      # Ligando ngrok em background
      ngrok tcp $FORWARDS_TO > /dev/null &

      current_tunnel_obj=$(get_sc_tunnel_obj)

      current_url=$(mount_current_url "$current_tunnel_obj")
    fi
  fi
fi

echo $current_url
