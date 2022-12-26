# sctunnel

TODOS OS DADOS são para testes. Num futuro não muito distante, iremos usar configurações para do condomínio (buscar câmeras dentro do condominio e sempre fazer a atualização)

## Configurando os equipamentos que deseja processar

Execute:

```
$ cp /<PATH_TO_SH_FILE>/sctunnel/config-sample.json /<PATH_TO_SH_FILE>/sctunnel/config.json
$ chmod 400 /<PATH_TO_SH_FILE>/sctunnel/scTunnel.pem
```

Altere o arquivo config.json conforme sua necessidade

## Configurando rotina para atualizar a câmera no cameras1.seucondominio

Execute:

$ crontab -u $USER -e

Obs.: Caso esse comando não abrir corretamente, tente com sudo

adicione os 2 comandos:

`*/1 * * * * /usr/bin/sudo -u <USER_NAME> /bin/bash -lc 'cd /<PATH_TO_SH_FILE>/sctunnel; bash exec.sh > logs.txt'`

`@reboot /usr/bin/sudo -u <USER_NAME> /bin/bash -lc 'cd /<PATH_TO_SH_FILE>/sctunnel; bash exec.sh > logs.txt'`

