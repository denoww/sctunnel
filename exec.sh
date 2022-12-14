echo ''
echo '---------------------------------------------------------------------------------'
echo '---------------------------------------------------------------------------------'
echo "Sincronizando equipamentos ($(date))"
echo '---------------------------------------------------------------------------------'
echo '---------------------------------------------------------------------------------'
echo ''

config=$(jq -r '' "config.json")

echo $config | jq -c '.equipamentos[]' | while read equipamento; do
  equipamento_obj=$(echo "$equipamento" | jq 'del(.cameras)')

  cameras=$(echo "$equipamento" | jq '.cameras')

  echo $cameras | jq -c '.[]' | while read camera; do
    camera_params=$(echo ''$equipamento_obj' '$camera'' | jq -s add)
    bash exec-camera.sh "$camera_params"
  done
done

echo ''
echo '---------------------------------------------------------------------------------'
echo 'OK OK OK OK OK OK OK OK OK OK OK OK OK'
echo '---------------------------------------------------------------------------------'
echo ''
