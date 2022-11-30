# sctunnel

TODOS OS DADOS são para testes. Num futuru não muito distante, iremos usar configurações para o condomínio (buscar câmeras dentro do condominio e sempre fazer a atualização)

Configurando rotina para atualizar a câmera no cameras1.seucondominio

crontab -e

adicione os 2 comandos:

*/1 * * * * /usr/bin/sudo -u <USER_NANE> /bin/bash -lc 'bash /home/<USER_NANE>/ngrok-update.sh > /home/<USER_NANE>/ngrok-update-logs.txt'
@reboot /usr/bin/sudo -u <USER_NANE> /bin/bash -lc 'bash /home/<USER_NANE>/ngrok-update.sh > /home/<USER_NANE>/ngrok-update-logs.txt'

