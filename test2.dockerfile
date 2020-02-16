from alpine as t
add http://www.sbeams.org/sample_data/Microarray/Affy_test_data.tar.gz /tmp/affy.tar.gz
run \
    cd /tmp && \
    tar -xzf affy.tar.gz && \
    chmod -R 400 /tmp/Affy_test_data

# FROM scratch
# COPY --from=t / /