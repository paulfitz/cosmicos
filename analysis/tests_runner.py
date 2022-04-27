#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Apr 23 16:03:36 2022

@author: joha2

Boilerplate code for unittest
"""

import unittest

import tests_analysis

loader = unittest.TestLoader()
suite = unittest.TestSuite()

suite.addTests(loader.loadTestsFromModule(tests_analysis))

runner = unittest.TextTestRunner(verbosity=3)
result = runner.run(suite)