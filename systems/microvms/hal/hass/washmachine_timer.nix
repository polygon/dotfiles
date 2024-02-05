{ config, pkgs, ...}:
{
  services.home-assistant.config = {
    timer.washmachine = {
      duration = "00:05:00";
      name = "Washmachine Timer";
    };
    binary_sensor = [
      {
        platform = "threshold";
        entity_id = "sensor.washmachine_plug_energy_power";
        upper = 8;
        device_class = "power";
        name = "Washmachine Power";
      }
    ];
    "automation manual" = [
      {
        alias = "Washmachine Started";
        trigger = {
          platform = "state";
          entity_id = "binary_sensor.washmachine_power";
          to = "on";
        };
        condition = {
          condition = "state";
          entity_id = "timer.washmachine";
          state = "idle";
        };
        action = {
          service = "notify.gotify_jan";
          data.title = "Washmachine Timer";
          data.message = "Washmachine started, we got this!";
        };
      }
      {
        alias = "Washmachine Finished";
        trigger = {
          platform = "state";
          entity_id = "binary_sensor.washmachine_power";
          to = "off";
        };
        action = {
          service = "timer.start";
          entity_id = "timer.washmachine";
        };
      }
      {
        alias = "Washmachine Re-On";
        trigger = {
          platform = "state";
          entity_id = "binary_sensor.washmachine_power";
          to = "on";
        };
        condition = {
          condition = "state";
          entity_id = "timer.washmachine";
          state = "active";
        };
        action = {
          service = "timer.cancel";
          entity_id = "timer.washmachine";
        };
      }
      {
        alias = "Washmachine Notification";
        trigger = {
          platform = "event";
          event_type = "timer.finished";
          event_data.entity_id = "timer.washmachine";
        };
        action = [
          {
            service = "notify.gotify_jan";
            data.title = "Washmachine Timer";
            data.message = "Washmachine done, please acknowledge!";
          }
          {
            service = "timer.start";
            entity_id = "timer.washmachine";
          }
        ];
      }
      {
        alias = "Washmachine Acknowledge";
        trigger = {
          platform = "event";
          event_type = "tasmota_event";
          event_data.mac = "2462AB201F9D";
          event_data.source = "button_1";
          event_data.event = "SINGLE";
        };
        condition = {
          condition = "state";
          entity_id = "timer.washmachine";
          state = "active";
        };
        action = [
          {
            service = "notify.gotify_jan";
            data.title = "Washmachine Timer";
            data.message = "Done acknowledged, we stop bugging you now!";
          }
          {
            service = "timer.cancel";
            entity_id = "timer.washmachine";
          }
        ];
      }
    ];
  };
}
