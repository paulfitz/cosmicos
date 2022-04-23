#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Apr 23 15:58:14 2022

@author: joha2

Some tests of the statistical analysis file.
"""

from statistical_graphical_analysis import DecoderClass

import unittest
import random
import logging

NUM_TESTS = 10

class TestMessagesContainEveryCharacter(unittest.TestCase):

    def setUp(self):
        self.d = DecoderClass(logging.getLogger("random msg test"))

    def test_uniform_random_message(self):

        def create_random_message(seed, length):
            (_, message, _) = self.d.generateRandomMessage(seed=seed,
                                                           limit=length)
            return message

        for i in range(NUM_TESTS):
            seed = random.randint(0, 1000)
            length = random.randint(1000, 20000)
            msg = create_random_message(seed, length)
            assert len(msg) == length and all([c in msg for c in "0123"])

    def test_binomial_random_message(self):

        def create_binomial_message(p, seed, length):
            (_, message, _) = self.d.generateBinomialRandomMessage(p=p,
                                                                   seed=seed,
                                                                   limit=length)
            return message


        for i in range(NUM_TESTS):
            p = 0.5
            seed = random.randint(0, 1000)
            length = random.randint(1000, 20000)
            msg = create_binomial_message(p, seed, length)
            assert len(msg) == length and all([c in msg for c in "0123"])


    def tearDown(self):
        pass
