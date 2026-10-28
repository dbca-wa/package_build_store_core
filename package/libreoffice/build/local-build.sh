!#/bin/bash

/usr/local/bin/python3.15-config --includes ; /usr/local/bin/python3.15-config --ldflags --embed

cd /tmp; git clone --depth 1 --branch release https://github.com/ninja-build/ninja.git; cd ninja; /usr/local/bin/python3.15 configure.py --bootstrap; install -m 0755 ninja /usr/local/bin/ninja;   /usr/local/bin/ninja --version;  cd /;  rm -rf /tmp/ninja
export MESON_VERSION="$(curl -fsSL https://api.github.com/repos/mesonbuild/meson/releases/latest | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')"; echo "Building Meson ${MESON_VERSION}"; cd /tmp; curl -fsSL         "https://github.com/mesonbuild/meson/releases/download/${MESON_VERSION}/meson-${MESON_VERSION}.tar.gz" -o meson.tar.gz; mkdir /opt/meson; tar -xzf meson.tar.gz --strip-components=1 -C /opt/meson; ln -s /opt/meson/meson.py /usr/local/bin/meson; chmod +x /opt/meson/meson.py; /usr/local/bin/meson --version; rm -f /tmp/meson.tar.gz
python -m pip install unoserver

export LIBREOFFICE_VERSION=26.8.0
export LIBREOFFICE_VERSION_MINOR=3

cd /tmp; curl -fsSL "https://download.documentfoundation.org/libreoffice/src/${LIBREOFFICE_VERSION}/libreoffice-${LIBREOFFICE_VERSION}.${LIBREOFFICE_VERSION_MINOR}.tar.xz" -o libreoffice.tar.xz; tar -xJf libreoffice.tar.xz;  cd "libreoffice-${LIBREOFFICE_VERSION}.${LIBREOFFICE_VERSION_MINOR}"; 

export PATH="/usr/local/bin:${PATH}";export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig";export LD_LIBRARY_PATH="/usr/local/lib:/usr/local/lib64";export PYTHON="/usr/local/bin/python3.15";export PYTHON_CFLAGS="$(python3.15-config --includes)";export PYTHON_LIBS="$(python3.15-config --ldflags --embed)"; export container=docker;./autogen.sh --prefix=/opt/LibreOffice --with-vendor="DBCA" --without-help --without-myspell-dicts --disable-online-update --disable-odk --disable-postgresql-sdbc --disable-firebird-sdbc --disable-report-builder --disable-scripting-beanshell --disable-cups --without-java --disable-gtk3 --disable-dbus --disable-gstreamer-1-0 --disable-opengl --disable-sdremote --disable-online-update --disable-avmedia --without-helppack-integration --without-junit --with-lang=en-US --disable-cve-tests --disable-pdfium --disable-skia --disable-mariadb-sdbc --disable-ldap --disable-librelogo --disable-lpsolve --disable-coinmp --without-webdav --disable-extension-update --with-templates=no --disable-scripting-javascript;

mv /opt/libreOffice /opt/libreOffice.disabled

make -j"$(nproc)"; 
 cp -p \
     workdir/Package/Gallery/Files/backgrounds.filelist \
     workdir/Package/Gallery/backgrounds.filelist && \
 cp -p \
     workdir/Package/Gallery/Files/sounds.filelist \
     workdir/Package/Gallery/sounds.filelist ;
mkdir -p workdir/Package/PackageSet
rm -f workdir/Package/PackageSet/Gallery_sounds.filelist  
 touch workdir/Package/PackageSet/Gallery_sounds.filelist
     
make install;  
sed -i '/gid_File_Extra_Gallsounds,/d' \
    scp2/source/ooo/module_ooo.scp
make -j"$(nproc)"
make install
make -j1 scp2.clean
make -j"$(nproc)" scp2
rm -rf workdir/ScpTarget/scp2
rm -rf workdir/ScpPreprocessTarget/scp2
make -j"$(nproc)"

mkdir -p workdir/Package/Gallery/Files
touch workdir/Package/Gallery/sounds.filelist
touch workdir/Package/Gallery/Files/sounds.filelist

make install
