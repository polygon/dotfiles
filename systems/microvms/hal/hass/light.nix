{ config, pkgs, ...}:
{
  services.home-assistant.config = {
    "automation manual" = [
      {
        alias = "Luminaire Toggle";
        trigger = {
          platform = "event";
          event_type = "hue_event";
          event_data.id = "bedroom_dimmer_button";
          event_data.type = "long_press";
        };
        action = {
          service = "switch.toggle";
          target.entity_id = "switch.tasmota";
        };
      }
    ];
  };
}
