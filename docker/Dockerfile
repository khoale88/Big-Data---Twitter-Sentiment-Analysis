FROM python:2.7
MAINTAINER khoale88 "lenguyenkhoa1988@gmail.com"

RUN apt-get update -y
RUN apt-get upgrade -y

RUN pip install Flask

RUN echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list

ENV R_BASE_VERSION 3.4.0
RUN apt-get update \
	&& apt-get install -t unstable -y --no-install-recommends \
		littler \
                r-cran-littler \
		r-base=${R_BASE_VERSION}* \
		r-base-dev=${R_BASE_VERSION}* \
		r-recommended=${R_BASE_VERSION}*    
# RUN pip install rpy2
RUN apt-get -y install libcurl4-openssl-dev
#setup R configs
RUN echo "r <- getOption('repos'); r['CRAN'] <- 'http://cran.us.r-project.org'; options(repos = r);" > ~/.Rprofile
RUN Rscript -e "install.packages('twitteR')"
RUN Rscript -e "install.packages('streamR')"
RUN Rscript -e "install.packages('RCurl')"
RUN Rscript -e "install.packages('RJSONIO')"
RUN Rscript -e "install.packages('devtools')"
RUN Rscript -e "install.packages('maptools')"
RUN Rscript -e "install.packages('maps')"
# RUN Rscript -e "install.packages('dismo')"
RUN Rscript -e "install.packages('ggplot2')"
RUN Rscript -e "install.packages('XML')"
RUN Rscript -e "install.packages('data.table')"
RUN Rscript -e "install.packages('mapproj')"
RUN Rscript -e "install.packages('ggmap')"
RUN apt-get install r-cran-slam -y
RUN Rscript -e "install.packages('wordcloud')"
RUN Rscript -e "install.packages('tm')"

CMD /bin/bash