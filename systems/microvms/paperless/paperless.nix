{ config, secrets, ... }:
{
  services.paperless.extraConfig = {
    PAPERLESS_FILENAME_FORMAT = "{created_year}/{document_type}/{created_month}-{created_day}-{title}-{asn}";
    PAPERLESS_OCR_LANGUAGE = "deu+eng";
    PAPERLESS_OCR_MODE = "skip";
    PAPERLESS_OCR_CLEAN = "clean";
    PAPERLESS_TASK_WORKERS = 1;
    PAPERLESS_THREADS_PER_WORKER = 1;
    PAPERLESS_TIME_ZONE = "Europe/Berlin";
    PAPERLESS_DBHOST = "192.168.3.20";
    PAPERLESS_DBPASS = "!!PAPERLESS_DBPASS!!";
    PAPERLESS_DATE_ORDER = "DMY";
    PAPERLESS_URL = "https://paperless.matelab.de";
  };

  networking.firewall.allowedTCPPorts = [ 28981 ];
}