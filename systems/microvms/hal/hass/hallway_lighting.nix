{ config, pkgs, ...}:
{
  services.home-assistant.config = {
    timer.hallway_light = {
      duration = "00:03:00";
      name = "Hallway Timer";
    };
    input_select.hallway_scene = {
      name = "Hallway Scene";
      options = [
        "Hallway Bright Day"
        "Hallway Dimmed"
        "Hallway Night"
      ];
    };
    "automation manual" = [
      {
        alias = "Hallway Daytime Scene";
        trigger = {
          platform = "numeric_state";
          entity_id = "sun.sun";
          attribute = "elevation";
          above = 0.0;
        };
        action = {
          service = "input_select.select_option";
          target.entity_id = "input_select.hallway_scene";
          data.option = "Hallway Bright Day";
        };
      }
      {
        alias = "Hallway Evening Scene";
        trigger = {
          platform = "numeric_state";
          entity_id = "sun.sun";
          attribute = "elevation";
          below = 0.0;
          above = -6.0;
        };
        action = {
          service = "input_select.select_option";
          target.entity_id = "input_select.hallway_scene";
          data.option = "Hallway Dimmed";
        };
      }
      {
        alias = "Hallway Night Scene";
        trigger = {
          platform = "numeric_state";
          entity_id = "sun.sun";
          attribute = "elevation";
          below = -6.0;
        };
        action = {
          service = "input_select.select_option";
          target.entity_id = "input_select.hallway_scene";
          data.option = "Hallway Night";
        };
      }
      {
        alias = "Motion Detected";
        trigger = {
          platform = "state";
          entity_id = "binary_sensor.hallway_motion_sensor_motion";
          to = "on";
        };
        action = [
          {
            service = "scene.turn_on";
            target.entity_id = "{% if is_state('input_select.hallway_scene', 'Hallway Night') %}scene.hallway_hallway_night{% elif is_state('input_select.hallway_scene', 'Hallway Dimmed') %}scene.hallway_hallway_dimmed{% else %}scene.hallway_hallway_bright_day{% endif %}";
          }
          {
            service = "timer.cancel";
            entity_id = "timer.hallway_light";
          }
        ];
      }
      {
        alias = "Motion Gone";
        trigger = {
          platform = "state";
          entity_id = "binary_sensor.hallway_motion_sensor_motion";
          to = "off";
        };
        action = {
          service = "timer.start";
          entity_id = "timer.hallway_light";
        };
      }
      {
        alias = "Timer expired";
        trigger = {
          platform = "event";
          event_type = "timer.finished";
          event_data.entity_id = "timer.hallway_light";
        };
        action = {
          service = "light.turn_off";
          entity_id = "light.hallway";
        };
      }
    ];
  };
}
