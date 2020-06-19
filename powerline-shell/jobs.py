import os
import re
import subprocess
import platform
from powerline_shell.utils import ThreadedSegment


class Segment(ThreadedSegment):
    def _execute(self, proc):
        return proc.communicate()[0].decode("utf-8").strip()

    def run(self):
        self.num_jobs = 0
        system = platform.system()
        if system.startswith('CYGWIN'):
            # cygwin ps is a special snowflake...
            output_proc = subprocess.Popen(['ps', '-af'], stdout=subprocess.PIPE)
            output = map(lambda l: int(l.split()[2].strip()),
                         output_proc.communicate()[0].decode("utf-8").splitlines()[1:])
            self.num_jobs = output.count(os.getppid()) - 1
        elif system.startswith('Darwin'):
            ppid = str(os.getppid())
            jobs_proc = subprocess.Popen(['ps', '-af'], stdout=subprocess.PIPE)
            jobs_output = self._execute(jobs_proc)
            jobs_output_splitted = jobs_output.splitlines()[1:]
            filtered_output = [x for x in jobs_output_splitted
                               if ppid in x and
                               '-bash' not in x and '__git' not in x and 'grep' not in x and 'ps -af' not in x and
                               'powerline-shell' not in x
                               ]
            self.num_jobs = len(filtered_output)
        else:
            pppid_proc = subprocess.Popen(['ps', '-p', str(os.getppid()), '-oppid='],
                                          stdout=subprocess.PIPE)
            pppid = pppid_proc.communicate()[0].decode("utf-8").strip()
            output_proc = subprocess.Popen(['ps', '-a', '-o', 'ppid'],
                                           stdout=subprocess.PIPE)
            output = output_proc.communicate()[0].decode("utf-8")
            self.num_jobs = len(re.findall(str(pppid), output)) - 1

    def add_to_powerline(self):
        try:
            self.run()
        except Exception:
            self.num_jobs = 0

        if self.num_jobs > 0:
            self.powerline.append(' {} '.format(self.num_jobs),
                                  self.powerline.theme.JOBS_FG,
                                  self.powerline.theme.JOBS_BG)
