function get_current_url {
  current_url=$(ngrok api tunnels list --api-key 2IGZTAcQVxAvTnOqdZsyL4t8xjw_44GsYaB3wkjBCVbhnMfrY)
  current_url=$(echo $current_url | jq '.tunnels[0].public_url' | tr -d '"' | sed -e "s/tcp:[/][/]//")
  current_url="rtsp://admin:Abc12345@$current_url/cam/realmonitor?channel=1&subtype=1"

  echo $current_url
}

function get_current_stream_url {
  current_str_url=$(curl --request GET https://cameras1.seucondominio.com.br/stream/8833a42a-b5d0-42dc-a1ea-e5d6fb3a11e5/info)
  current_str_url=$(echo $current_str_url | jq '.payload.channels[].url' | tr -d '"')

  echo $current_str_url
}

current_url=$(get_current_url)
current_stream_url=$(get_current_stream_url)

if [[ "$current_url" != "$current_stream_url" ]]
then
  # Destruindo serviços antigos
  killall ngrok

  # Ligando ngrok em background
  ngrok tcp 192.168.1.140:554 > /dev/null &
else
  echo 'Já atualizado'
  exit 1
fi

current_url=$(get_current_url)

# Buscando a URL pública criada no comando anterior
echo "atualiznado url para $current_url"

# Atualizando a stream da Câmera atual
json_data="{\"uuid\":\"8833a42a-b5d0-42dc-a1ea-e5d6fb3a11e5\",\"name\":\"sc-camera-1\",\"channels\":{\"0\":{\"url\":\"$current_url\",\"on_demand\":true,\"debug\":false}}}"

curl --header "Content-Type: application/json" \
  --request POST \
  --data $json_data \
  https://cameras1.seucondominio.com.br/stream/8833a42a-b5d0-42dc-a1ea-e5d6fb3a11e5/edit

# Avisando que deu tudo certo
echo 'OK'
