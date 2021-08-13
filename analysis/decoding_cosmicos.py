#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 27 21:16:12 2016

@author: joha2

The complexity of this decoder is IMHO a measure
for the simplicity of the message.
Format was taken from an old form of message.

"""

import re
import sys
import math
import numpy as np
import matplotlib.pyplot as plt

import argparse

class DecoderClass(object):

    def __init__(self):
        self.datadict = {}
        self.datacounter = 0
        self.commanddict = {}
        self.commandcounter = 0
        self.defdict = {}
        self.defcounter = 0


    def generateRandomMessage(self, limit=10000):
        print('---------')
        print("Generating random message with limit %d characters" % (limit,))
        np.random.seed(1337)
        preliminary = [str(i) for i in list(np.random.randint(0, 3 + 1, (limit,)))]
        result = ''.join(preliminary)
        return (limit, result)

    def generateBinomialRandomMessage(self, p=0.5, limit=10000):
        print('---------')
        print("Generating binomial distributed message with limit %d characters" % (limit,))
        np.random.seed(1337)
        preliminary = [str(i) for i in list(np.random.binomial(3, p, (limit,)))]
        result = ''.join(preliminary)
        return (limit, result)



    def readStandardTextFromFile(self, filename, limit=10000):
        print('---------')
        print("Reading text from file %s with limit %d characters" % (filename, limit))

        with open(filename,'r') as fl:
            s = fl.read()
        s = " ".join(s.lower().split())  # substituted all \n by spaces
        if limit > 0:
            s = s[0:limit]
        lenmsg = len(s)
        print('---------')
        return (lenmsg, s)


    def readMessage(self, filename, limit=10000):
        print('---------')
        print("Reading message from file %s with limit %d characters" % (filename, limit))

        fl = open(filename,'r')
        self.origmsgtext = fl.read()
        fl.close()
        self.msgtext = re.sub(r'[\n]+', '', self.origmsgtext) # remove end line symbols
        if limit > 0:
            self.msgtext = self.msgtext[0:limit]
        lenmsg = len(self.msgtext)
        print('---------')
        return lenmsg


    def performStatistics(self, msgtext, lets, maxlen=2):

        print("msglen %d" % (len(msgtext),))

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
                print('empty matching for %s at length %d' % (letters, kp))
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
                print("h(\'%c\') = %f" % (mon, -hmon*math.log(hmon, numletters)))
                hsum += -hmon*math.log(hmon, numletters)
                print("hsum = %f" % (hsum,))

            numdigrams = len(digrams)
            hsumdi = 0.0
            for (di, hdi) in digrams:
                print("h(\'%s\') = %f" % (di, -hdi*math.log(hdi, numdigrams)))
                hsumdi += -hdi*math.log(hdi, numdigrams)
            print("hsumdi = %f" % (hsumdi,))

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
                print(wd)

            print("%d %f" % (ind+1, hsumn))
            entropyngramlist.append([ind+1, hsumn])
        return(entropyngramlist)

    def preparePyPM(self, outputfile):
        outputmsgtext = re.sub(r'2233', '\n', self.msgtext)

        outputmsgtext = re.sub(r'([0123]{1})', r'\1 ', outputmsgtext)

        fo = open(outputfile, 'w')
        fo.write(outputmsgtext)
        fo.close()


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
        print(sorted(worddict.items()))
        ranklist = [pair for pair in sorted(worddict.items(),
                                            key=lambda word, rank: rank, reverse=True)]

        if rankcutoff > 0:
            ranklist = ranklist[0:rankcutoff]



        freqranking = np.array([(k+1, float(i)/float(lenmodifiedmsg))
            for (k, (w, i)) in enumerate(ranklist)])

        log10freqranking = np.log10(freqranking)

        [decreasing, intersection] = np.lib.polynomial.polyfit(log10freqranking[:,0],log10freqranking[:,1],1)

        return (freqranking, decreasing, intersection)


    def doesItObeyZipfsLaw(self, textlist, delimiterlist, wordrelist, colorlist_points, colorlist_fits, rankcutoff=100):

        print("Printing word frequency over ordered by frequency rank.")
        print("This obviously relies on the correct choice of delimiter symbols.")
        print("This should give a power law according to Zipf\'s law.")

        fig = plt.figure(1)
        ax = fig.add_subplot(111)

        ax.axis('equal')

        ax.set_yscale('log')
        ax.set_xscale('log')

        ax.set_xlabel('rank # according to frequency (-> decreasing frequency)')
        ax.set_ylabel('word frequency')

        texts_to_analyse = [self.msgtext] + textlist
        delimiters_to_use = [r'[23]+'] + delimiterlist
        wordres_to_use = [r'[01]+'] + wordrelist
        colorlist_points_to_use = ['r'] + colorlist_points
        colorlist_fits_to_use = ['r'] + colorlist_fits

        for (text, delimiters, wordre, color_points, color_fits) in zip(texts_to_analyse, delimiters_to_use, wordres_to_use, colorlist_points_to_use, colorlist_fits_to_use):

            (freqranking, decreasing, intersection) = self.performFrequencyRankOrderingAndFit(text, delimiters, wordre, rankcutoff)

            # formulas for the log-log plot
            # y = a*x^b
            # log10 y = log10 a + b*log10 x

            xfit = np.linspace(freqranking[0, 0], freqranking[-1, 0], 100)
            yfit = 10.0**intersection*np.power(xfit, decreasing)


            ax.set_title('Zipf\'s Law y = a*x^b')

            print('a = %f, b = %f' % (10.0**intersection, decreasing))
            print(freqranking)

            ax.plot(freqranking[:, 0], freqranking[:, 1], color_points+'.', xfit, yfit, color_fits)


        try:
            plt.show()
        except ValueError:
            print('something wrong with values in log plot')


    def showGraphicalRepresentation(self, width=128):

        msgtext = self.msgtext
        lenmsg = len(msgtext)

        numlines = lenmsg/width
        numoverhead = lenmsg % width
        padding = width - numoverhead

        msgtext += "".join(['X' for i in range(padding)])

        floatmsg = []
        for c in msgtext:
            if c != 'X':
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

    def showGraphicalRepresentationLineTerminal(self, terminalsymbol='2233', maxlen=1000):

        msgtext = self.msgtext

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
                print("truncated line %d" % (linnum,))
                paddedline = line[:width]
            tmplist = []
            for c in paddedline:
                if c != 'X':
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



    def guessShortControlSymbols(self, maxlen=5):
        print('---------')
        print('Guessing control symbols by counting')
        print('every occurence of strings of fixed')
        print('length up to %d characters. Are these (nearly)' % (maxlen,))
        print('identical for two strings, there is a high chance')
        print('that these are delimiters of blocks. They may not occur at a higher')
        print('level together, to be delimiters. A single occurence')
        print('will not be shown.')
        for k in range(maxlen):
            wordlength = k+1
            pk = re.compile(r'[0-3]{'+str(wordlength)+'}')
            nk = pk.findall(self.msgtext)

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
                print("%d-char strings: %s" % (wordlength, occur))
        print('--------')


    def decodeLine(self, linetext, leftdelimiter='', rightdelimiter=''):

        scanner=re.Scanner([
            (r"2032[01]+3", lambda scanner, token: ("DEFINITION", token[4:-1])),
            (r"2[01]+3*", lambda scanner, token: ("DATA", token[1:-1])),
            (r"2[0123]+3*", lambda scanner, token: ("NESTED_COMMAND", token[1:-1])),
            (r"023", lambda scanner, token: ("HASPROPERTY", token))
        ])

        (results, remain) = scanner.scan(linetext)

        # the first data cell in the line is typically a command

        if linetext != '':
            if results[0][0] == 'DATA':
                results[0] = ('COMMAND', results[0][1])

        # now add commands and definitions to dictionaries

        for w in results:
            if w[0] == 'DEFINITION':
                if  self.defdict.get(w[1]) == None:
                    self.defdict[w[1]] = 'DEFINITION' + str(self.defcounter)
                    self.defcounter += 1
            if w[0] == 'COMMAND':
                if  self.defdict.get(w[1]) == None:
                    print("ERROR COMMAND NOT DEFINED (%s); INSERTING INTO DEFINITION DICT\n" % (w[1],))
                    self.defdict[w[1]] = 'DEFINITION' + str(self.defcounter)
                    self.defcounter += 1
            if w[0] == 'DATA':
                if  self.datadict.get(w[1]) == None:
                    self.datadict[w[1]] = 'DATA' + str(self.datacounter)
                    self.datacounter += 1


        # is there something remaining which is not covered by our pattern matching?
        if remain != '':
            print('CANNOT INTERPRET %s \n' % (remain,))

        return results

    def parseBlock(self, leftdelimiter='', rightdelimiter='', eol=''):
        print('--------')
        print("Using leftdelimiter '%s', rightdelimiter '%s', EOL '%s'" % (leftdelimiter, rightdelimiter, eol))

        modifiedmsg = self.msgtext

        if eol!='':
            modifiedmsg = re.sub(eol, '\n', modifiedmsg)

        modifiedmsg = modifiedmsg.split('\n')

        decoded = [self.decodeLine(line, leftdelimiter, rightdelimiter) for line in modifiedmsg]



        print('--------')
        return decoded

    def decodeBlock(self, parsedBlocks):
        print('decoding blocks ...')
        lines = []
        for line in parsedBlocks:
            linestring = ''

            for parsedPair in line:
                if parsedPair[0] == 'DEFINITION':
                    linestring += 'DEFINITION ' + self.defdict[parsedPair[1]] + ' '
                if parsedPair[0] == 'COMMAND':
                    linestring += 'COMMAND ' + self.defdict[parsedPair[1]] + ' '
                if parsedPair[0] == 'DATA':
                    linestring += self.datadict[parsedPair[1]] + ' '
                if parsedPair[0] == 'HASPROPERTY':
                    linestring += 'HASPROPERTY '
                if parsedPair[0] == 'NESTED_COMMAND':
                    linestring += 'NESTED_COMMAND ' + parsedPair[1]
            lines.append(linestring)
        return lines


    def plotNGramEntropy(self, entlengtharrays, colors, labels):
        fig = plt.figure(1)
        ax = fig.add_subplot(111)

        ax.set_xlabel('n-gram length')
        ax.set_ylabel('Shannon-Boltzmann entropy')

        for (data, color, l) in zip(entlengtharrays, colors, labels):

            ax.plot(data[:, 0], data[:, 1], '-', color=color)

        ax.legend(labels, loc='lower right')

        plt.show()


def main(args_from_argsparse):

    print(args_from_argsparse)

    d = DecoderClass()

    (msglen, randomtext) = d.generateRandomMessage(limit=60000)
    (mlenb1, binomialtext1) = d.generateBinomialRandomMessage(p=0.1, limit=600000)
    #(mlenb2, binomialtext2) = d.generateBinomialRandomMessage(p=0.2, limit=600000)
    #(mlenb3, binomialtext3) = d.generateBinomialRandomMessage(p=0.3, limit=600000)
    #(mlenb4, binomialtext4) = d.generateBinomialRandomMessage(p=0.5, limit=600000)

    #(txtlen, mobytext) = d.readStandardTextFromFile("../moby_dick.txt", limit=0)
    #(metilen, metitext) = d.readStandardTextFromFile("../meti.txt", limit=0)
    d.readMessage(args_from_argsparse.files[0], limit=0)

    #d.doesItObeyZipfsLaw([randomtext], [r'[23]+'], [r'[01]+'], ['g'], ['g'])
    # check various texts or messages for their ranked frequency content

    #d.showGraphicalRepresentation(width=512)
    #d.showGraphicalRepresentationLineTerminal(maxlen=128)
    #d.guessShortControlSymbols(maxlen=2)
    #res = d.parseBlock(leftdelimiter='2', rightdelimiter='3', eol='2233')
    #d.decodeBlock(res)

    #mobytext = re.sub(r'\n', '', mobytext) # remove punctuation

    #metitext = re.sub(r'[ \n]+', '', metitext)

    #wmeti = metitext.split()
    #encodedmeti = ''
    #metidict = {}
    #count = 0
    #for w in wmeti:
    #    cdstr = ''
    #    if metidict.get(w) == None:
    #        metidict[w] = count
    #        cdstr = hex(count)[2:]
    #        count += 1
    #    else:
    #        cdstr = hex(metidict[w])[2:]
    #    lcdstr = len(cdstr)
    #    if lcdstr < 4:
    #        cdstr = (''.join(['0' for i in range(4-lcdstr)])) + cdstr
    #    encodedmeti += cdstr

    randomtext2 = "".join([str(v) for v in (np.fromfile("./rnd60kb.bin", dtype="uint8") % 4).tolist()])

    Srnd = np.array(d.performStatistics(randomtext, '0123', maxlen=100))
    Srnd2 = np.array(d.performStatistics(randomtext2, '0123', maxlen=100))
    Sbinomial1 = np.array(d.performStatistics(binomialtext1, '0123', maxlen=100))
    #Sbinomial2 = np.array(d.performStatistics(binomialtext2, '0123', maxlen=100))
    #Sbinomial3 = np.array(d.performStatistics(binomialtext3, '0123', maxlen=100))
    #Sbinomial4 = np.array(d.performStatistics(binomialtext4, '0123', maxlen=100))
    Scos = np.array(d.performStatistics(d.msgtext, '0123', maxlen=100))
    #Smoby = np.array(d.performStatistics(mobytext, '0123456789abcdefghijklmnopqrstuvwxyz', maxlen=100))
    #Smeti = np.array(d.performStatistics(metitext, '01234567', maxlen=100))

    d.plotNGramEntropy([Srnd,
                        Srnd2,
                        Sbinomial1,
                        #Sbinomial2,
                        #Sbinomial3,
                        #Sbinomial4,
                        Scos,
                        #Smoby,
                        #Smeti
                        ],
                       ['r',
                       r'#000000',
                       r'#220000',
                       #r'#440000',
                       #r'#880000',
                       'g',
                       'b',
                       'm'],
                        ['Random text (uniformly distributed 0123)',
                         'Random text (uniformly distributed 0123)',
                        'Random text (binomial distributed 0123 p=0.1)',
                        #'Random text (binomial distributed 0123 p=0.2)',
                        #'Random text (binomial distributed 0123 p=0.3)',
                        #'Random text (binomial distributed 0123 p=0.5)',
                        'CosmicOS',
                        'Moby Dick (lowercase + numbers)', 'METI (dearet.org, removed space and \\n)'])

    # used later for automated process analysis
    #d.preparePyPM('lm.txt')

if __name__ == '__main__':
    program_description ="""
    Analyse different text files (including the message file from
    CosmicOS) from the perspective of different measures of information.
    This is to be thought as a naive investigation whether such a
    peace of information contains a message and if possible to derive
    the format of the message.
    """
    parser = argparse.ArgumentParser(description=program_description)
    parser.add_argument("--files", metavar="file", type=str, nargs="+",
                        help="a file to be analysed")
    parser.add_argument("--ngram", action="store_true",
                        help="show ngram entropy for files")
    parser.add_argument("--zipf", action="store_true",
                        help="show whether files obey Zipf's law")
    parser.add_argument("--linerep", type=int, default=512,
                        help="show line representation of files (length int)")
    parser.add_argument("--generate", #choices=["uniform", "binomial"],
                        nargs="*",
                        help="show generated distributions together with files")
    # TODO: decompose into binomial, uniform with different parameters
    parser.add_argument("--genmsglength", type=int, default=10000,
                        help="cutoff length of generated message")
    parser.add_argument("--filmsglength", type=int, default=0,
                        help="cutoff length of file message")

    args = parser.parse_args()

    main(args)




