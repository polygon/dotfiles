{ config, pkgs, ...}:
{
  services.home-assistant = {
    package = (pkgs.home-assistant.override {
      extraPackages = py: with py; [ psycopg2 ];
    }).overrideAttrs (oldAttrs: {
      doInstallCheck = false;
    });

    enable = true;
    config = {
      default_config = {};
      esphome = {};
      met = {};
      hue = {};
      mqtt = {};
      tasmota = {};
      backup = {};
      rest = {};
      recorder.db_url = "postgresql://hass:!!HASS_DBPASS!!@192.168.3.20/hass";
      http = {
        server_host = "192.168.3.23";
        trusted_proxies = "192.168.3.20";
        use_x_forwarded_for = true;
      };
      homeassistant = {
        time_zone = "Europe/Berlin";
        latitude = "!!HASS_LAT!!";
        longitude = "!!HASS_LON!!";
      };
      "automation ui" = "!include automations.yaml";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
}
