import re
import os
import argparse
import pandas as pd

# build slurm
parser = argparse.ArgumentParser(description='Generate shell script for group processing')
parser.add_argument('-s', '--sample_id', help='sample id', required=True)
parser.add_argument('-t', '--template', help='template', required=True)
parser.add_argument('-d', '--directory', help='directory', required=True)
args = parser.parse_args()

home_path = os.path.dirname(os.path.realpath(__file__))  + '/../'
config_file = home_path + 'config.txt'
template_file = home_path + 'Tools/' + args.template

def func(m):
    return replace_pair[m.group(1).strip('_')]

if __name__ == "__main__":
    dfs = []
    
    # build slurm
    slurm_file = home_path + args.directory + '/Kneaddata-' + args.sample_id + '.sh'
    
    replace_pair = {}
    with open(config_file) as fc:
        for line in fc:
            if not line.strip().startswith('#') and line.strip():
                content = line.strip().split('=')
                replace_pair[content[0].strip()] = \
                    content[1].strip()
    replace_pair['SAMPLE_ID'] = args.sample_id
    with open(template_file) as ft, \
        open(slurm_file, 'w') as fs:
        for line in ft:
            p = re.compile('(__.+?__)')
            s = p.search(line.strip())
            if s:
                fs.write(p.sub(func, line.strip()) + '\n')
            else:
                fs.write(line)
