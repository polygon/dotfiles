{ config, pkgs, ...}:
{
  services.home-assistant.config = {
    notify = [
      {
        name = "gotify_jan";
        platform = "rest";
        resource = "https://push.nubego.de/message";
        method = "POST_JSON";
        headers = {
          "X-Gotify-Key" = "!include ${config.sops.secrets.hass-gotify-token.path}";
        };
        message_param_name = "message";
        title_param_name = "title";
        data = {
          priority = 5;
        };
      }
    ];
  };
}
