#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 27 21:16:12 2016

@author: joha2

The complexity of this decoder is IMHO a measure for the simplicity of the message.
Format was taken from an old form of message.

"""

import re
import numpy as np
import sys

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
        origmsgtext = fl.read()
        fl.close()
        msgtext = re.sub(r'[\n]+', '', origmsgtext) # remove end line symbols
        if limit > 0:
            msgtext = msgtext[0:limit]
        lenmsg = len(msgtext)
        print('---------')
        return (origmsgtext, msgtext, lenmsg)

    def guessShortControlSymbols(self, msgtext, maxlen=5):
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
            nk = pk.findall(msgtext)
            
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

    def parseBlock(self, msgtext, leftdelimiter='', rightdelimiter='', eol=''):
        print('--------')
        print("Using leftdelimiter '%s', rightdelimiter '%s', EOL '%s'" % (leftdelimiter, rightdelimiter, eol))    
    
        modifiedmsg = msgtext    
    
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
                    linestring += 'NESTED ' + parsedPair[1]
            print(linestring)
            lines.append(linestring)
        return lines
        

def main(argv):
   
    if len(argv) != 2:
        print("%s msgfile\n" % (argv[0],))
        return

    d = DecoderClass()    
    
    (origmsg, msg, msglen) = d.readMessage(argv[1], limit=10000)
    d.guessShortControlSymbols(msg, maxlen=4)
    res = d.parseBlock(msg, leftdelimiter='2', rightdelimiter='3', eol='2233')
    #for line in res:
    #    print(line)

    decodedlines = d.decodeBlock(res)
    #print(decodedlines)

    print('dictionaries ....')
    print(d.commanddict)
    print(d.datadict)
    print(d.defdict)

    
if __name__ == '__main__':
    main(sys.argv)    
    
        
            
            
