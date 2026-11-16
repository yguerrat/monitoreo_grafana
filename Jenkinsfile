// Jenkins lee el repositorio del alumno y publica un cambio visible en la app.
// Todo ocurre dentro de Docker; no se monta el socket del motor Docker.
pipeline {
    agent any
    options { skipDefaultCheckout() }

    stages {
        stage('1. Descargar de GitHub') {
            steps {
                checkout scm
                sh 'git log -1 --format="%h %s"'
            }
        }

        stage('2. Validar cambio') {
            steps {
                sh '''
                    test -s app/home.txt
                    test "$(wc -c < app/home.txt)" -le 500
                    python3 -m py_compile app/app.py
                '''
            }
        }

        stage('3. Publicar en la app') {
            steps {
                sh '''
                    cp app/home.txt /release/home.txt.tmp
                    chmod 644 /release/home.txt.tmp
                    mv -f /release/home.txt.tmp /release/home.txt
                '''
            }
        }

        stage('4. Verificar monitoreo') {
            steps {
                sh 'python3 jenkins/verificar.py monitoreo'
            }
        }

        stage('5. Verificar seguridad') {
            steps {
                sh 'python3 jenkins/verificar.py seguridad'
            }
        }
    }
}
