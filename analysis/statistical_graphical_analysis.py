#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 27 21:16:12 2016

@author: joha2

The complexity of this decoder is IMHO a measure
for the simplicity of the message.
Format was taken from an old form of message.

20220415:
    - removed decoding stuff (only statistical and graphical analysis needed)
    - added command line switches
    - cleaned up file
20160627:
    - played around a bit with message
    - added Zipf's law analysis
    - added N-gram entropy analysis

"""

import re
import sys
import math
import numpy as np
import matplotlib.pyplot as plt
import logging
from operator import itemgetter

import argparse

class DecoderClass:

    def __init__(self, logger):
        self.datadict = {}
        self.datacounter = 0
        self.commanddict = {}
        self.commandcounter = 0
        self.defdict = {}
        self.defcounter = 0
        self.logger = logger

    def convert_args_to_string(self, *args):
        return " ".join([str(a) for a in args])

    def info(self, *args):
        self.logger.info(self.convert_args_to_string(*args))

    def debug(self, *args):
        self.logger.debug(self.convert_args_to_string(*args))

    def error(self, *args):
        self.logger.error(self.convert_args_to_string(*args))


    def generateRandomMessage(self, seed=1337, limit=10000):
        self.info('---------')
        self.info("Generating random message with limit %d characters" % (limit,))
        np.random.seed(seed)
        preliminary = [str(i) for i in list(np.random.randint(0, 3 + 1, (limit,)))]
        result = ''.join(preliminary)
        return (limit, result, {"type": "random", "seed": seed})

    def generateBinomialRandomMessage(self, p=0.5, seed=1337, limit=10000):
        self.info('---------')
        self.info("Generating binomial distributed message with limit %d characters" % (limit,))
        np.random.seed(seed)
        preliminary = [str(i) for i in list(np.random.binomial(3, p, (limit,)))]
        result = ''.join(preliminary)
        return (limit, result, {"type": "binomial", "seed": seed, "p": p})



    def readStandardTextFromFile(self, filename, limit=10000):
        self.info('---------')
        self.info("Reading text from file %s with limit %d characters" % (filename, limit))

        with open(filename,'r') as fl:
            s = fl.read()
        s = " ".join(s.lower().split())  # substituted all \n by spaces
        if limit > 0:
            s = s[0:limit]
        lenmsg = len(s)
        self.info('---------')
        return (lenmsg, s, {"type": "standardtext", "filename": filename})


    def readMessage(self, filename, limit=10000):
        self.info('---------')
        self.info("Reading message from file %s with limit %d characters" % (filename, limit))

        with open(filename,'rt') as fl:
            self.origmsgtext = fl.read()

        self.msgtext = "".join(self.origmsgtext.split()) # remove end line symbols
        if limit > 0:
            self.msgtext = self.msgtext[0:limit]
        lenmsg = len(self.msgtext)
        self.info('---------')
        return (lenmsg, self.msgtext, {"type": "message", "filename": filename})


    def performStatistics(self, msgtext, lets, maxlen=2):

        self.info("msglen %d" % (len(msgtext),))

        printentropies = False

        letters = r'['+lets+']'
        numletters = len(lets)
        worddict = {}
        ngramlist = []
        for k in range(maxlen):
            worddictngram = {}
            kp = k + 1
            pattern = re.compile(letters+"{"+str(kp)+"}")
            matchedpattern = re.findall(pattern, msgtext)

            if matchedpattern == []:
                self.debug('empty matching for %s at length %d' % (letters, kp))
            numpatterns = len(matchedpattern)

            for w in matchedpattern:
                if worddict.get(w) == None:
                    worddict[w] = 1.0/numpatterns
                else:
                    worddict[w] += 1.0/numpatterns

                if worddictngram.get(w) == None:
                    worddictngram[w] = 1.0/numpatterns
                else:
                    worddictngram[w] += 1.0/numpatterns

            ngramlist.append(worddictngram)

        if printentropies:
            digrams = []
            monograms = []
            for (gr, hgr) in worddict.items():
                if len(gr) == 2:
                    digrams.append((gr, hgr))
                if len(gr) == 1:
                    monograms.append((gr, hgr))

            hsum = 0.0
            for (mon, hmon) in monograms:
                self.debug("h(\'%c\') = %f" % (mon, -hmon*math.log(hmon, numletters)))
                hsum += -hmon*math.log(hmon, numletters)
                self.debug("hsum = %f" % (hsum,))

            numdigrams = len(digrams)
            hsumdi = 0.0
            for (di, hdi) in digrams:
                self.debug("h(\'%s\') = %f"
                           % (di, -hdi*math.log(hdi, numdigrams)))
                hsumdi += -hdi*math.log(hdi, numdigrams)
            self.debug("hsumdi = %f" % (hsumdi,))

        entropyngramlist = []
        for (ind, wd) in enumerate(ngramlist):

            hsumn = 0.0
            numngrams = len(wd)

            for (ngram, hn) in wd.items():
                sn = 0.0
                if numngrams > 1 and hn != 0:
                    sn = -hn*math.log(hn, numngrams)
                hsumn += sn

            if hsumn < 1e-6:
                self.debug(wd)

            self.debug("%d %f" % (ind+1, hsumn))
            entropyngramlist.append([ind+1, hsumn])
        return(entropyngramlist)

    def performFrequencyRankOrderingAndFit(self, msgtext, delimsymbols, wordre, rankcutoff=100):
        modifiedmsg = re.sub(delimsymbols, ' ', msgtext)
        lenmodifiedmsg = len(modifiedmsg)
        pwords = re.compile(wordre) # usually \w+ but we have digits instead of letters
        wordlist = pwords.findall(modifiedmsg)

        worddict = {}
        for w in wordlist:
            if worddict.get(w) == None:
                worddict[w] = 1
            else:
                worddict[w] += 1
        self.debug(sorted(worddict.items()))
        ranklist = [pair for pair in sorted(worddict.items(),
                                            key=itemgetter(1), reverse=True)]
        # sort by rank

        if rankcutoff > 0:
            ranklist = ranklist[0:rankcutoff]



        freqranking = np.array([(k+1, float(i)/float(lenmodifiedmsg))
            for (k, (w, i)) in enumerate(ranklist)])

        log10freqranking = np.log10(freqranking)

        [decreasing, intersection] = np.lib.polynomial.polyfit(log10freqranking[:,0],log10freqranking[:,1],1)

        return (freqranking, decreasing, intersection)


    def doesItObeyZipfsLaw(self, textlist,
                           delimiterlist,
                           wordrelist,
                           colorlist_points,
                           colorlist_fits,
                           labels,
                           rankcutoff=100):

        self.info("Printing word frequency over ordered by frequency rank.")
        self.info("This obviously relies on the correct choice of delimiter symbols.")
        self.info("This should give a power law according to Zipf\'s law.")

        fig = plt.figure()
        ax = fig.add_subplot(111)

        ax.axis('equal')

        ax.set_yscale('log')
        ax.set_xscale('log')

        ax.set_xlabel('rank # according to frequency (-> decreasing frequency)')
        ax.set_ylabel('word frequency')

        # self.msgtext: [r'[23]+'], [r'[01]+'], r, r
        texts_to_analyse = textlist
        delimiters_to_use = delimiterlist
        wordres_to_use = wordrelist
        colorlist_points_to_use = colorlist_points
        colorlist_fits_to_use = colorlist_fits

        for (text, delimiters, wordre, color_points, color_fits) \
            in zip(texts_to_analyse,
                   delimiters_to_use,
                   wordres_to_use,
                   colorlist_points_to_use,
                   colorlist_fits_to_use):

            (freqranking, decreasing, intersection) =\
                self.performFrequencyRankOrderingAndFit(text,
                                                        delimiters,
                                                        wordre,
                                                        rankcutoff)

            # formulas for the log-log plot
            # y = a*x^b
            # log10 y = log10 a + b*log10 x

            xfit = np.linspace(freqranking[0, 0], freqranking[-1, 0], 100)
            yfit = 10.0**intersection*np.power(xfit, decreasing)


            ax.set_title('Zipf\'s Law y = a*x^b')

            self.info('a = %f, b = %f' % (10.0**intersection, decreasing))
            self.debug(freqranking)

            ax.scatter(freqranking[:, 0], freqranking[:, 1], color=color_points)
            ax.plot(xfit, yfit, color_fits)

        ax.legend(labels, loc='lower right')


        try:
            plt.show()
        except ValueError:
            self.error('something wrong with values in log plot')


    def showGraphicalRepresentation(self, msgtext, width=128):

        lenmsg = len(msgtext)

        numlines = lenmsg//width
        numoverhead = lenmsg % width
        padding = width - numoverhead

        msgtext += "".join(['X' for i in range(padding)])

        floatmsg = []
        for c in msgtext:
            if c != 'X' and c != " ":
                floatmsg.append(float(c))
            else:
                floatmsg.append(np.NaN)

        nummsgtext = np.array(floatmsg)


        Data = nummsgtext.reshape((numlines+1, width))


        nx, ny = width, numlines+1
        x = range(nx)
        y = range(ny)

        X, Y = np.meshgrid(x, y)

        fig = plt.figure()
        ax = fig.add_subplot(111)

        ax.set_xlabel('width')
        ax.set_ylabel('lines')

        ax.set_title('Graphical Representation of Message')

        ax.imshow(Data, interpolation='None')

    def showGraphicalRepresentationLineTerminal(self, msgtext, terminalsymbol='2233', maxlen=1000):

        # split msg at terminalsymbol
        # fill all lines up with X until length of longest line
        # convert into image

        msgtext = re.split(terminalsymbol, msgtext)

        howmanylines = len(msgtext)

        sortedlines = sorted(msgtext, key=lambda line: len(line))

        lengths = sorted([len(l) for l in msgtext])

        print("last 20 lengths: %s" % str(lengths[-20:-1]))

        longestline = sortedlines[-1]

        if maxlen == -1:
            width = len(longestline)
        else:
            width = maxlen

        howmanypixel = int(math.ceil(float(howmanylines)/float(width)))
        # to correct the aspect ratio between length and width

        paddedfloatlines = []
        for (linnum, line) in enumerate(msgtext):
            paddedline = line
            if len(line) < width:
                paddedline = line + (''.join(['X' for i in range(width - len(line))]))
            elif len(line) > width:
                self.debug("truncated line %d" % (linnum,))
                paddedline = line[:width]
            tmplist = []
            for c in paddedline:
                if c != 'X' and c != " ":
                    tmplist = tmplist + [float(c) for i in range(howmanypixel)]
                else:
                    tmplist = tmplist + [np.NaN for i in range(howmanypixel)]
            paddedfloatlines.append(tmplist)
        numlines = len(paddedfloatlines)
        newwidth = len(paddedfloatlines[0])




        Data = np.array(paddedfloatlines)

        nx, ny = newwidth, numlines+1
        x = range(nx)
        y = range(ny)

        X, Y = np.meshgrid(x, y)

        fig = plt.figure()
        ax = fig.add_subplot(111)

        ax.set_xlabel('width')
        ax.set_ylabel('lines')

        ax.set_title('Linewise Graphical Representation of Message')

        ax.imshow(Data, interpolation='None')

    def guessShortControlSymbols(self, text, maxlen=5):
        self.info('---------')
        self.info('Guessing control symbols by counting')
        self.info('every occurence of strings of fixed')
        self.info('length up to %d characters. Are these (nearly)' % (maxlen,))
        self.info('identical for two strings, there is a high chance')
        self.info('that these are delimiters of blocks. They may not occur at a higher')
        self.info('level together, to be delimiters. A single occurence')
        self.info('will not be shown.')
        for k in range(maxlen):
            wordlength = k+1
            pk = re.compile(r'[0-3]{'+str(wordlength)+'}')
            nk = pk.findall(text)

            nkdict = {}
            for wk in nk:
                try:
                    nkdict[wk] += 1
                except KeyError:
                    nkdict[wk] = 1

            sortednkdict = sorted(nkdict.items(), key=lambda pair: pair[1])
            occur = []
            for (w, i) in sortednkdict:
                if i > 1:
                    occur.append((w,i))
            if occur != []:
                self.info("%d-char strings: %s" % (wordlength, occur))
        self.info('--------')

    def plotNGramEntropy(self, entlengtharrays, colors, labels):
        fig = plt.figure()
        ax = fig.add_subplot(111)

        ax.set_xlabel('n-gram length')
        ax.set_ylabel('Shannon-Boltzmann entropy')

        for (data, color, l) in zip(entlengtharrays, colors, labels):

            ax.plot(data[:, 0], data[:, 1], '-', color=color)

        ax.legend(labels, loc='lower right')

        plt.show()

def parse_generate_parameter(generate_parameter):
    if generate_parameter is None:
        return []
    else:
        if isinstance(generate_parameter, list):
            return [tuple(x.strip().split())
                    for x in generate_parameter]

def main(args_from_argsparse):

    print(args_from_argsparse)

    generate_lengthlimit = args_from_argsparse.genmsglength
    file_lengthlimit = args_from_argsparse.filmsglength
    generate_list = parse_generate_parameter(args_from_argsparse.generate)
    message_file_no = args_from_argsparse.messagenumber

    MAX_NGRAM_LENGTH = 100
    analyse_chars_list = args_from_argsparse.messagechars.split()
    verbose = args_from_argsparse.verbose
    if verbose:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.INFO)

    showgraphical = args_from_argsparse.graphical

    d = DecoderClass(logging.getLogger("analysis"))

    statistics_list = []  # list of texts to analyze

    # first grab texts from articially generated ones
    for generate_tuple in generate_list:
        if len(generate_tuple) > 0:
            type_of_generation = generate_tuple[0].lower()
            if type_of_generation == "random":
                if len(generate_tuple) == 1:
                    seed = 1337
                else:
                    (_, seed, *rest) = generate_tuple
                    try:
                        seed = int(seed)
                    except ValueError:
                        print("ERROR: value " + seed + " is no valid float number!")
                statistics_list.append(
                    d.generateRandomMessage(limit=generate_lengthlimit,
                                            seed=seed))
            elif type_of_generation == "binomial":
                if len(generate_tuple) > 1:
                    (_, p, *rest) = generate_tuple
                    if len(rest) >= 1:
                        (seed, *_) = rest
                    else:
                        seed = 1337
                    try:
                        p = float(p)
                        seed = int(seed)
                    except ValueError:
                        print("ERROR: value " + str(p) + " is no valid float number " +
                              "or value " + str(seed) + " is no valid int number!")
                    else:
                        statistics_list.append(
                            d.generateBinomialRandomMessage(
                                p=p, limit=generate_lengthlimit, seed=seed))
            else:
                print("ERROR: unknown type \"" + type_of_generation + "\"")

    # second grab texts from provided text files
    for (parsed_filename_no, parsed_filename) in enumerate(args_from_argsparse.files):
        try:
            if parsed_filename_no == message_file_no:
                statistics_list.append(
                    d.readMessage(parsed_filename,
                                  limit=file_lengthlimit))
            else:
                statistics_list.append(
                    d.readStandardTextFromFile(parsed_filename,
                                               limit=file_lengthlimit))
        except FileNotFoundError:
            print("ERROR: file not found: " + parsed_filename)

    if len(analyse_chars_list) == 1:
        analyse_chars_list *= len(statistics_list)

    if showgraphical:
        for (length, text, props) in statistics_list:
            d.showGraphicalRepresentation(text,
                                          width=args_from_argsparse.linerep)
            d.showGraphicalRepresentationLineTerminal(text, maxlen=128)

    if args_from_argsparse.guesscontrolsymbols:
        for (_, text, _) in statistics_list:
            d.guessShortControlSymbols(text, maxlen=2)

    if args_from_argsparse.ngram:

        plot_ngram_entropy_plots = []
        plot_ngram_entropy_colors = []
        plot_ngram_entropy_labels = []
        for ((length, text, typedict), analyse_chars) in zip(statistics_list, analyse_chars_list):
            Splot = np.array(
                d.performStatistics(text,
                                    analyse_chars,
                                    maxlen=MAX_NGRAM_LENGTH))
            Scolor = "#" + "".join(
                [hex(x)[2:].zfill(2)
                 for x in np.random.randint(256, size=3).tolist()])
            Slabel = " ".join([k + ": " + str(v) for (k, v) in typedict.items()]).strip()
            Slabel += " (" + analyse_chars + ")"
            plot_ngram_entropy_plots.append(Splot)
            plot_ngram_entropy_colors.append(Scolor)
            plot_ngram_entropy_labels.append(Slabel)

    if args_from_argsparse.zipf:
        d.doesItObeyZipfsLaw([text
                              for (length, text, props) in statistics_list],
                             [r'[23]+']*len(statistics_list),
                             [r'[01]+']*len(statistics_list),
                             plot_ngram_entropy_colors,
                             plot_ngram_entropy_colors,
                             plot_ngram_entropy_labels)

        d.plotNGramEntropy(plot_ngram_entropy_plots,
                           plot_ngram_entropy_colors,
                           plot_ngram_entropy_labels)

    # check various texts or messages for their ranked frequency content
    # analyse chars list can be submitted by arg to the programm
    # but beware: while for 4-char text 0123 is sufficient, for meti
    # you have to use 01234567 and for a normal text e.g.
    # 0123456789abcdefghijklmnopqrstuvwxyz

    # TODO: use PyPM later for automated process analysis

if __name__ == '__main__':
    program_description ="""
    Analyse different text files (including the message file from
    CosmicOS) from the perspective of different measures of information.
    This is to be thought as a naive investigation whether such a
    peace of information contains a message and if possible to derive
    the format of the message.
    """
    parser = argparse.ArgumentParser(description=program_description)
    parser.add_argument("files", metavar="file", type=str, nargs="+",
                        help="a file to be analysed")
    parser.add_argument("--ngram", action="store_true",
                        help="show ngram entropy for files")
    parser.add_argument("--zipf", action="store_true",
                        help="show whether files obey Zipf's law")
    parser.add_argument("--linerep", type=int, default=512,
                        help="show line representation of files (length int)")
    parser.add_argument("--generate",
                        action="append",
                        type=str,
                        help="""
show generated distributions together with files:

    --generate "random"
    --generate "binomial p"
""")
    parser.add_argument("--genmsglength", type=int, default=10000,
                        help="Cutoff length of generated message")
    parser.add_argument("--filmsglength", type=int, default=0,
                        help="Cutoff length of file message")
    parser.add_argument("--messagenumber", type=int, default=0,
                        help="Which filename in the list is the message?")
    parser.add_argument("--messagechars", type=str, default="0123",
                        help="Which chars can occur in the message?" +
                            " Either \"--messagechars 0123\" or " +
                            "space separated strings\"--messagechars 0123 0123"+
                            " ... 01234567\" (no of texts). " +
                            "First generated then files.")
    parser.add_argument("--verbose", action="store_true",
                        help="Increases the debug output.")
    parser.add_argument("--graphical", action="store_true",
                        help="Show graphical representations.")
    parser.add_argument("--guesscontrolsymbols", action="store_true",
                        help="Guess control symbols (aka data delimiters)")

    args = parser.parse_args()

    main(args)

