from setuptools import setup
import sys
import os
import subprocess
from setuptools import setup, Extension
from setuptools.command.build_ext import build_ext
from distutils.command.build import build
import shutil
import glob


GENESIS2_PATH = os.path.join(os.path.dirname(__file__),
                             "Genesis2")

GENESIS2_REPO = "https://github.com/StanfordVLSI/Genesis2"

class Genesis2Extension(Extension):
    def __init__(self, name, sourcedir=''):
        Extension.__init__(self, name, sources=[])
        self.sourcedir = os.path.abspath(sourcedir)


class Genesis2Build(build_ext):
    def run(self):
        if not os.path.isdir(GENESIS2_PATH):
            subprocess.check_call(["git", "clone", GENESIS2_REPO])

        # we only have one extension
        assert len(self.extensions) == 1
        ext = self.extensions[0]
        extdir = \
            os.path.abspath(os.path.dirname(self.get_ext_fullpath(ext.name)))
        if not os.path.isdir(extdir):
            os.makedirs(extdir)
        extdir = os.path.join(extdir, "Genesis2-src")
        if os.path.isdir(extdir):
            shutil.rmtree(extdir)
        # copy everything over
        assert os.path.isdir(GENESIS2_PATH)
        gui_folder = os.path.join(GENESIS2_PATH, "Genesis2Tools", "gui")
        if os.path.isdir(gui_folder):
            shutil.rmtree(gui_folder)
        shutil.copytree(GENESIS2_PATH, extdir)

setup(
    name='genesis2',
    version='0.0.6',
    packages=[
        "genesis2"
    ],
    author='Keyi Zhang',
    author_email='keyi@cs.stanford.edu',
    description='Python wrapper for Genesis2',
    url="https://github.com/Kuree/genesis2",
    ext_modules=[Genesis2Extension('genesis2')],
    scripts=["bin/Genesis2.pl"],
    cmdclass=dict(build_ext=Genesis2Build),
)
