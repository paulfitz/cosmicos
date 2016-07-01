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

    def doesItObeyZipfsLaw(self, delimsymbols):
        
        print("Printing word frequency over word length.")
        print("This obviously relies on the correct choice of delimiter symbols.")
        print("This should give a power law according to Zipf\'s law.")        
        
        modifiedmsg = re.sub(delimsymbols, ' ', self.msgtext)
        pwords = re.compile(r'[01]+') # usually \w+ but we have digits instead of letters
        wordlist = pwords.findall(modifiedmsg)

        worddict = {}
        for w in wordlist:
            if worddict.get(w) == None:
                worddict[w] = 1
            else:
                worddict[w] += 1
                
        ranklist = [pair for pair in sorted(worddict.items(), key=lambda (word, rank): rank)]
        
        lengthranking = np.array([(len(w), i) for (w, i) in ranklist])
        
        
        fig = plt.figure(1)
        ax = fig.add_subplot(111)

        ax.axis('equal')
        #ax.set_axis_bgcolor('black')        

        ax.set_yscale('log')
        ax.set_xscale('log')
        
        ax.plot(lengthranking[:, 0], lengthranking[:, 1], '.', color='r')

        plt.show()        

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
    
    msglen = d.readMessage(argv[1], limit=0)
    d.doesItObeyZipfsLaw('[23]+')

    # message at the actual version is somehow not correctly encoded

    #d.guessShortControlSymbols(maxlen=4)
    #res = d.parseBlock(leftdelimiter='2', rightdelimiter='3', eol='2233')
    #decodedlines = d.decodeBlock(res)

    print('dictionaries ....')
    print(d.commanddict)
    print(d.datadict)
    print(d.defdict)

    
if __name__ == '__main__':
    main(sys.argv)    
    
        
            
            
