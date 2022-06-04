FROM python:2.7
RUN mkdir www
COPY index.html www
WORKDIR www
CMD ["python", "-m", "SimpleHTTPServer"]
