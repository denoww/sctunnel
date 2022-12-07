# sctunnel

TODOS OS DADOS são para testes. Num futuro não muito distante, iremos usar configurações para do condomínio (buscar câmeras dentro do condominio e sempre fazer a atualização)

## Configurando rotina para atualizar a câmera no cameras1.seucondominio

Execute:

$ crontab -e

adicione os 2 comandos:

`*/1 * * * * /usr/bin/sudo -u <USER_NAME> /bin/bash -lc 'bash /<PATH_TO_SH_FILE>/ngrok-update.sh > /<PATH_TO_SH_FILE>/ngrok-update-logs.txt'`

`@reboot /usr/bin/sudo -u <USER_NAME> /bin/bash -lc 'bash /<PATH_TO_SH_FILE>/ngrok-update.sh > /<PATH_TO_SH_FILE>/ngrok-update-logs.txt'`
