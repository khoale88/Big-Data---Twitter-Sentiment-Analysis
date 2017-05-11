FROM khoale88/r-python:0.3
MAINTAINER khoale88 "lenguyenkhoa1988@gmail.com"

COPY . /app
WORKDIR /app

CMD python main.py
