
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


class Exp {
private:
  bool auto_paren;
  bool commentary;
  bool terminated;
  bool bag;
  list<Exp> sub;
  Exp *tparent;
  string content;

public:
  Exp(Exp *nparent = NULL) {
    auto_paren = false;
    commentary = false;
    terminated = false;
    bag = false;
    tparent = nparent;
    content = "";
  }

  Exp(const Exp& alt) {
    tparent = alt.tparent;
  }

  Exp *add() {
    sub.push_back(Exp(this));
    return &(sub.back());
  }

  Exp *parent() {
    return tparent;
  }

  Exp *autoParent() {
    Exp *nparent = parent();
    if (nparent!=NULL) {
      while (nparent->auto_paren) {
	nparent = nparent->parent();
	assert(nparent!=NULL);
      }
    }
    return nparent;
  }

  void setName(const char *name) {
    content = name;
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

  void write(ostream& os) {
    bool need_space = false;
    if (sub.size()>=1) {
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
    current->setName("BLANK");
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
    base.write(os);
  }
};


void ExpBuilder::apply(char ch) {
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
  exp.apply(Text("#blah blah\n(define make-graph / lambda (nodes links) (pair (nodes) (links)));#more blah\n(+ 1 1);"));
  exp.apply(Text("#blah blah\n(define make-graph / lambda (nodes links) (pair (nodes) (links)));#more blah\n(+ 1 1);"));
  exp.write(cout);
  return 0;
}

