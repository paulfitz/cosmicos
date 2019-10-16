default:
	./make.sh

help:
	./make.sh help

dock:
	cd docker && cp ../package.json . && docker build -t paulfitz/cosmicos_builder .

%:
	./make.sh $*
