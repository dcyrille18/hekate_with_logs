FROM devkitpro/devkitarm

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl unzip zip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work

CMD ["sh", "-c", "make -j4 && sh tools/package_release.sh"]
