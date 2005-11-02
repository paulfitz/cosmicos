import org.apache.bcel.classfile.Visitor;
import org.apache.bcel.classfile.*;
import org.apache.bcel.generic.*;
import java.io.*;
import java.util.*;
import org.apache.bcel.Constants;
import org.apache.bcel.Repository;
import org.apache.bcel.generic.*;

import java.util.regex.*;


/**
 * Disassemble Java class object into the FRITZ format.
 * Based on JasminVisitor example with BCEL library
 */
public class Fritzifier extends org.apache.bcel.classfile.EmptyVisitor {
    private JavaClass       clazz;
    private PrintWriter     out;
    private String          class_name;
    private ConstantPoolGen cp;

    private Hashtable methods = new Hashtable();

    public Fritzifier(JavaClass clazz, OutputStream out) {
	this.clazz = clazz;
	this.out   = new PrintWriter(out);
	class_name = clazz.getClassName();
	cp = new ConstantPoolGen(clazz.getConstantPool());
    }

    /**
     * Start traversal using DefaultVisitor pattern.
     */
    public void disassemble() {
	new org.apache.bcel.classfile.DescendingVisitor(clazz, this).visit();
	out.println(" );");
	out.close();
    }

    private static int fritzCountParam(String param) {
	String s = fritzParam(param);
	int ct = 0;
	for (int i=0; i<s.length(); i++) {
	    if (s.charAt(i)=='(') {
		ct++;
	    }
	}
	return ct;
    }

    private static String fritzMethodName(String param) {
	//param = param.replace('(','-');
	//param = param.replace(')','-');
	//if (param.equals("--V")) {
	//  param = "";
	//}
	StringBuffer result = new StringBuffer("");
	StringBuffer type = new StringBuffer("");
	int mode = 0;
	for (int i= 0; i<param.length(); i++) {
	    char ch = param.charAt(i);
	    if (mode==0) {
		if (ch=='L') {
		    mode = 1;
		} else if (ch!='(' && ch!=')') {
		    result.append('-');
		    result.append(ch);
		}
	    } else {
		if (ch==';') {
		    mode = 0;
		    result.append('-');
		    result.append(type);
		    type = new StringBuffer("");
		} else if (ch=='/') {
		    type = new StringBuffer("");		    
		} else {
		    type.append(ch);
		}
	    }
	}
	return result.toString();
    }

    private static String fritzParam(String param) {
	if (param.indexOf("COS_")==0) {
	    return "(" + param + ")";
	}
	StringBuffer result = new StringBuffer("");
	param = param.replace(';',' ');
	Pattern p = Pattern.compile("\\[*([BCDFIJSZV]|(L[^ ]+))");
	Matcher m = p.matcher(param);
	boolean first = true;
	while (m.find()) {
	    if (!first) {
		result.append(' ');
	    }
	    result.append(fritzType(m.group()));
	    first = false;
	}
	return result.toString();
    }

    private static String fritzSig(String sig) {
	StringBuffer minimal = new StringBuffer("");

	Pattern p = Pattern.compile("(.+)\\/([^\\/]+)\\((.*)\\)(.*)");
	Matcher m = p.matcher(sig);
	if (m.find()) {
	    if (false) { // old style
		minimal.append(m.group(2));
		minimal.append(" ");
		minimal.append(fritzCountParam(m.group(3)));
		minimal.append(" ");
		minimal.append((m.group(4).toString().equals("V"))?"0":"1");
	    } else {
		minimal.append(m.group(2));
		minimal.append(fritzMethodName("(" + m.group(3).toString() + ")" + m.group(4).toString()));
		minimal.append(" ");
		minimal.append(fritzCountParam(m.group(3)));
		minimal.append(" ");
		minimal.append((m.group(4).toString().equals("V"))?"0":"1");
	    }
	}
	return minimal.toString();
    }

    private static String fritzType(String jvmType) {
	int ch = jvmType.charAt(0);
	StringBuffer stringbuffer = new StringBuffer("(");
	switch (ch) {
	case 66 : // 'B'
	    stringbuffer.append("byte");
	    break;
	    
	case 67 : // 'C'
	    stringbuffer.append("char");
	    break;
	    
	case 68 : // 'D'
	    stringbuffer.append("double");
	    break;
	    
	case 70 : // 'F'
	    stringbuffer.append("float");
	    break;
	    
	case 73 : // 'I'
	    stringbuffer.append("int");
	    break;

	case 74 : // 'J'
	    stringbuffer.append("long");
	    break;
	    
	case 83 : // 'S'
	    stringbuffer.append("short");
	    break;
	    
	case 90 : // 'Z'
	    stringbuffer.append("boolean");
	    break;
	    
	case 86 : // 'V'
	    stringbuffer.append("void");
	    break;
	    
	case 76 : // 'L'
	    //special case for objects.
	    stringbuffer.append(jvmType.substring(1,jvmType.length()).replace('/',' '));
	    break;

	    // also need case for arrays

	default :
	    break;
        }
	stringbuffer.append(")");
	return stringbuffer.toString();
    }

    public String fritzInstruction(String name) {
	String desc = name + " ";
	StringBuffer out = new StringBuffer("");
	int first = 0;
	String opcode = "";
	boolean op = true;
	for (int i=1; i<desc.length(); i++) {
	    if (desc.charAt(i)==' ') {
		String item = desc.substring(first,i);
		//item = item.replaceAll("/",".");
		String result = item;
		if (op) {
		    opcode = item;
		}
		// these tests won't work in general (literal strings, floats)
		if (item.indexOf('\"')!=-1) {
		    // do nothing
		} else if (item.indexOf('(')!=-1) {
		    result = fritzSig(item);
		} else if (item.indexOf('.')!=-1) {
		    //result = fritzName(item);
		    result = item.replaceAll(".*\\.","");
		} else if (item.indexOf('/')!=-1) {
		    result = fritzName(item.replace('/','.'));
		} else if (item.startsWith("Label")) {
		    result = "" + evalLabel(item);
		} else if (item.length()>0) {
		    if (Character.isUpperCase(item.charAt(0))) {
			result = fritzParam(item);
		    }
		} else {
		    result = "";
		}
		if (first != 0) {
		    out.append(" ");
		}
		if (op) {
		    result = result.replaceAll("_([0-9])"," $1");
		}
		out.append(result);
		first = i+1;
		op = false;
	    }
	}
	Pattern p = Pattern.compile("\"([^\"]*)\"");
	Matcher m = p.matcher(out);
	StringBuffer sb = new StringBuffer();
	while (m.find()) {
	    String s = m.group(1);
	    StringBuffer s2 = new StringBuffer("");
	    for (int i=0; i<s.length(); i++) {
		s2.append(" ");
		s2.append(new Integer((int)(s.charAt(i))).toString());
	    }
	    m.appendReplacement(sb,"(String new int-init \"" + s.toString() + "\")");
	    //m.appendReplacement(sb,"(string / vector" + s2.toString() + ")");
	}
	m.appendTail(sb);
	out = sb;
	//out.append("["+name+"]");
	return out.toString();
    }

    public static String fritzName(String name) {
	if (name.indexOf(';')!=-1) {
	    name = name.replaceAll("^L","");
	    name = name.replaceAll(";$","");
	}
	return "(" + name.replace('.',' ').replace('/',' ') + ")";
    }

    public void visitJavaClass(JavaClass clazz) {
	out.println("# JAVA class translation '" + clazz.getClassName() + "'");
	out.println("# " + new Date());
	out.println("# Produced by Fritzifier, based on JasminVisitor");
	out.println("# Using BCEL library to read Java bytecode");
	out.println("# Here is the original code:");
	out.println("# CODE");

	out.println("(class " + clazz.getClassName() + " ()");

	String[] interfaces = clazz.getInterfaceNames();

	for(int i=0; i < interfaces.length; i++) {
	    out.println("   (implement " + fritzName(interfaces[i].toString()) + ")");
	}

	//out.println("   (field super (" + fritzName(clazz.getSuperclassName()) + " new))");
	//out.println("   (method unknown (lambda (x) (super (x))))");
	out.println("   (field super-ref (make-cell 0))");
	out.println("   (method new (set! (super-ref) (" + fritzName(clazz.getSuperclassName()) + " / this)))");
	out.println("   (method super (? x / (get! / super-ref) / x))");
	out.println("   (method unknown (? x / self super / x))");
    }

    public void visitField(Field field) {
	String name = field.getType().toString();
	String fname = fritzName(name);
	// This should just condition on
	// whether we're dealing with a reference or a primitive
	if (name.indexOf("COS_")==0||fname.equals("(java lang String)")) {
	    out.println("   (field " + field.getName() + " (cell new 0))");
	    //out.println("   (field " + field.getName() + " (cell new / " + 
	    //	fritzName(field.getType().toString()) +" new))");
	} else {
	    out.println("   (field " + field.getName() + " (" + 
			fritzName(field.getType().toString()) +" new))");
	}
    }

    public void visitConstantValue(ConstantValue cv) {
	out.println(" = " + cv);
    }

    private Method method;
    
    private void altMethodName() {
	if (!methods.containsKey(method.getName())) {
	    out.println("   (method " + method.getName() + " (self " + method.getName() + fritzMethodName(method.getSignature()) + "))\n");
	    methods.put(method.getName(),"done");
	}
    }

    /**
     * Unfortunately Jasmin expects ".end method" after each method. Thus we've to check
     * for every of the method's attributes if it's the last one and print ".end method"
     * then.
     */
    private final void printEndMethod(Attribute attr) {
	if (method!=null) {
	    Attribute[] attributes = method.getAttributes();
	    
	    if(attr == attributes[attributes.length - 1]) {
		out.println("   )\n");
		altMethodName();
	    }
	}
    }

    public void visitDeprecated(org.apache.bcel.classfile.Deprecated attribute) { printEndMethod(attribute); }
    public void visitSynthetic(Synthetic attribute) { printEndMethod(attribute); }

    public void visitMethod(Method method) {
	out.println("   (method " + method.getName() + fritzMethodName(method.getSignature()));
	//out.println("   (method " + method.getName() + "[" + method.getSignature() + ":" + fritzMethodName(method.getSignature()) + "]");
	this.method = method; // Remember for use in subsequent visitXXX calls
	Attribute[] attributes = method.getAttributes();
	if((attributes == null) || (attributes.length == 0)) {
	    out.println("   )\n"); 
	    altMethodName();
	}
    }

    public void visitExceptionTable(ExceptionTable e) {
	String[] names = e.getExceptionNames();
	for(int i=0; i < names.length; i++)
	    out.println("      (throws " + names[i] + ")");

	printEndMethod(e);
    }

    private Hashtable map;
    private Hashtable rev_map;
    private Hashtable mapn;

    public void visitCode(Code code) {
	int label_counter = 0;

	//out.println("      (limit stack " + code.getMaxStack() + ")");
	//out.println("      (limit locals " + code.getMaxLocals() + ")");

	MethodGen           mg  = new MethodGen(method, class_name, cp);
	InstructionList     il  = mg.getInstructionList();
	InstructionHandle[] ihs = il.getInstructionHandles();

	/* Pass 1: Give all referenced instruction handles a symbolic name, i.e. a
	 * label.
	 */
	map = new Hashtable();
	rev_map = new Hashtable();
	mapn = new Hashtable();

	int id = 0;
	for(int i=0; i < ihs.length; i++) {
	    putn(ihs[i], i);
	}
	for(int i=0; i < ihs.length; i++) {
	    if(ihs[i] instanceof BranchHandle) {
		BranchInstruction bi = (BranchInstruction)ihs[i].getInstruction();
	
		if(bi instanceof Select) { // Special cases LOOKUPSWITCH and TABLESWITCH
		    InstructionHandle[] targets = ((Select)bi).getTargets();
	  
		    for(int j=0; j < targets.length; j++)
			put(targets[j], "Label" + label_counter++ + ":");
		}

		InstructionHandle ih = bi.getTarget();
		put(ih, "Label" + label_counter++ + ":");
	    }
	}

	LocalVariableGen[] lvs = mg.getLocalVariables();
	for(int i=0; i < lvs.length; i++) {
	    InstructionHandle ih = lvs[i].getStart();
	    put(ih, "Label" + label_counter++ + ":");
	    ih = lvs[i].getEnd();
	    put(ih, "Label" + label_counter++ + ":");	
	}
    
	CodeExceptionGen[] ehs = mg.getExceptionHandlers();
	for(int i=0; i < ehs.length; i++) {
	    CodeExceptionGen  c  = ehs[i];
	    InstructionHandle ih = c.getStartPC();

	    put(ih, "Label" + label_counter++ + ":");	
	    ih = c.getEndPC();
	    put(ih, "Label" + label_counter++ + ":");	
	    ih = c.getHandlerPC();
	    put(ih, "Label" + label_counter++ + ":");	
	}

	/*
	  LineNumberGen[] lns = mg.getLineNumbers();
	  for(int i=0; i < lns.length; i++) {
	  InstructionHandle ih = lns[i].getInstruction();
	  put(ih, ".line " + lns[i].getSourceLine());
	  }
	*/
 
	/* Pass 2: Output code.
	 */
	out.print("     (lambda (");
	for(int i=1; i < lvs.length; i++) {
	    LocalVariableGen l = lvs[i];

	    if (i>1) { out.print(" "); }
	    out.print(l.getName());
	    //out.print("(" + l.getName() + " " +
	    //	fritzName(l.getType().toString()) +  ")");

	    //out.println("      (var " + l.getIndex() + " " + l.getName() + " " +
			//fritzName(l.getType().toString()) +  ")");
	}
	out.println(") /");
	out.println("      let ((vars / cell new / make-hash / vector");
	out.print("                   ");
	for(int i=0; i < lvs.length; i++) {
	    LocalVariableGen l = lvs[i];
	    String s = l.getName();
	    if (s.equals("this")) {
		s = "self";
	    }
	    out.print(" (pair " + l.getIndex() + " (" + s + "))");
	    //out.println("      (var " + l.getIndex() + " " + l.getName() + " " +
	    //	fritzName(l.getType().toString()) +  ")");
	    //out.println("      (var " + l.getIndex() + " " + l.getName() + " " +
			//fritzName(l.getType().toString()) +  ")");
	}
	out.println(")");
	out.println("           (stack / cell new / vector)) /");

	out.println("      state-machine (vars) (stack) / ? jvm / ? x / cond");

	for(int i=0; i < ihs.length; i++) {
	    InstructionHandle ih   = ihs[i];
	    Instruction       inst = ih.getInstruction();
	    String            str  = (String)map.get(ih);

	    String pre = "((= (x) " + i + ") ";
	    String post = ")";

	    /*
	    if(str != null) {
		out.println("         " + pre + "(label " + str.replaceAll(":","") + ")" + post);
		//out.println(str);
	    }
	    */

	    if(inst instanceof BranchInstruction) {
		String desc = "";
		if(inst instanceof Select) { // Special cases LOOKUPSWITCH and TABLESWITCH
		    Select              s       = (Select)inst;
		    int[]               matchs  = s.getMatchs();
		    InstructionHandle[] targets = s.getTargets();
	  
		    if(s instanceof TABLESWITCH) {
			desc = "tableswitch " + matchs[0] + " " +
				  matchs[matchs.length - 1];
	    
			for(int j=0; j < targets.length; j++)
			    desc = desc + " " + get(targets[j]);
			desc = desc + " " + get(s.getTarget()); // default
		    } else { // LOOKUPSWITCH
			desc = "lookupswitch";

			for(int j=0; j < targets.length; j++)
			    desc = desc + " (" + matchs[j] + " " + get(targets[j]) + ")";
			desc = desc + " (default " + get(s.getTarget()) + ")"; // Applies for both
		    }

		} else {
		    BranchInstruction bi  = (BranchInstruction)inst;
		    ih  = bi.getTarget();
		    str = get(ih);
		    desc = Constants.OPCODE_NAMES[bi.getOpcode()] + " " + str;
		}
		out.println("         "+pre+"(jvm " + fritzInstruction(desc) + ")" + post);
	    }
	    else {
		String desc = inst.toString(cp.getConstantPool());
		//foo = foo.replaceAll(" ([^ ]*)\\(([^ ]*)\\)([^ ]*)", " :$1:$2:$3");
		desc = fritzInstruction(desc);
		//out.println("         (" + inst.toString(cp.getConstantPool()) + ")");	  
		out.println("         "+pre+"(jvm " + desc + ")"+post);
	    }
	}
    
	for(int i=0; i < ehs.length; i++) {
	    CodeExceptionGen c = ehs[i];
	    ObjectType caught = c.getCatchType();
	    String class_name = (caught == null)?  // catch any exception, used when compiling finally
		"all" : fritzName(caught.getClassName());

	    out.println("         (catch " + class_name + " from " +
			get(c.getStartPC()) + " to " + get(c.getEndPC()) +
			" using " + get(c.getHandlerPC()) + ")");
	}

	out.println("         (jvm return))");
	printEndMethod(code);
    }

 
    private final String get(InstructionHandle ih) {
	String str = new StringTokenizer((String)map.get(ih), "\n").nextToken();
	return str.substring(0, str.length() - 1);
    }

    private final void put(InstructionHandle ih, String line) {
	String str = (String)map.get(ih);

	Integer i = (Integer)mapn.get(ih);
	if (i!=null) {
	    String s = line.replaceAll(":","");
	    rev_map.put(s,i);
	}

	if(str == null)
	    map.put(ih, line);
	else {
	    if(line.startsWith("Label") || str.endsWith(line)) // Already have a label in the map
		return;

	    map.put(ih, str + "\n" + line); // append
	}
    }	

    private final void putn(InstructionHandle ih, int n) {
	mapn.put(ih,new Integer(n));
    }

    private final int getn(InstructionHandle ih) {
	return ((Integer)(mapn.get(ih))).intValue();
    }

    private final int evalLabel(String s) {
	Integer i = (Integer)rev_map.get(s);
	if (i==null) {
	    System.out.println("No definition for [" + s + "]");
	    System.out.println("Map is " + rev_map);
	}
	return i.intValue();
    }

    public static void main(String[] argv) { 
	ClassParser parser=null;
	JavaClass   java_class;

	try {
	    if(argv.length == 0) {
		System.err.println("disassemble: No input files specified");
	    }
	    else {
		for(int i=0; i < argv.length; i++) {
		    if((java_class = Repository.lookupClass(argv[i])) == null)
			java_class = new ClassParser(argv[i]).parse();
	  
		    String class_name = java_class.getClassName();
		    int    index      = class_name.lastIndexOf('.');
		    String path       = class_name.substring(0, index + 1).replace('.', File.separatorChar);
		    class_name = class_name.substring(index + 1);

		    if(!path.equals("")) {
			File f = new File(path);
			f.mkdirs();
		    }

		    FileOutputStream out = new FileOutputStream(path + class_name + ".ftz");
		    new Fritzifier(java_class, out).disassemble();
		}
	    }	  
	} catch(Exception e) {
	    e.printStackTrace();
	}
    }        

}


