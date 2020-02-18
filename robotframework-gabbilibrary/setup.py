#!/usr/bin/env python
# -*- coding: utf-8 -*-

try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

from os.path import join, dirname
## python3 does not have execfile so use exec.
exec(open(join(dirname(__file__), 'src', 'GabbiLibrary', 'version.py')).read())
#execfile(join(dirname(__file__), 'src', 'GabbiLibrary', 'version.py'))
long_description = open(join(dirname(__file__), 'README.rst',)).read()

CLASSIFIERS = """
Programming Language :: Python :: 3
Topic :: Software Development :: Testing
"""[1:-1]

setup(
    name='robotframework-gabbilibrary',
    version=VERSION,
    description='Robot framework test library for Gabbi tests ',
    long_description=long_description,
    author='Heechul Kim',
    author_email='jijisa@iorchard.co.kr',
    url='https://github.com/iorchard/robotframework-gabbilibrary',
    license='Apache License 2.0',
    packages=['GabbiLibrary'],
    package_dir={'': 'src'},
    install_requires=['robotframework', 'gabbi>=1.36.0'],
    zip_safe=False,
    keywords='robotframework gabbi http testing',
    classifiers=CLASSIFIERS.splitlines()
)
