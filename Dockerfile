#Temp Image to create exec to allow UID/GID to be updated on boot
FROM golang:alpine3.11 as go_tmp
COPY ./startup.go /startup.go
RUN cd / && go build startup.go

from continuumio/miniconda3:4.7.12-alpine as py_build

ENV PATH "/opt/conda/bin:/usr/local/bin:$PATH:/home/dja/.local/bin"

# https://uoa-eresearch.github.io/eresearch-cookbook/recipe/2014/11/20/conda/
user root
# # datajoint admin (dja) mapped to docker host user
RUN export uid=3000 gid=3000 && \
    mkdir -p /home/dja && \
    mkdir /src && \
    echo "dja:x:${uid}:101:Developer,,,:/home/dja:/bin/sh" >> /etc/passwd && \
    # echo "dja:x:${uid}:" >> /etc/group && \
    chown ${uid}:${gid} -R /home/dja && \
    chown ${uid}:${gid} -R /src && \
    chmod -R g+w /opt/conda
# jupyter dependencies
RUN \
  apk --no-cache --update-cache add --virtual build-jnb-dependencies \
    curl make && \
  mkdir -p min-package && \
  cd min-package && \
  curl -L https://archive.org/download/zeromq_4.0.4/zeromq-4.0.4.tar.gz > package.tar.gz && \
  tar -xzf package.tar.gz && \
  rm package.tar.gz && \
  cd $(ls) && \
  ./configure && make && make install && \
  cd ../../ && \
  rm -rf min-package && \
  strip --strip-unneeded --strip-debug /usr/local/lib/*.a || true && \
  strip --strip-unneeded --strip-debug /usr/local/lib/*.so* || true 
# RUN \
#   apk --no-cache --update-cache add git
COPY ./entrypoint.sh /entrypoint.sh
COPY --from=go_tmp /startup /startup
RUN \
  chmod +x /entrypoint.sh && \
  chmod 4755 /startup

ENV PYTHON_USER dja
# RUN chmod 4755 /startup && /startup 3000 3000
LABEL maintainerName="Raphael Guzman" \
      maintainerEmail="raphael@vathes.com" \
      maintainerCompany="DataJoint"
# User root
# run \
#     chmod -R o+w /home/dja/.miniconda3/pkg && \
#     chmod -R o+w /home/dja/.miniconda3/envs && \
#     printf "\nconda activate dj\n" | tee -a /etc/profile.d/shell_intercept.sh
USER dja
COPY shell_intercept.sh /etc/profile.d/
SHELL ["/bin/sh", "-lc"]
# ENV CONDA_PKGS_DIRS /home/dja/.miniconda3/pkg
# ENV CONDA_ENVS_PATH /home/dja/.miniconda3/envs
# RUN \
#     conda create -y -n dj python=3.7 && \
#     conda activate dj && \
#     conda config --add channels conda-forge && \
#     conda install -y -n dj datajoint --only-deps
RUN \
    conda config --add channels conda-forge && \
    # conda install -y python=3.6 && \
    conda install -y python=3.8 datajoint --only-deps && \
    conda clean -ya
# jupyter install
RUN pip install jupyter
user root
run apk del build-jnb-dependencies
user dja
COPY ./jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py
# User root
# run \
#     chmod -R o+w /home/dja/.miniconda3/pkg && \
#     chmod -R o+w /home/dja/.miniconda3/envs && \
#     printf "\nconda activate dj\n" | tee -a /etc/profile.d/shell_intercept.sh
# user dja
# pip install datajoint==0.12.4
# conda install -y -n dj datajoint=0.12.4
ENV HOME /home/dja
ENV LANG C.UTF-8
ENV APK_REQUIREMENTS /apk_requirements.txt
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /src
VOLUME /src
VOLUME /tmp/.X11-unix
EXPOSE 8888
CMD ["/bin/sh", "-l"]


# #Squashed Final Image
FROM scratch
COPY --from=py_build / /
ENV PYTHON_USER dja
RUN chmod 4755 /startup && /startup 3000 3000
LABEL maintainerName="Raphael Guzman" \
      maintainerEmail="raphael@vathes.com" \
      maintainerCompany="DataJoint"
USER dja
ENV HOME /home/dja
ENV LANG C.UTF-8
ENV APK_REQUIREMENTS /apk_requirements.txt
ENV PATH "/opt/conda/bin:/usr/local/bin:$PATH:/home/dja/.local/bin"
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /src
VOLUME /src
VOLUME /tmp/.X11-unix
EXPOSE 8888
CMD ["/bin/sh", "-l"]