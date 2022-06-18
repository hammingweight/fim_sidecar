FROM python:3.8
RUN useradd -m hellouser
WORKDIR /home/hellouser
COPY index.html /home/hellouser
RUN chown hellouser:hellouser /home/hellouser/index.html
RUN chmod 600 /home/hellouser/index.html
USER hellouser
CMD ["python", "-m", "http.server"]
