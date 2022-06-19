{lib, config, prev, ...}:
let
  new_env = env: (builtins.removeAttrs env ["PAPERLESS_DBPASS"]);
  preStart = "${prev.config.systemd.services.paperless-scheduler.preStart}";
  manage = builtins.head (builtins.match ".*ln -sf ([^[:space:]]+).*" "${builtins.trace preStart preStart}");
in
{
  systemd.services.paperless-scheduler.environment = lib.mkForce (new_env prev.config.systemd.services.paperless-scheduler.environment);
  systemd.services.paperless-scheduler.serviceConfig.EnvironmentFile = config.sops.secrets.paperless-dbpass-envfile.path;

  systemd.services.paperless-consumer.environment = lib.mkForce (new_env prev.config.systemd.services.paperless-consumer.environment);
  systemd.services.paperless-consumer.serviceConfig.EnvironmentFile = config.sops.secrets.paperless-dbpass-envfile.path;

  systemd.services.paperless-web.environment = lib.mkForce (new_env prev.config.systemd.services.paperless-web.environment);
  systemd.services.paperless-web.serviceConfig.EnvironmentFile = config.sops.secrets.paperless-dbpass-envfile.path;

  systemd.services.paperless-consumer.preStart = lib.mkForce (
    builtins.replaceStrings [ "${manage}" ] [ "${config.scalpel.trafos."manage".destination} "] "${preStart}"
  );
  scalpel.trafos."manage" = {
    source = manage;
    matchers."PAPERLESS_DBPASS".secret = config.sops.secrets.paperless-dbpass.path;
    owner = "paperless";
    group = "paperless";
    mode = "0440";
  };
}
