#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 27 21:16:12 2016

@author: joha2

The complexity of this decoder is IMHO a measure for the simplicity of the message.
Format was taken from an old form of message.

"""

import re
import sys
import numpy as np
import matplotlib.pyplot as plt

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
        preliminary = [str(i) for i in list(np.random.random_integers(0, 3, (limit,)))]
        self.origmsgtext = ''.join(preliminary)
        self.msgtext = self.origmsgtext
        return (limit, self.msgtext)
        
    def readStandardTextFromFile(self, filename, limit=10000):
        print('---------')
        print("Reading text from file %s with limit %d characters" % (filename, limit))
        
        fl = open(filename,'r')
        s = fl.read()
        s.lower()
        fl.close()
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
        
        
    def performFrequencyRankOrderingAndFit(self, msgtext, delimsymbols, wordre):
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
                
        ranklist = [pair for pair in sorted(worddict.items(), key=lambda (word, rank): rank)]
        ranklist.reverse()        
        
        freqranking = np.array([(k+1, float(i)/float(lenmodifiedmsg)) 
            for (k, (w, i)) in enumerate(ranklist)])
        
        log10freqranking = np.log10(freqranking)
        
        [decreasing, intersection] = np.lib.polynomial.polyfit(log10freqranking[:,0],log10freqranking[:,1],1)

        return (freqranking, decreasing, intersection)


    def doesItObeyZipfsLaw(self, textlist, delimiterlist, wordrelist, colorlist_points, colorlist_fits):
        
        print("Printing word frequency over ordered by frequency rank.")
        print("This obviously relies on the correct choice of delimiter symbols.")
        print("This should give a power law according to Zipf\'s law.")        

        fig = plt.figure(1)
        ax = fig.add_subplot(111)

        ax.axis('equal')
        #ax.set_axis_bgcolor('black')        

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
            
            (freqranking, decreasing, intersection) = self.performFrequencyRankOrderingAndFit(text, delimiters, wordre)        
        
            # y = a*x^b
            # log10 y = log10 a + b*log10 x

            xfit = np.linspace(freqranking[0, 0], freqranking[-1, 0], 100)
            yfit = 10.0**intersection*np.power(xfit, decreasing)
        
       
            ax.set_title('Zipf\'s Law y = a*x^b')
        
            print('a = %f, b = %f' % (10.0**intersection, decreasing))        
        
            ax.plot(freqranking[:, 0], freqranking[:, 1], color_points+'.', xfit, yfit, color_fits)

        plt.show()

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
                floatmsg.append(NaN)

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

        #plt.show()
       
    def showGraphicalRepresentationLineTerminal(self, terminalsymbol='2233', maxlen=1000):

        msgtext = self.msgtext
        lenmsg = len(msgtext)

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
            
        howmanypixel = int(ceil(float(howmanylines)/float(width)))
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
                    tmplist = tmplist + [NaN for i in range(howmanypixel)]
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

        #ax.axis([0, width, 0, numlines+1])        
        
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
            (r"2132[01]+3", lambda scanner, token: ("DEFINITION", token[4:-1])),
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
            #print(linestring)
            lines.append(linestring)
        return lines
        

def main(argv):
   
    if len(argv) != 2:
        print("Shows a few properties of the message:")
        print("string frequencies -- to determine delimiters")
        print("graphics -- fulfillment of Zipf's law")
        print("preliminary decoding -- as far as possible")
        print("dictionaries -- of commands, data, ...")
        print("%s msgfile\n" % (argv[0],))
        return

    d = DecoderClass()    
    
    (msglen, randomtext) = d.generateRandomMessage(limit=600000)
    #(txtlen, mobytext) = d.readStandardTextFromFile("../moby_dick.txt", limit=0)
    msglen = d.readMessage(argv[1], limit=0)
    
    d.doesItObeyZipfsLaw([randomtext], [r'[23]+'], [r'[01]+'], ['g'], ['g'])
    # check various texts or messages for their ranked frequency content    
    
    d.showGraphicalRepresentation(width=512)
    
    d.showGraphicalRepresentationLineTerminal(maxlen=128)

    # message at the actual version is somehow not correctly encoded

    d.guessShortControlSymbols(maxlen=4)
    res = d.parseBlock(leftdelimiter='2', rightdelimiter='3', eol='2233')
    decodedlines = d.decodeBlock(res)

    #print('dictionaries ....')
    #print(d.commanddict)
    #print(d.datadict)
    #print(d.defdict)

    
if __name__ == '__main__':
    main(sys.argv)    
    
        
            
            
