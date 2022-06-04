FROM python:2.7
RUN useradd -m testuser
WORKDIR /home/testuser
COPY index.html /home/testuser
RUN chown testuser:testuser /home/testuser/index.html
USER testuser
CMD ["python", "-m", "SimpleHTTPServer"]
