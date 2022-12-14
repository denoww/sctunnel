echo ''
echo 'Configurando Câmera'

HOST=https://cameras1.seucondominio.com.br

params=$1

function get_params {
  echo $params | jq '.'$1'' | tr -d '"'
}

STREAM_ID=$(get_params "stream_id")
STREAM_CHANNEL_ID=$(get_params "stream_channel_id")

# LOCAL CAMERA ACCESS
CAMERA_USER=$(get_params "camera_user")
CAMERA_USER_PASS=$(get_params "camera_user_pass")
CAMERA_ADRESS_IP=$(get_params "camera_adress_ip")
CAMERA_ADRESS_PORTA=$(get_params "camera_adress_porta")
CAMERA_CHANNEL=$(get_params "camera_channel")

function get_ngrok_obj {
  resp=$(ngrok api tunnels list | jq '.tunnels[0]')

  echo $resp
}

function mount_current_url {
  current_url=$(echo $1 | jq '.public_url' | tr -d '"' | sed -e "s/tcp:[/][/]//")
  current_url="rtsp://$CAMERA_USER:$CAMERA_USER_PASS@$current_url/cam/realmonitor?channel=$CAMERA_CHANNEL&subtype=1"

  echo $current_url
}

function get_current_stream_obj {
  current_str_obj=$(curl -s --request GET $HOST/stream/$STREAM_ID/channel/$STREAM_CHANNEL_ID/info )

  echo $current_str_obj
}

current_ngrok_obj=$(get_ngrok_obj)
current_stream_obj=$(get_current_stream_obj)

current_url=$(mount_current_url "$current_ngrok_obj")
current_stream_url=$(echo $current_stream_obj | jq '.payload.url?' | tr -d '"')

if [[ "$current_url" != "$current_stream_url" ]]
then
  forwards_to=$(echo $current_ngrok_obj | jq '.forwards_to' | tr -d '"')
  if [[ "$CAMERA_ADRESS_IP:$CAMERA_ADRESS_PORTA" != "$forwards_to" ]]
  then
    # Destruindo serviços antigos
    killall ngrok

    # Ligando ngrok em background
    ngrok tcp $CAMERA_ADRESS_IP:$CAMERA_ADRESS_PORTA > /dev/null &

    current_ngrok_obj=$(get_ngrok_obj)
    current_url=$(mount_current_url "$current_ngrok_obj")
  fi
else
  echo 'Já atualizado'
  exit 1
fi

# Atualizando a stream da Câmera atual
json_data="{\"url\":\"$current_url\",\"on_demand\":true,\"debug\":false}"

if [[ -n "$current_stream_url" ]]
then
  POST_URL=$HOST/stream/$STREAM_ID/channel/$STREAM_CHANNEL_ID/edit
  info_text="Atualizando"
else
  POST_URL=$HOST/stream/$STREAM_ID/channel/$STREAM_CHANNEL_ID/add
  info_text="Adicionando"
fi

echo "$info_text url para $current_url"

curl -s --header "Content-Type: application/json" \
  --request POST \
  --data $json_data \
  $POST_URL

# Avisando que deu tudo certo
echo ''
echo 'OK'
