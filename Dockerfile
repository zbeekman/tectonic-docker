FROM rust:latest as builder
RUN apt-get update && apt-get install -y libfontconfig1-dev libgraphite2-dev libharfbuzz-dev libicu-dev zlib1g-dev


RUN cargo install tectonic --force

WORKDIR /usr/src/tex
RUN wget 'https://sourceforge.net/projects/biblatex-biber/files/biblatex-biber/current/binaries/Linux/biber-linux_x86_64.tar.gz'
RUN tar -xvzf biber-linux_x86_64.tar.gz
RUN chmod +x biber
RUN cp biber /usr/bin/biber

COPY *.tex ./
COPY *.bib ./
# first run - keep files for biber
RUN tectonic --keep-intermediates --reruns 0 main.tex
RUN biber main
RUN for f in *.tex; do tectonic $f; done

# use a lightweight debian - no need for whole miniconda
FROM debian:stretch-slim 
RUN apt-get update \
    && apt-get install -y --no-install-recommends libfontconfig1 libgraphite2-3 libharfbuzz0b libicu57 zlib1g libharfbuzz-icu0 libssl1.1 ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/* 

# copy tectonic binary to new image
COPY --from=builder /usr/local/cargo/bin/tectonic /usr/bin/
# reuse tectonic cache from compiling tex files
COPY --from=builder /root/.cache/Tectonic/ /root/.cache/Tectonic/
# copy biber binary to new image
COPY --from=builder /usr/bin/biber /usr/bin/ 

WORKDIR /usr/src/tex