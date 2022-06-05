FROM python:2.7
RUN useradd -m hellouser
WORKDIR /home/hellouser
COPY index.html /home/hellouser
RUN chown hellouser:hellouser /home/hellouser/index.html
USER hellouser
CMD ["python", "-m", "SimpleHTTPServer"]
