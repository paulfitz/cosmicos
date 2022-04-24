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


class TestMessagesEntropy(unittest.TestCase):

    def setUp(self):
        self.d = DecoderClass(logging.getLogger("entropy test"))

    def test_empty_text_word_lengths(self):
        # empty message and zero word length gives empty list
        assert len(self.d.performStatistics("", "0123", maxlen=0)) == 0
        # some message and zero word length gives empty list
        assert len(self.d.performStatistics("0000", "0123", maxlen=0)) == 0
        # empty message and non-zero word length gives non-empty list
        assert len(self.d.performStatistics("", "0123", maxlen=10)) == 10

    def test_zero_entropy(self):
        for i in range(NUM_TESTS):
            text_length = random.randint(0, 100)
            max_length = random.randint(0, 20)
            statistics = self.d.performStatistics("0"*text_length,
                                                  "0123",
                                                  maxlen=max_length)
            # check numbers of word lengths
            assert(tuple([number for (number, _) in statistics]) ==\
                   tuple(range(1, max_length+1)))
            # check entropy zero
            assert all([abs(value) < 1e-15 for (_, value) in statistics])

    def test_high_entropy(self):
        for i in range(NUM_TESTS):
            text_length = random.randint(1000, 10000)
            (_, text, _) = self.d.generateRandomMessage(limit=text_length)
            max_length = random.randint(0, 20)
            statistics = self.d.performStatistics(text,
                                                  "0123",
                                                  maxlen=max_length)
            # check numbers of word lengths
            assert(tuple([number for (number, _) in statistics]) ==\
                   tuple(range(1, max_length+1)))
            # check entropy > 0.95
            assert all([abs(value) > 0.95 for (_, value) in statistics])


    def tearDown(self):
        pass
