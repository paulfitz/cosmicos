
#include <string.h>
#include <assert.h>

#include <iostream>
#include <list>
#include <string>

using namespace std;

class Text {
private:
  const char *body;
  int tstart;
  int tend;
public:
  Text(const char *txt) {
    body = txt;
    tstart = 0;
    tend = strlen(txt)-1;
  }

  int start() const { return tstart; }
  int end() const { return tend; }
  char at(int index) const { return body[index]; }
};


enum {
  FAMILY_UNIT,
  FAMILY_BODIED,
  FAMILY_APPLY,
};


class Emit {
private:
  int prev_at;
  ostream& os;
public:

  Emit(ostream& nos) : os(nos) { prev_at = 0; }

  void write(const char *str) {
    write(str,prev_at);
  }

  void write(const char *str, int at) {
    //printf("asked to write [%s]\n", str);
    if (at<prev_at) {
      os << endl;
      prev_at = 0;
    }
    while (prev_at<at && prev_at>=0) {
      os << " ";
      prev_at++;
      if (prev_at>200) {
	printf("seeking to %d from %d for [%s]\n", at, prev_at, str);
	exit(1);
      }
    }
    int len = strlen(str);
    os << str;
    prev_at += len;
  }
};

class Exp {
private:
  bool auto_paren;
  bool commentary;
  bool terminated;
  bool bag;
  bool name_set;
  list<Exp> sub;
  Exp *tparent;
  string content;
  string render;
  int pos;
  int len;

public:
  Exp(Exp *nparent = NULL) {
    auto_paren = false;
    commentary = false;
    terminated = false;
    bag = false;
    name_set = false;
    tparent = nparent;
    content = "";
  }

  Exp(const Exp& alt) {
    auto_paren = alt.auto_paren;
    commentary = alt.commentary;
    terminated = alt.terminated;
    bag = alt.bag;
    tparent = alt.tparent;
    content = alt.content;
    name_set = alt.name_set;
  }

  Exp *add() {
    sub.push_back(Exp(this));
    return &(sub.back());
  }

  Exp *parent() {
    return tparent;
  }

  Exp *autoParent() {
    Exp *current = this;
    while (current->auto_paren) {
      current = current->parent();
    }
    if (current==NULL) { return current; }
    return current->parent();
  }

  void setName(const char *name) {
    content = name;
    name_set = true;
  }

  const char *getName() {
    return content.c_str();
  }

  void setAutoParen(bool flag) {
    auto_paren = flag;
  }

  void setComment(bool flag) {
    commentary = flag;
  }

  void setTerminated(bool flag) {
    terminated = flag;
  }

  void setBag(bool flag) {
    bag = flag;
  }

  int getFamily() {
    int family = FAMILY_UNIT;
    if (!name_set) {
      family = FAMILY_APPLY;
      if (sub.size()>=1) {
	if (strcmp(first().getName(),"define")==0) {
	  family = FAMILY_BODIED;
	}
      }
    }
    return family;
  }

  void layout() {
    if (!name_set) {
      pos = 0;
      int pre_len = 0;
      int call_len = 0;
      int longest_arg_len = 0;
      int last_len = 0;
      int first = 1;
      int arg_ct = 0;
      int speedy = 0;
      for (list<Exp>::iterator it = sub.begin(); it!=sub.end(); it++) {
	(*it).layout();
	int ilen = (*it).len;
	pre_len += ilen;
	last_len = ilen;
	if (!first) {
	  if (ilen>longest_arg_len) {
	    longest_arg_len = ilen;
	  }
	} else {
	  call_len = ilen;
	  if (!(*it).name_set) {
	    speedy = 1;
	    printf("ZAP call_len for: \n");
	    (*it).write(cout);
	    call_len = -1;
	    longest_arg_len = ilen;   
	  }
	}
	first = 0;
	arg_ct++;
      }
      if (!bag) {
	int ap = auto_paren?1:0;
	if (pre_len+2<20 || (arg_ct<=2&&!speedy)) {
	  int at = 1;
	  for (list<Exp>::iterator it = sub.begin(); it!=sub.end(); it++) {
	    (*it).pos = at+ap;
	    at += (*it).len+1;
	  }
	  if (at<=1) at=2;
	  len = at;
	} else {
	  for (list<Exp>::iterator it = sub.begin(); it!=sub.end(); it++) {
	    if (it!=sub.begin()) {
	      (*it).pos = call_len+2+ap;
	    } else {
	      (*it).pos = 1+ap;
	    }
	  }
	  len = call_len+1+last_len+2;
	}
      } else {
	len = 0;
	pos = 0;
      }
    } else {
      pos = 0;
      len = content.length();
    }
  }


  void layout(ostream& os) {
    layout();
    Emit emit(os);
    layout_helper(emit,0);
    os << endl;
  }
  
  void layout_helper(Emit& emit, int at) {
    if (name_set) {
      emit.write(content.c_str(),at+pos);
    } else {
      if (!bag && !auto_paren) {
	emit.write("(",at+pos);
      }
      int last_pos = at+pos+1;
      for (list<Exp>::iterator it = sub.begin(); it!=sub.end(); it++) {
	if ((*it).auto_paren) {
	  emit.write(" /");
	}
	(*it).layout_helper(emit,at+pos);
	last_pos = (*it).pos+(*it).len+at+pos;
      }
      if (!bag) {
	if (!auto_paren) {
	  emit.write(")",last_pos);
	}
	if (terminated) {
	  emit.write(";",last_pos+1);
	}
      }
    }
  }

  void write(ostream& os) {
    bool need_space = false;
    if (!name_set) {
      if (!bag) {
	if (!auto_paren) {
	  os << "(";
	  need_space = false;
	} else {
	  os << "/";
	  need_space = true;
	}
      }
      for (list<Exp>::iterator it = sub.begin(); it!=sub.end(); it++) {
	assert((*it).parent()==this);
	if (need_space) {
	  os << " ";
	}
	(*it).write(os);
	need_space = !((*it).terminated||(*it).commentary);
      }
      if (!bag) {
	if (!auto_paren) {
	  os << ")";
	} 
      } 
    } else {
      os << content;
    }
    if (terminated) {
      os << ";" << endl;
    } else if (commentary) {
      os << endl;
    }
  }

  Exp& first() {
    return (sub.front());
  }

  Exp& last() {
    return (sub.back());
  }
};

class ExpBuilder {
public:
  Exp base;
  Exp *current;

  ExpBuilder() {
    current = &base;
  }


  bool sym;
  bool comment;
  int at;
  string symbol_text;
  void apply (char ch);

  void apply(const Text& text);

  void applyLeft() {
    current = current->add();
  }

  void applyRight() {
    current = current->autoParent();
  }

  void applyMid() {
    applyLeft();
    current->setAutoParen(true);
  }

  void applyTerminator() {
    current->last().setTerminated(true);
  }

  void applySymbol(const char *name, bool is_comment = false) {
    Exp *sub = current->add();
    sub->setName(name);
    sub->setComment(is_comment);
  }

  void applyComment(const char *name) {
    applySymbol(name,true);
  }


  void write(ostream& os) {
    base.setBag(true);
    base.layout(os);
  }
};


void ExpBuilder::apply(char ch) {
  //printf("[apply %c]", ch);
  //write(cout);
  if (sym) {
    if (comment) {
      if (ch!='\n') {
	symbol_text += ch;
      } else {
	applyComment(symbol_text.c_str());
	sym = false;
	comment = false;
      }
    } else {
      switch (ch) {
      case '(':
      case ')':
      case ' ':
      case '\t':
      case '\n':
      case '\r':
      case '/':
      case ';':
	applySymbol(symbol_text.c_str());
	sym = false;
	break;
      default:
	symbol_text += ch;
	break;
      }
    }
  }
  if (!sym) {
    switch (ch) {
    case '(':
      applyLeft();
      break;
    case ')':
      applyRight();
      break;
    case '/':
      applyMid();
      break;
    case ';':
      applyTerminator();
      break;
    case '\n':
    case '\r':
    case '\t':
    case ' ':
      break;
    default:
      sym = true;
      comment = (ch=='#');
      symbol_text = ch;
      break;
    }
  }
}

void ExpBuilder::apply(const Text& text) {
  sym = false;
  comment = false;
  for (int i=text.start(); i<=text.end(); i++) {
    at = i;
    char ch = text.at(i);
    apply(ch);
  }
}


int main() {
  ExpBuilder exp;
  string in;
  while (!(cin.eof()||cin.bad())) {
    getline(cin,in);
    in += "\n";
    exp.apply(Text(in.c_str()));
  }
  exp.write(cout);

  return 0;
}

