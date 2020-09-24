FROM alpine:latest as builder

RUN apk add wget tar tectonic

WORKDIR /usr/src/tex
RUN wget 'https://sourceforge.net/projects/biblatex-biber/files/biblatex-biber/2.11/binaries/Linux-musl/biber-linux_x86_64-musl.tar.gz'
RUN tar -xvzf biber-linux_x86_64-musl.tar.gz
RUN chmod +x biber
RUN cp biber /usr/bin/biber

COPY *.tex ./
COPY *.bib ./
# first run - keep files for biber
RUN tectonic --keep-intermediates --reruns 0 main.tex
# do the biber
RUN biber main
# one last tectonic run over all files
RUN for f in *.tex; do tectonic $f; done


FROM alpine:latest
# Install runtime dependencies, alternative use # RUN apk add harfbuzz-dev 
RUN apk add harfbuzz libstdc++ fontconfig icu-libs harfbuzz-icu
# copy tectonic binary to new image
COPY --from=builder /usr/bin/tectonic /usr/bin/
# reuse tectonic cache from compiling tex files
COPY --from=builder /root/.cache/Tectonic/ /root/.cache/Tectonic/
# copy biber binary to new image
COPY --from=builder /usr/bin/biber /usr/bin/ 

WORKDIR /usr/src/tex