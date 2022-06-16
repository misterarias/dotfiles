import os
import platform
import re
import subprocess

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
            filtered_output = list(filter(
                lambda x: ppid in x and all(s not in x for s in {
                    '-bash', '__git', 'grep', 'ps -af', 'powerline-shell',
                    'poetry shell', 'bash -i'   # poetry?
                }), jobs_output_splitted))
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
            self.powerline.append(' {}! '.format(self.num_jobs),
                                  self.powerline.theme.JOBS_FG,
                                  self.powerline.theme.JOBS_BG)
