from continuumio/miniconda3:4.7.12-alpine as t
ENV PATH "/opt/conda/bin:/usr/local/bin:$PATH:/home/dja/.local/bin"
COPY shell_intercept.sh /etc/profile.d/
SHELL ["/bin/sh", "-lc"]
RUN \
    # conda update conda && \
#     # conda config --add channels conda-forge && \
    conda install -y python=3.6 && \
#     # conda install -y python=3.7 && \
#     # conda install -y python=3.8 && \
    conda clean --yes --all

FROM scratch
COPY --from=t / /