FROM python:2.7
MAINTAINER khoale88 "lenguyenkhoa1988@gmail.com"

RUN apt-get update -y
RUN apt-get upgrade -y

RUN pip install Flask

RUN apt-get -y install r-base
RUN pip install rpy2
RUN apt-get -y install libcurl4-openssl-dev
#setup R configs
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
RUN Rscript -e "install.packages('yhatr')"
RUN Rscript -e "install.packages('ggplot2')"
RUN Rscript -e "install.packages('plyr')"
# RUN Rscript -e "install.packages('reshape2')"
# RUN Rscript -e "install.packages('forecast')"
RUN Rscript -e "install.packages('stringr')"
# RUN Rscript -e "install.packages('lubridate')"
# RUN Rscript -e "install.packages('randomForest')"
# RUN Rscript -e "install.packages('rpart')"
# RUN Rscript -e "install.packages('e1071')"
# RUN Rscript -e "install.packages('kknn')"
RUN Rscript -e "install.packages('devtools')"
RUN Rscript -e "install.packages('rjson')"
RUN Rscript -e "install.packages('bit64')"
RUN Rscript -e "install.packages('httr')"
RUN Rscript -e "install.packages('geoffjentry/twitteR')"

