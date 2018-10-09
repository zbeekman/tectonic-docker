# Docker Tectonic with Biber
A tiny docker image with a working [tectonic latex
engine](https://tectonic-typesetting.github.io/en-US/index.html) and [biber](https://github.com/plk/biblatex) with a primed cache.

* Visit my page on docker hub at: https://hub.docker.com/r/dxjoke/tectonic-docker/
* Visit my page on github at: https://github.com/WtfJoke/tectonic-docker


## Getting the image
```
docker pull dxjoke/tectonic-docker
```

Only **~70MB** compressed.

A fully working latex engine. Packages that are not in the cache will be
downloaded on demand.

# Example: Gitlab CI

Create a `.gitlab-ci.yml` with the following content for very fast
pdf builds.

```yaml
pdf:
  image: dxjoke/tectonic-docker
  script:
    - tectonic --keep-intermediates --reruns 0 my-document.tex
    - biber my-document
    - tectonic my-document.tex
  artifacts:
    paths:
      - my-document.pdf
```

# Example: Travis CI
Create a `.travis.yml` file with, assuming the main tex file to be `main.tex`.
If your `main.tex` file is in a subfolder (for example src/main.tex), adjust the second line to src=$TRAVIS_BUILD_DIR/mysubfolder (eg src=$TRAVIS_BUILD_DIR/src)

```yaml
sudo: required

services:
  - docker

script:
 - docker pull dxjoke/tectonic-docker
 - docker run --mount src=$TRAVIS_BUILD_DIR,target=/usr/src/tex,type=bind dxjoke/tectonic-docker
  /bin/sh -c "tectonic --keep-intermediates --reruns 0 main.tex; biber main; tectonic main.tex"
```

### Priming the cache

After building tectonic, it is run on the tex files in this repo to
download all the common files from the tectonic bundle. These files are bundled in the docker image

## Running locally
On windows
`docker run -it -v c:/mytex/folder/thesis:/data dxjoke/tectonic-docker`
On linux
`docker run -it -v /home/user/mytex/folder/thesis:/data dxjoke/tectonic-docker`

Then you can cd into /data and run tectonic/biber as you wish.

