# Construye la app Flask con Python y sus dos bibliotecas.
FROM python:3.12-slim
WORKDIR /app
# Instala dependencias antes de copiar el código para aprovechar la caché.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
COPY home.txt .

# Ejecuta la aplicación sin privilegios de administrador.
RUN groupadd --gid 10001 app && useradd --uid 10001 --gid app --no-create-home app
USER 10001:10001

# La app escucha en el puerto 8000 al iniciar el contenedor.
EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "1", "--threads", "2", "app:app"]
