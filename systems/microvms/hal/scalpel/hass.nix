{lib, config, prev, ...}:
let
  preStart = "${prev.config.systemd.services.home-assistant.preStart}";
  hass_cfgfile = builtins.head (builtins.match ".*ln -s ([^[:space:]]+) [^[:space:]]*configuration.yaml.*" "${preStart}");
in
{
  systemd.services.home-assistant.preStart = lib.mkForce (
    builtins.replaceStrings [ "${hass_cfgfile}" ] [ "${config.scalpel.trafos."configuration.yaml".destination} "] "${preStart}"
  );
  scalpel.trafos."configuration.yaml" = {
    source = hass_cfgfile;
    matchers."HASS_DBPASS".secret = config.sops.secrets.hass-psql-pass.path;
    matchers."HASS_LAT".secret = config.sops.secrets.hass-lat.path;
    matchers."HASS_LON".secret = config.sops.secrets.hass-lon.path;
    owner = "hass";
    group = "hass";
    mode = "0440";
  };
}
