{
  lib,
  stdenv,
  fetchurl,
  rpm,
  cpio,
  jdk17,
  bash,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "datamodeler";
  version = "24.3.1";
  src = fetchurl {
    url = "https://download.oracle.com/otn_software/java/sqldeveloper/datamodeler-24.3.1.351.0831-1.noarch.rpm";
    hash = "sha256-mUw4qaaax2mpK/TaLx2P7wlveF8ayslzY7wDS+ItOVo=";
  };

  nativeBuildInputs = [
    rpm
    cpio
  ];

  buildInputs = [
    bash
    jdk17
  ];

  unpackPhase = ''
    runHook preUnpack

    rpm2cpio $src | cpio -idvm
    cd ./opt/datamodeler

    runHook postUnpack
  '';

  dontBuild = true;

  postPatch = ''
    patchShebangs --build ./datamodeler/bin/datamodeler

    substituteInPlace ./datamodeler.desktop --replace-fail "/opt/datamodeler/icon.png" "$out/share/icons/hicolor/128x128/apps/icon.png"
  '';

  installPhase = ''
    runHook preInstall

    cp -r ../datamodeler $out
    mkdir -vp "$out/bin"  "$out/share/applications/" "$out/share/icons/hicolor/128x128/apps"
    ln -s $out/datamodeler/bin/datamodeler $out/bin/datamodeler
    install -m 444 ./datamodeler.desktop $out/share/applications
    install -m 444 ./icon.png $out/share/icons/hicolor/128x128/apps

    runHook postInstall
  '';

  meta.license = lib.licenses.unfree;
})
