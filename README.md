# Laboratorio DevSecOps: monitoreo y pipeline

Actividad con una app de ejemplo, Prometheus, Grafana, Elasticsearch, Logstash y Kibana.

## Empezar

1. Descomprime el ZIP que te entregó el docente.
2. Crea un repositorio vacío en [GitHub](https://github.com/new), sin añadir README, .gitignore ni licencia.
3. En la carpeta descomprimida, ejecuta `git init -b main`, `git add .` y `git commit -m "Inicio del laboratorio"`.
4. Copia desde GitHub el comando `git remote add origin ...` de tu repositorio y ejecuta `git push -u origin main`.
5. Con Docker Desktop abierto, haz doble clic en **INICIAR-AQUI.cmd** y abre [la guía interactiva](guia-monitoreo-interactiva.html).

El iniciador crea las contraseñas en `secrets/` y las muestra en su ventana. Esa carpeta se excluye de Git; no la publiques.

La parte **Jenkins con GitHub** es opcional. Al llegar allí, pulsa el botón de la guía si quieres continuar. Haz doble clic en **INICIAR-JENKINS.cmd**: Jenkins se inicia en el mismo Docker Compose y usa el `Jenkinsfile` de **tu repositorio**. No necesita acceso al motor Docker.

Más ayuda: [LEEME.txt](LEEME.txt).
