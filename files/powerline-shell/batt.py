import os
import platform
import re
import subprocess

from powerline_shell.utils import BasicSegment


class MyColor():
    def __init__(self, fg, bg):
        self.fg = fg
        self.bg = bg


class Segment(BasicSegment):
    '''
    Example outputs for pmset:
    "Now drawing from 'AC Power'\n -InternalBattery-0 (id=3866723)\t84%; charging; 1:04 remaining present: true"
    "Now drawing from 'Battery Power'\n -InternalBattery-0 (id=3866723)\t85%; discharging; (no estimate) present: true"
    '''
    low_batt = MyColor(124, 243)
    normal_batt = MyColor(172, 242)
    high_batt = MyColor(106, 235)
    low_threshold = 25
    high_threshold = 75
    on_battery_icon = '⚡️'
    # on_ac_power_icon = ''
    on_ac_power_icon = '🔌'

    def _is_mac(self):
        system = platform.system()
        return system.startswith('Darwin')

    def _execute(self, proc):
        return proc.communicate()[0].decode("utf-8").strip()

    def _get_batt_status(self):
        command = ['acpi']    # Debian
        if self._is_mac():
            command = ['pmset', '-g', 'batt']   # Debian only, most probably

        # Debug
        batt_level = os.environ.get('BATT_LEVEL', None)
        if batt_level:
            return int(batt_level), os.environ.get('BATT_STATUS', False)

        batt_proc = subprocess.Popen(command, stdout=subprocess.PIPE)
        batt_output = self._execute(batt_proc)

        batt_level = re.findall('[0-9]+%', batt_output)
        if batt_level:
            batt_level = int(batt_level[0].replace('%', ''))

        is_discharging = 'discharging' in batt_output
        return batt_level, is_discharging

    def _enough_powered_battery(self, level: int, discharging: bool) -> bool:
        return level >= 90 and not discharging

    def add_to_powerline(self):
        batt_level, is_batt_discharging = self._get_batt_status()
        if not batt_level:
            return

        if self._enough_powered_battery(batt_level, is_batt_discharging):
            return

        batt_level = int(batt_level)

        batt_level_string = ' {}% {}'.format(
            batt_level,
            self.on_battery_icon if is_batt_discharging else self.on_ac_power_icon
        )
        if batt_level <= self.low_threshold:
            self.powerline.append(batt_level_string, self.low_batt.bg, self.low_batt.fg)
        elif batt_level <= self.high_threshold:
            self.powerline.append(batt_level_string, self.normal_batt.bg, self.normal_batt.fg)
        else:
            self.powerline.append(batt_level_string, self.high_batt.bg, self.high_batt.fg)
