{
  lib,
  stdenv,
  fetchFromGitHub,
  librime,
}:

stdenv.mkDerivation {
  pname = "rime-moran";
  version = "3.1-r1294";

  src = fetchFromGitHub {
    owner = "rime";
    repo = "plum";
    rev = "4c28f11f451facef809b380502874a48ba964ddb";
    sha256 = "sha256-4KrOYSNN2sjDhnMr4jZxF+0bPwRzj8oDsW0qSX23/dg=";
  };

  buildInputs = [ librime ];

  buildFlags = [ "all" ];
  makeFlags = [ "PREFIX=$(out)" ];

  preBuild = ''
    mkdir -p package/rime
    ln -sv ${
      fetchFromGitHub {
        owner = "rimeinn";
        repo = "rime-moran";
        rev = "b8ac069eea4cb1b4192ba4dbac9957739641ed7c";
        sha256 = "1xn4j05sbmyn002rq9j9c8knq9pgqy66ashamkb9njzq79ljj5pz";
      }
    } package/rime/moran
  '';

  patches = [ ./0001-for-moran.patch ];

  postPatch = ''
    # Disable git operations.
    sed -i /fetch_or_update_package$/d scripts/install-packages.sh
  '';

  meta = with lib; {
    description = "Moran schema data of Rime Input Method Engine";
    longDescription = ''
      Moran is an advanced Rime schema based on Ziranma, designed for fast, precise, and intuitive Chinese typing. The name "Moran" signifies a "Radically-modified Ziranma" in Chinese.
    '';
    homepage = "https://rime.im";
    license = with licenses; [
      # plum
      lgpl3Only

      # rime-moran
      cc-by-40
    ];
  };
}
