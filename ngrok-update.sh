HOST=https://cameras1.seucondominio.com.br

# sc-camera-1 (sctunnel rodando na empresa)
STREAM_ID=8833a42a-b5d0-42dc-a1ea-e5d6fb3a11e5
# DEV
# STREAM_ID=1_development

# LOCAL CAMERA ACCESS
CAMERA_USER=admin
CAMERA_USER_PASS=Abc12345
CAMERA_ADRESS_IP=192.168.1.140
CAMERA_ADRESS_PORTA=554
CAMERA_CHANNEL=1

function get_current_url {
  current_url=$(ngrok api tunnels list)
  current_url=$(echo $current_url | jq '.tunnels[0].public_url' | tr -d '"' | sed -e "s/tcp:[/][/]//")
  current_url="rtsp://$CAMERA_USER:$CAMERA_USER_PASS@$current_url/cam/realmonitor?channel=$CAMERA_CHANNEL&subtype=1"

  echo $current_url
}

function get_current_stream_obj {
  current_str_obj=$(curl --request GET $HOST/stream/$STREAM_ID/info)
  current_str_obj=$(echo $current_str_obj | jq '.payload.channels[]')

  echo $current_str_obj
}

current_stream_obj=$(get_current_stream_obj)

current_url=$(get_current_url)
current_stream_url=$(echo $current_stream_obj | jq '.url' | tr -d '"')

if [[ "$current_url" != "$current_stream_url" ]]
then
  # Destruindo serviços antigos
  killall ngrok

  # Ligando ngrok em background
  ngrok tcp $CAMERA_ADRESS_IP:$CAMERA_ADRESS_PORTA > /dev/null &
else
  echo 'Já atualizado'
  exit 1
fi

current_url=$(get_current_url)

# Buscando a URL pública criada no comando anterior
echo "atualiznado url para $current_url"

current_stream_name=$(echo $current_stream_obj | jq '.name')

# Atualizando a stream da Câmera atual
json_data="{\"uuid\":\"$STREAM_ID\",\"name\":$current_stream_name,\"channels\":{\"0\":{\"url\":\"$current_url\",\"on_demand\":true,\"debug\":false}}}"

curl --header "Content-Type: application/json" \
  --request POST \
  --data $json_data \
  $HOST/stream/$STREAM_ID/edit

# Avisando que deu tudo certo
echo 'OK'
