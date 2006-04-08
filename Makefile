
#DEPFILE = depend_min.txt
#DEPFILE = depend_inc.txt
DEPFILE = depend.txt

JAVAMAIN = COS_JavaMain

SRCDIR = src
TOOLSDIR = tools-src
OBJDIR = obj
BINDIR = bin
MSGDIR = msg
TESTDIR = testing
WWWSRCDIR = www-src
WWWDIR = www


# make the basic message, as a sequence of elementary symbols
default: wrapped.txt

all: depend testall test web icon tar

# test that the message runs as expected
test:
	rm -f $(TESTDIR)/test_all.scm $(TESTDIR)/test_all.txt
	make test_all.txt

# configure to test everything
testall:
	rm -f incremental-test.txt
	@echo test mode set to non-incremental

# configure to test everything beyond a marker
testinc:
	@echo test mode set to incremental | tee incremental-test.txt

# Java pre-test testing
jtest: 
	rm -f $(TESTDIR)/$(JAVAMAIN).txt $(BINDIR)/$(JAVAMAIN).class
	make $(JAVAMAIN).txt

# web pages
web:
	make index.html

icon:
	make iconic-000000.png

depend:
	make Makefile.plan

###############################################################################

BASEDIR = $(shell pwd|sed "s|.*/||")
BASEFILE = $(shell pwd|sed "s|.*/||"|sed "s|\.|\-|g")

VPATH += $(SRCDIR)
VPATH += $(TOOLSDIR)
VPATH += $(OBJDIR)
VPATH += $(MSGDIR)
VPATH += $(TESTDIR)
VPATH += $(WWWSRCDIR)
VPATH += $(WWWDIR)
VPATH += $(BINDIR)


include Makefile.plan


# rules for making the basic CosmicOS code
%.ftz: %.pl
	mkdir -p $(OBJDIR)
	mkdir -p $(MSGDIR)
	mkdir -p $(TESTDIR)
	perl -I$(BINDIR) -I$(SRCDIR) $< > $(OBJDIR)/$@


%.ftz: %.scm
	mkdir -p $(OBJDIR)
	mkdir -p $(MSGDIR)
	mkdir -p $(TESTDIR)
	cp $< $(OBJDIR)/$@


# need BCEL library (http://jakarta.apache.org/bcel/)
%.ftz: %.java Fritzifier.class bin/java-comment.pl
	grep -q "STUB:" $< || ( javac -source 1.4 -classpath /usr/share/java/bcel.jar:.:src $< && \
	java -cp /usr/share/java/bcel.jar:.:src:bin Fritzifier $(basename $<).class && \
	./bin/java-comment.pl $@ $< > tmp.java && mv tmp.java $(OBJDIR)/$@ && \
	rm -f $(basename $<).class && rm -f $@ )
	grep -q "STUB:" $< && ( grep "STUB:" $< | sed "s/^.*: //" | sed "s/ \*\///" | tee $(OBJDIR)/$@ ) || echo -n


# there's an inconsistency in the order of coordinates describing gates
%.ftz: %.gate UnlessDriver.class bin/drawgate-txt.pl bin/drawgate-ppm.pl
	java -cp bin:. UnlessDriver $< | tee $<.tmp
	cat $<.tmp | ./bin/drawgate-txt.pl | sed "s/IMAGE_SRC/IMAGE_SRC=$*.gif/" | sed "s/CIRCUIT_NAME/$*/g" > $(OBJDIR)/$@
	cat $<.tmp | ./bin/drawgate-ppm.pl > $<.ppm
	convert $<.ppm $(OBJDIR)/$*.gif
	rm -f $<.ppm
	rm -f $<.tmp


# pretty-printing the code
%.pp: %.ftz
	grep -q "class COS_" $(OBJDIR)/$(notdir $<) && cp $(OBJDIR)/$(notdir $<) $(OBJDIR)/$(notdir $@) || ./$(BINDIR)/cosmic-pp $(OBJDIR)/$(notdir $<) $(OBJDIR)/$(notdir $@)


.PRECIOUS: %.class

# java utilities - one requires BCEL library
%.class: %.java
	javac -source 1.4 -classpath /usr/share/java/bcel.jar:tools-src:src $<
	mv $(dir $<)/*.class $(BINDIR)

$(JAVAMAIN).txt: $(JAVAMAIN).class
	cd $(BINDIR) && java -ea -cp /usr/share/java/bcel.jar:../$(SRCDIR):../$(BINDIR) $(JAVAMAIN) | tee ../$(TESTDIR)/$(JAVAMAIN).txt

%.cgi: %.cpp
	g++ $< -o $(WWWDIR)/$(notdir $@)

weak-numeric.txt: pp.txt $(BINDIR)/strip-identifiers.pl $(BINDIR)/identifiers.pm
	perl -Ibin $(BINDIR)/strip-identifiers.pl < $(MSGDIR)/$(notdir $<) > $(MSGDIR)/weak-numeric.txt


wrapped.txt: numeric.txt $(BINDIR)/tokenize.pl
	( $(BINDIR)/tokenize.pl < $(MSGDIR)/$(notdir $<) ) > $(MSGDIR)/unwrapped.txt
	$(BINDIR)/renumber.pl < $(MSGDIR)/unwrapped.txt > $(MSGDIR)/renumbered.txt
	$(BINDIR)/wrap.pl < $(MSGDIR)/unwrapped.txt > $(MSGDIR)/$@


numeric.txt: weak-numeric.txt test_all.txt
#	cp $(MSGDIR)/$(notdir $<) $(MSGDIR)/$(notdir $@)
	$(BINDIR)/patch-message.pl $(MSGDIR)/weak-numeric.txt $(TESTDIR)/test_all.txt >  $(MSGDIR)/$(notdir $@)


test_all.scm: weak-numeric.txt pp.txt all.txt $(BINDIR)/fritz.pl
	$(BINDIR)/fritz.pl < $(MSGDIR)/$(notdir $<) > $(TESTDIR)/$(notdir $@) && mv primer.scm $(TESTDIR)
	$(BINDIR)/inc.pl "base" < $(TESTDIR)/test_all.scm > $(TESTDIR)/test_inc.scm


test_all.txt: test_all.scm $(BINDIR)/fritz.scm
	cp $(BINDIR)/fritz.scm $(TESTDIR)
	perl -I$(BINDIR) $(BINDIR)/make-scheme-ids.pl > $(TESTDIR)/identifiers.scm
	cd $(TESTDIR) && ( ( test -e ../incremental-test.txt && ( echo '(disk-restore "base.save")'; echo '(load "test_inc")' ) || echo '(load "test_all")' ) | scheme | tee test_inc.txt )
	test -e incremental-test.txt || cp $(TESTDIR)/test_inc.txt $(TESTDIR)/test_last_all.txt
	test -e incremental-test.txt || echo -n && ( cat $(TESTDIR)/test_last_all.txt $(TESTDIR)/test_inc.txt ) > $(TESTDIR)/$(notdir $@)
	test -e incremental-test.txt || ( cat $(TESTDIR)/test_last_all.txt ) > $(TESTDIR)/$(notdir $@)


color.txt: all.txt pp.txt  $(BINDIR)/colorize.pl
	perl -I$(BINDIR) $(BINDIR)/colorize.pl < $(MSGDIR)/pp.txt > $(MSGDIR)/color.txt

index.html: color.txt template.html COMMENTS.TXT $(BINDIR)/makedoc.pl sound.cgi view.png numeric.txt
	perl -I$(BINDIR) $(BINDIR)/makedoc.pl $(BASEDIR) $(BASEFILE) | tee $(WWWDIR)/index.html
	cd $(WWWDIR) && ../$(BINDIR)/splitdoc.pl < message-verbose.html
	cp $(WWWSRCDIR)/images/*.* $(WWWDIR)
	cp $(MSGDIR)/*.png  $(WWWDIR) || echo -n
	cp $(OBJDIR)/*.gif $(WWWDIR) || echo -n
	cp $(BINDIR)/fritz.scm $(WWWDIR)/fritz.scm.txt
	cp $(TESTDIR)/test_all.txt $(WWWDIR)
	cp $(MSGDIR)/numeric.txt $(WWWDIR)
	cp $(MSGDIR)/wrapped.txt $(WWWDIR)
	test -e cross/sound.cgi && cp cross/sound.cgi $(WWWDIR) || echo -n
	test -e cross/.htaccess && cp cross/.htaccess $(WWWDIR) || echo -n
	chmod a+x $(WWWDIR)/sound.cgi

reconstructed.txt: wrapped.txt $(BINDIR)/reconstruct.pl
	$(BINDIR)/reconstruct.pl < $(MSGDIR)/wrapped.txt > $(MSGDIR)/$(notdir $@)

deconstructed.txt: numeric.txt $(BINDIR)/deconstruct.pl
	$(BINDIR)/deconstruct.pl < $(MSGDIR)/numeric.txt > $(MSGDIR)/$(notdir $@)

check: reconstructed.txt deconstructed.txt
	diff $(MSGDIR)/reconstructed.txt $(MSGDIR)/deconstructed.txt && echo "Final form of message looks sane"


view.png: wrapped.txt
	$(BINDIR)/prep-image.pl < $(MSGDIR)/wrapped.txt > $(MSGDIR)/view.ppm
	convert $(MSGDIR)/view.ppm $(MSGDIR)/view.png
	rm -f $(MSGDIR)/view.ppm

iconic-000000.png: wrapped.txt $(BINDIR)/showchars.pl
	cd $(WWWDIR) && ../$(BINDIR)/showchars.pl < ../$(MSGDIR)/wrapped.txt

install:
	rm -rf $(HOME)/www/cosmic/incoming
	rm -rf $(HOME)/www/cosmic/outgoing
	cd .. && cp -R $(BASEDIR) $(HOME)/www/cosmic/incoming
	mv $(HOME)/www/cosmic/$(BASEDIR) $(HOME)/www/cosmic/outgoing || echo first time
	mv $(HOME)/www/cosmic/incoming $(HOME)/www/cosmic/$(BASEDIR)
	rm -rf $(HOME)/www/cosmic/outgoing


tar:
	rm -f *.tar *.tgz
	rm -f $(WWWDIR)/*.tar $(WWWDIR)/*.tgz
	( cd ..; tar -cvvf $(BASEFILE).tar $(BASEDIR) )
	mv ../$(BASEFILE).tar .
	gzip $(BASEFILE).tar
	mv $(BASEFILE).tar.gz $(WWWDIR)/$(BASEFILE).tgz


configure: 
	make Makefile.plan


Makefile.plan: $(DEPFILE) bin/planner.pl
	$(BINDIR)/planner.pl $(DEPFILE) | tee Makefile.plan

clean:
	rm -f $(OBJDIR)/*.*
	rm -f $(MSGDIR)/*.*
	rm -f $(BINDIR)/*.class
	rm -f $(TESTDIR)/*.*
	echo -n | tee $(TESTDIR)/test_all.txt
	rm -f incremental-test.txt
	rm -rf $(WWWDIR)/*
	rm -f *.tgz *.tar
