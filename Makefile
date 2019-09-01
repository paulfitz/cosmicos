default:
	./make.sh

help:
	./make.sh help

dock:
	cd docker && docker build -t paulfitz/cosmicos_builder .

%:
	./make.sh $*
