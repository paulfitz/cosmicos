#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

static int content_mode = 1;

void show(FILE *fout, int x, int n) {
  for (int i=0; i<n; i++) {
    int v = x % 256;
    fputc(v,fout);
    x /= 256;
  }
}

void show_header(FILE *fout, int sample_len) {
  fprintf(fout,"RIFF");
  show(fout,36+sample_len,4);
  fprintf(fout,"WAVE");
  fprintf(fout,"fmt ");
  show(fout,16,4);
  show(fout,1,2);
  show(fout,1,2);
  show(fout,16000,4);
  show(fout,16000,4);
  show(fout,1,2);
  show(fout,8,2);
  fprintf(fout,"data");
  show(fout,sample_len,4);
}

void render(FILE *fout, char *text) {
  int unit_len = 4000;
  int char_len = strlen(text);
  int sample_len = unit_len*char_len;
  double variation = 0.5;
  //double qraise = pow(2,1/6.0);
  //double qminor = pow(2,1/12.0);
  double qraise = sqrt(sqrt(2));
  double qminor = 2;
  double base = 2;
  show_header(fout,sample_len);

  double v = 0;
  double n_prev = 0;
  double n2_prev = -1;
  int k_prev = 4;
  for (int i=0; i<char_len; i++) {
    int k = text[i] - '0';
    double n = k;
    double n2 = -1;
    int chord = 0;
    //if (k==2) { base = base+1;  n = base;  chord = 1; }
    //if (k==3) { base = base-1;  n = base;  chord = 1; }
    //if (k==0) { n = base-variation; }
    //if (k==1) { n = base+variation; }
    if (k==2) { base = base*qraise;  n = base; chord = 1; }
    if (k==3) { base = base/qraise;  n = base; chord = 1; }
    if (k==0) { n2 = base/qminor;  n = base; }
    if (k==1) { n2 = base*qminor;  n = base; }
    for (int j=0; j<unit_len; j++) {
      double q = 0;
      double factor = j/80.0;
      double tweak = 1-fabs(j-unit_len/2)/(unit_len/2);
      if (factor>1) { factor = 1; }
      if (k!=4 && k!=5) {
	q += factor*100*sin((n)*v);
	if (n2>=0) {
	  q += factor*20*sin((n2)*v);
	}
	if (chord) {
	  //q += tweak*factor*12*sin((n*qminor)*v);
	  //q += tweak*factor*12*sin((n/qminor)*v);
	} else {
	}
      }
      if (k_prev!=4 && k_prev!=5) {
	if (i!=0) {
	  q += (1-factor)*100*sin((n_prev)*v);
	}
      }
      if (n2_prev>=0) {
	  q += (1-factor)*20*sin((n2_prev)*v);
      }
      if (k==4 || k==5) {
	if (k==4) {
	  q += tweak*factor*50*sin(base*v);
	  q += tweak*factor*25*sin(2*base*v);
	} else {
	  q += tweak*factor*50*sin(base*v);
	  q += tweak*factor*25*sin(2*base*v);
	  q += tweak*factor*12*sin(4*base*v);
	  q += tweak*factor*12*sin(8*base*v);
	}
      }
      show(fout,128+int(q),1);
      //show(fout,128+int(127*sin(i*0.1)),1);
      v += 0.1;
    }
    n_prev = n;
    k_prev = k;
    n2_prev = n2;
  }
}



int main(int argc, char *argv[]) {
  FILE *fout = stdout;
  char *default_text = "01234543210";
  char *text = default_text;
  argc--;
  argv++;
  while (argc>0) {
    text = argv[0];
    if (text[0]=='-') {
      switch (text[1]) {
      case 'w':
	content_mode = 0;
	break;
      }
    }
    argc--;
    argv++;
  }
  if (content_mode) {
    text = default_text;
    char *data;
    data = getenv("QUERY_STRING");
    if(data != NULL) {
      if (data[0]=='s') {
	if (data[1]=='=') {
	  text = data+2;
	}
      }
    }

    printf("Content-Type: audio/x-wav");
    printf("%c%c",10,10);
  }
  render(fout,text);
  return 0;
}
