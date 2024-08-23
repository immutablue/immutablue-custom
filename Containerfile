# Base off of Immutablue
FROM registry.gitlab.com/immutablue/immutablue:40
ARG INSTALL_DIR=/opt/immutablue/
ARG NAME=CHANGE-ME

COPY ./packages/packages-custom-*.yaml ${INSTALL_DIR}

WORKDIR /opt/immutablue-build-${NAME}
COPY . .

# Install RPM (NO NEED TO EDIT THIS)
RUN set -x && \
    ls -l ./packages/packages-custom-*.yaml && \
    pkg_yamls=$(for yaml in ./packages/packages-custom-*.yaml; do printf "%s " $yaml; done) && \
    for yaml in $pkg_yamls; do pkgs=$(yq '.immutablue.rpm[]' < $yaml); rpm-ostree install $(for pkg in $pkgs; do printf '%s ' $pkg; done); done && \
    ostree container commit


# Remove RPM (NO NEED TO EDIT THIS)
RUN set -x && \
    ls -l ./packages/packages-custom-*.yaml && \
    pkg_yamls=$(for yaml in ./packages/packages-custom-*.yaml; do printf "%s " $yaml; done) && \
    for yaml in $pkg_yamls; do pkgs=$(yq '.immutablue.rpm_rm[]' < $yaml); [ "" != "$pkgs" ] && rpm-ostree uninstall $(for pkg in $pkgs; do printf '%s ' $pkg; done) || echo "No Uninstalls"; done && \
    ostree container commit


# Remove Build Files (NO NEED TO EDIT THIS)
RUN set -x && \
    ls -l ./packages/packages-custom-*.yaml && \
    file_yamls=$(for yaml in ./packages/packages-custom-*.yaml; do printf "%s " $yaml; done) && \
    for yaml in $file_yamls; do files=$(yq '.immutablue.file_rm[]' < $yaml); for f in $files; do rm "$f"; done; done && \
    ostree container commit


