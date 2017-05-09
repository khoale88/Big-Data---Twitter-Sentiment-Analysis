import subprocess
import csv

def del_files_except(directory, exclude):
    """args[1]"""
    from os import listdir, remove
    from os.path import isfile, join
    #args[1] should be input path
    onlyfile = [f for f in listdir(directory) if isfile(join(directory, f))]
    for filename in onlyfile:
        if filename not in exclude:
            remove(join(directory, filename))

def call_rscript(working_dir, script_file, *args):
    """run r script with arbitrary numbers of arguments"""
    subprocess.call(["Rscript", working_dir+script_file] +
                    [str(arg) for arg in args] +
                    [working_dir])

def csv_to_array(csv_path):
    """read all line in csv file and return a flaten arrays"""
    with open(csv_path, 'r') as csv_file:
        csv_reader = csv.reader(csv_file)
        output = [item for line_items in csv_reader for item in line_items]
    #ignore the 1st entry which is x
    return output[1:]

