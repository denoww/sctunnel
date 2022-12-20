params=$1
config=$(jq -r '.sc_stream_server' "config.json")

function get_config {
  echo $config | jq '.'$1'' | tr -d '"'
}

function get_params {
  echo $params | jq '.'$1'' | tr -d '"'
}

HOST=$(get_config "host")

STREAM_ID=$(get_params "stream_id")
STREAM_CHANNEL_ID=$(get_params "id")
STREAM_CAMERA_URL=$(get_params "url")

# LOCAL CAMERA ACCESS

echo ''
echo "Configurando Stream $STREAM_ID channel $STREAM_CHANNEL_ID ($HOST)"
echo "Câmera url $STREAM_CAMERA_URL"
echo ''

function mount_current_url {
  current_url=$(echo $1 | jq '.public_url' | tr -d '"' | sed -e "s/tcp:[/][/]//")
  current_url="rtsp://$CAMERA_USER:$CAMERA_USER_PASS@$current_url/cam/realmonitor?channel=$CAMERA_CHANNEL&subtype=1"

  echo $current_url
}

function get_current_stream_obj {
  current_str_obj=$(curl -s --request GET $HOST/stream/$STREAM_ID/channel/$STREAM_CHANNEL_ID/info )

  echo $current_str_obj
}

current_stream_obj=$(get_current_stream_obj)

current_stream_url=$(echo $current_stream_obj | jq '.payload.url?' | tr -d '"')

if [[ "$STREAM_CAMERA_URL" == "$current_stream_url" ]]
then
  echo 'Já atualizado'
  exit 1
fi

# Atualizando a stream da Câmera atual
json_data="{\"url\":\"$STREAM_CAMERA_URL\",\"on_demand\":true,\"debug\":false}"

if [[ -n "$current_stream_url" ]]
then
  POST_URL=$HOST/stream/$STREAM_ID/channel/$STREAM_CHANNEL_ID/edit
  info_text="Atualizando"
else
  POST_URL=$HOST/stream/$STREAM_ID/channel/$STREAM_CHANNEL_ID/add
  info_text="Adicionando"
fi

echo "$info_text url para $STREAM_CAMERA_URL"

curl -s --header "Content-Type: application/json" \
  --request POST \
  --data $json_data \
  $POST_URL

# Avisando que deu tudo certo
echo ''
echo 'OK'
