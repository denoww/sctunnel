jsonData=$(jq -r '' "confi-cameras.json")

data=$(echo $jsonData | jq 'del(.cameras)')

cameras=$(echo $jsonData | jq '.cameras')

echo $cameras | jq -c '.[]' | while read camera; do
  camera_params=$(echo ''$data' '$camera'' | jq -s add)
  bash run-ngrok-update.sh "$camera_params"
done
