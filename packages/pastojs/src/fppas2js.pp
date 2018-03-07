{
    This file is part of the Free Component Library (FCL)
    Copyright (c) 2018 by Michael Van Canneyt

    Pascal to Javascript converter class.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************
}(*
Abstract:
  Converts TPasElements into TJSElements.

Works:
- units, programs
- unit interface function
- uses list
- use $impl for implementation declarations, can be disabled
- interface vars
  - only double, no other float type
  - only string, no other string type
  - modifier public to protect from removing by optimizer
- implementation vars
- external vars
- initialization section
- option to add "use strict";
- procedures
  - params
  - local vars
  - default values
  - function results
  - modifier external 'name'
  - local const: declare in singleton parent function as local var
  - give procedure overloads in module unique names by appending $1, $2, ...
  - give nested procedure overloads unique names by appending $1, $2, ...
  - untyped parameter
  - varargs
  - modifier public to protect from removing by optimizer
  - choose overloads based on type and precision
  - fail overload on multiple with loss of precision or one used default param
  - FuncName:=, auto rename lower lvl Result variables
  - var modifier 'absolute' for local vars
- assign statements
- char
  - literals
  - ord(char)  ->  char.charCodeAt()
  - chr(integer)  -> String.fromCharCode(integer)
- string
  - literals
  - setlength(s,newlen) -> s = rtl.strSetLength(s,newlen)
  - read and write char aString[]
  - allow only String, no ShortString, AnsiString, UnicodeString,...
  - allow type casting string to external class name 'String'
- for int/enum do, for char do, for bool do
- repeat..until
- while..do
- try..finally
- try..except, try..except on else
- raise, raise E
- asm..end
- assembler; asm..end;
- break
- continue
- procedure str, function str
- type alias
- inc/dec to += -=
- case-of
- convert "a div b" to "Math.floor(a / b)"
- and, or, xor, not: logical and bitwise
- typecast boolean to integer and back with unary plus:  +bool  and int!=0
- rename name conflicts with js identifiers: apply, bind, call, prototype, ...
- record
  - types and vars
  - assign
  - clone record member
  - clone set member
  - clone when passing as argument
  - equal, not equal
- classes
  - declare using createClass
  - constructor
  - destructor
  - vars, init on create, clear references on destroy
  - class vars
  - ancestor
  - virtual, override, abstract
  - "is" operator
  - "as" operator
  - call inherited
    - "inherited;",
    - "inherited funcname(params);"
    - in nested proc
  - call class method
  - read/write class var
  - property
    - param list
    - property of type array
  - class property
    - accessors non static
  - Assigned()
  - default property
  - type casts
  - overloads, reintroduce  append $1, $2, ...
  - reintroduced variables
  - external vars and methods
  - const
  - bracket accessor, getter/setter has external name '[]'
  - TObject.Free sets variable to nil
  - property stored and index modifier
- dynamic arrays
  - arrays can be null
  - init as "arr = []"  so typeof works
  - SetLength(arr,dim1,...) becomes  arr = rtl.arraySetLength(arr,defaultvalue,dim1,dim2,...)
  - length(), low(), high(), assigned(), concat()
  - assign nil -> []  so typeof works
  - read, write element arr[index]
  - multi dimensional [index1,index2] -> [index1][index2]
  - array of record
  - equal, unequal nil -> rtl.length(array)==0  or >0
  - when passing nil to an array argument, pass []
  - allow type casting array to external class name 'Array'
  - type cast array to array of same dimensions and compatible element type
  - function copy(array,start=0,count=max): array
  - procedure insert(item,var array,const position)
  - procedure delete(var array,const start,count)
  - const c: dynarray = (a,b,...)
- static arrays
  - range: enumtype, boolean, int, char, custom int
  - init as arr = rtl.arraySetLength(null,value,dim1,dim2,...)
  - init with expression
  - length(1-dim array)
  - low(1-dim array), high(1-dim array)
- open arrays
  - as dynamic arrays
- enums
  - type with values and names
  - option to write numbers instead of variables
  - ord(), low(), high(), pred(), succ()
  - type cast alias to enumtype
  - type cast number to enumtype, enumtype to number
  - const aliasname = enumvalue
- sets
  - set of enum
  - include, exclude, clone when referenced
  - assign :=   set state referenced
  - constant set: enums, enum vars, ranges
  - set operators +, -, *, ><, =, <>, >=, <=
  - in-operator
  - low(), high()
  - when passing as argument set state referenced
  - set of (enum,enum2)  - anonymous enumtype
- with-do  using local var
  - with record do i:=v;
  - with classinstance do begin create; i:=v; f(); i:=a[]; end;
- pass by reference
  - pass local var to a var/out parameter
  - pass variable to a var/out parameter
  - pass reference to a var/out parameter
  - pass array element to a var/out parameter
- procedure types
  - implemented as immutable wrapper function
  - assign := nil, proctype (not clone), @function, @method
  - call  explicit and implicit
  - compare equal and notequal with nil, proctype, address, function
  - assigned(proctype)
  - pass as argument
  - methods
  - mode delphi: proctype:=proc
  - mode delphi: functype=funcresulttype
  - nested functions
  - reference to
  - @@ compare method in delphi mode
- class-of
  - assign :=   nil, var
  - call class method
  - call constructor
  - operators =, <>
  - class var, property, method
  - Self in class method
  - typecast
- class external
  - JS object or function as ancestor
  - does not descend from TObject
  - all members become external. case sensitive
  - has no hidden values like $class, $ancestor, $unitname, $init, $final
  - can be ancestor of a pascal class (not descend from TObject).
  - pascal class descendant can override methods
  - property works as normal, replaced by getter and setter
  - class-of
  - class var/function: works as in JS.
  - is and as operators
  - destructor forbidden
  - constructor must not be virtual
  - constructor 'new' -> new extclass(params)
  - identifiers are renamed to avoid clashes with external names
  - call inherited
  - Pascal descendant can override newinstance
  - any class can be typecasted to any root class
  - class instances cannot access external class members (e.g. static class functions)
  - external class 'Array' bracket operator [integer] type jsvalue
  - external class 'Object' bracket operator [string] type jsvalue
- jsvalue
  - init as undefined
  - assign to jsvalue := integer, string, boolean, double, char
  - type cast base types to jsvalue
  - type cast jsvalue to base type
     integer: Math.floor(jsvalue)   may return NaN
     boolean: !(jsvalue == false)   works for numbers too 0==false
     double: rtl.getNumber(jsvalue)    typeof(n)=="number"?n:NaN;
     string: ""+jsvalue
     char: rtl.getChar(jsvalue)   ((typeof(c)!="string") && (c.length==1)) ? c : ""
  - enums: assign to jsvalue, typecast jsvalue to enum
  - class instance: assign to jsvalue, typecast jsvalue to a class
  - class of: assign to jsvalue, typecast jsvalue to a class-of
  - array of jsvalue,
    allow to assign any array to an array of jsvalue
    allow type casting to any array
  - parameter, result type, assign from/to untyped
  - operators equal, not equal
  - callback: assign to jsvalue, equal, not equal
  - jsvalue is class-type, jsvalue is class-of-type
- RTTI
  - base types
  - $mod.$rtti
  - enum type tkEnumeration
  - set type tkSet
  - procedure type  tkProcVar, tkMethod
  - class type tkClass
    - fields,
    - methods,
    - properties  no params, no index, no defaultvalue
    - class forward
  - class-of type tkClassRef
  - dyn array type  tkDynArray
  - static array type  tkArray
  - record type  tkRecord
  - no typeinfo for local types
  - built-in function typeinfo(): Pointer/TTypeInfo/...;
    - typeinfo(class) -> class.$rtti
  - WPO skip not used typeinfo
  - open array param
  - property stored and index modifier
  - property default value
- pointer
  - compare with and assign nil
- ECMAScript6:
  - use 0b for binary literals
  - use 0o for octal literals
- dotted unit names, namespaces
- resourcestring
- custom ranges
  - enum, int, char
  - low(), high(), pred(), succ(), ord(),
  - rg(int), int(rg), enum:=rg,
  - rg:=rg, rg1:=rg2, rg:=enum, =, <>,
  - set of int/enum/char range, in
  - array[rg], low(array), high(array), length(array)
- enumeration  for..in..do
  - enum, enum range, set of enum, set of enum range
  - int, int range, set of int, set of int range
  - char, char range, set of char, set of char range
  - array
  - class
- Assert(bool[,string])
  - without sysutils: if(bool) throw string
  - with sysutils: if(bool) throw pas.sysutils.EAssertionFailed.$create("Create",[string])
- Object checks:
  - Method call EInvalidCast, rtl.checkMethodCall
  - type cast to class-type and class-of-type, rtl.asExt, EInvalidCast
- Range checks:
  - assign int:=, int+=
  - procedure argument int

ToDos:
- 'new', 'Function' -> class var use .prototype
- btArrayLit
  a: array of jsvalue;
  a:=[];
- bug:
  v:=a[0]  gives Local variable "a" is assigned but never used
- setlength(dynarray)  modeswitch to create a copy
- range checks:
  - compile time: warnings to errors
  - proc args enum, custom enum, custom int
  - assign enum:=, enum+=
  - prop:=
  - string[index]
  - array[index]
  - prop[index]
- typecast longint(highprecint) -> value & $ffffffff
- static arrays
  - a[] of record
- RTTI
  - class property
  - type alias type
  - documentation
- move local types to unit scope
- make records more lightweight
- pointer of record
- nested classes
- asm: pas() - useful for overloads and protect an identifier from optimization
- ifthen
- stdcall of methods: pass original 'this' as first parameter

Not in Version 1.0:
- write, writeln
- arrays
  - array of const
- sets
  - set of char, boolean, integer range, char range, enum range
- call array of proc element without ()
- record const
- enums with custom values
- library
- constref
- option typecast checking -Ct
- option verify method calls -CR
- option range checking -Cr
- option overflow checking -Co
- optimizations:
  - add $mod only if needed
  - add Self only if needed
  - use a number for small sets
  - put set literals into constants
  - shortcut for test set is empty  a=[]  a<>[]
  - set operators on literals without temporary arrays, a in [b], [a]*b<>[]
  - nested procs without var, instead as "function name(){}"
  - combine multiple var a=0,b=0
  -O1 insert local/unit vars for global type references:
      at start of intf var $r1;
      at end of impl: $r1=path;
  -O1 insert unit vars for complex literals
  -O1 no function Result var when assigned only once
  - SetLength(scope.a,l) -> read scope only once, same for
    Include, Exclude, Inc, Dec, +=, -=, *=, /=
  -O1 replace constant expression with result
  -O1 pass array element by ref: when index is constant, use that directly
- objects
- interfaces
- advanced records
- class helpers, type helpers, record helpers,
- generics
- operator overloading
  - operator enumerator
- inline
- anonymous functions
- extended RTTI
- attributes

Debugging this unit: -d<x>
   VerbosePas2JS
*)
unit FPPas2Js;

{$mode objfpc}{$H+}
{$inline on}

interface

uses
  Classes, SysUtils, math, contnrs,
  jsbase, jstree, jswriter,
  PasTree, PScanner, PasResolveEval, PasResolver;

// message numbers
const
  nPasElementNotSupported = 4001;
  nNotSupportedX = 4002;
  nUnaryOpcodeNotSupported = 4003;
  nBinaryOpcodeNotSupported = 4004;
  nInvalidNumber = 4005;
  nInitializedArraysNotSupported = 4006;
  nMemberExprMustBeIdentifier = 4007;
  nCantWriteSetLiteral = 4008;
  nInvalidAbsoluteLocation = 4009;
  //nExpectedXButFoundY = 4010;
  nInvalidFunctionReference = 4011;
  nMissingExternalName = 4012;
  nVirtualMethodNameMustMatchExternal = 4013;
  nPublishedNameMustMatchExternal = 4014;
  nInvalidVariableModifier = 4015;
  nNoArgumentsAllowedForExternalObjectConstructor = 4016;
  nNewInstanceFunctionMustBeVirtual = 4017;
  nNewInstanceFunctionMustHaveTwoParameters = 4018;
  nNewInstanceFunctionMustNotHaveOverloadAtX = 4019;
  nBracketAccessorOfExternalClassMustHaveOneParameter = 4020;
  nTypeXCannotBePublished = 4021;
  nNestedInheritedNeedsParameters = 4022;
  nFreeNeedsVar = 4023;
// resourcestring patterns of messages
resourcestring
  sPasElementNotSupported = 'Pascal element not supported: %s';
  sNotSupportedX = 'Not supported: %s';
  sUnaryOpcodeNotSupported = 'Unary OpCode not yet supported "%s"';
  sBinaryOpcodeNotSupported = 'Binary OpCode not yet supported "%s"';
  sInvalidNumber = 'Invalid number "%s"';
  sInitializedArraysNotSupported = 'Initialized array variables not yet supported';
  sMemberExprMustBeIdentifier = 'Member expression must be an identifier';
  sCantWriteSetLiteral = 'Cannot write set literal';
  sInvalidAbsoluteLocation = 'Invalid absolute location';
  //sExpectedXButFoundY = 'Expected %s, but found %s';
  sInvalidFunctionReference = 'Invalid function reference';
  sMissingExternalName = 'Missing external name';
  sVirtualMethodNameMustMatchExternal = 'Virtual method name must match external';
  sInvalidVariableModifier = 'Invalid variable modifier "%s"';
  sPublishedNameMustMatchExternal = 'Published name must match external';
  sNoArgumentsAllowedForExternalObjectConstructor = 'no arguments allowed for external object constructor';
  sNewInstanceFunctionMustBeVirtual = 'NewInstance function must be virtual';
  sNewInstanceFunctionMustHaveTwoParameters = 'NewInstance function must have two parameters';
  sNewInstanceFunctionMustNotHaveOverloadAtX = 'NewInstance function must not have overload at %s';
  sBracketAccessorOfExternalClassMustHaveOneParameter = 'Bracket accessor of external class must have one parameter';
  sTypeXCannotBePublished = 'Type "%s" cannot be published';
  sNestedInheritedNeedsParameters = 'nested inherited needs parameters';
  sFreeNeedsVar = 'Free needs a variable';

const
  ExtClassBracketAccessor = '[]'; // external name '[]' marks the array param getter/setter
  IsExtModePasClassInstance = 1;
  IsExtModePasClass = 2;

type
  TPas2JSBuiltInName = (
    pbifnArray_Concat,
    pbifnArray_Copy,
    pbifnArray_Length,
    pbifnArray_SetLength,
    pbifnArray_Static_Clone,
    pbifnAs,
    pbifnAsExt,
    pbifnCheckMethodCall,
    pbifnClassInstanceFree,
    pbifnClassInstanceNew,
    pbifnCreateClass,
    pbifnCreateClassExt,
    pbifnGetChar,
    pbifnGetNumber,
    pbifnGetObject,
    pbifnGetResourcestring,
    pbifnIs,
    pbifnIsExt,
    pbifnFloatToStr,
    pbifnFreeLocalVar,
    pbifnFreeVar,
    pbifnProcType_Create,
    pbifnProcType_Equal,
    pbifnProgramMain,
    pbifnRangeCheckInt,
    pbifnRecordEqual,
    pbifnRTTIAddField, // typeinfos of tkclass and tkrecord have addField
    pbifnRTTIAddFields, // typeinfos of tkclass and tkrecord have addFields
    pbifnRTTIAddMethod,//   "   "
    pbifnRTTIAddProperty,//   "   "
    pbifnRTTINewClass,// typeinfo creator of tkClass $Class
    pbifnRTTINewClassRef,// typeinfo of tkClassRef $ClassRef
    pbifnRTTINewDynArray,// typeinfo of tkDynArray $DynArray
    pbifnRTTINewEnum,// typeinfo of tkEnumeration $Enum
    pbifnRTTINewInt,// typeinfo of tkInt $Int
    pbifnRTTINewMethodVar,// typeinfo of tkMethod $MethodVar
    pbifnRTTINewPointer,// typeinfo of tkPointer $Pointer
    pbifnRTTINewProcSig,// rtl.newTIProcSig
    pbifnRTTINewProcVar,// typeinfo of tkProcVar $ProcVar
    pbifnRTTINewRecord,// typeinfo creator of tkRecord $Record
    pbifnRTTINewRefToProcVar,// typeinfo of tkRefToProcVar $RefToProcVar
    pbifnRTTINewSet,// typeinfo of tkSet $Set
    pbifnRTTINewStaticArray,// typeinfo of tkArray $StaticArray
    pbifnSetCharAt,
    pbifnSet_Clone,
    pbifnSet_Create,
    pbifnSet_Difference,
    pbifnSet_Equal,
    pbifnSet_Exclude,
    pbifnSet_GreaterEqual,
    pbifnSet_Include,
    pbifnSet_Intersect,
    pbifnSet_LowerEqual,
    pbifnSet_NotEqual,
    pbifnSet_Reference,
    pbifnSet_SymDiffSet,
    pbifnSet_Union,
    pbifnSpaceLeft,
    pbifnStringSetLength,
    pbifnUnitInit,
    pbivnExceptObject,
    pbivnImplementation,
    pbivnLoop,
    pbivnLoopEnd,
    pbivnLoopIn,
    pbivnModule,
    pbivnModules,
    pbivnPtrClass,
    pbivnResourceStrings,
    pbivnResourceStringOrg,
    pbivnRTL,
    pbivnRTTI, // $rtti
    pbivnRTTIArray_Dims,
    pbivnRTTIArray_ElType,
    pbivnRTTIClassRef_InstanceType,
    pbivnRTTIEnum_EnumType,
    pbivnRTTIInt_MaxValue,
    pbivnRTTIInt_MinValue,
    pbivnRTTIInt_OrdType,
    pbivnRTTILocal, // $r
    pbivnRTTIMethodKind, // tTypeInfoMethodVar has methodkind
    pbivnRTTIPointer_RefType,
    pbivnRTTIProcFlags,
    pbivnRTTIProcVar_ProcSig,
    pbivnRTTIPropDefault,
    pbivnRTTIPropIndex,
    pbivnRTTIPropStored,
    pbivnRTTISet_CompType,
    pbivnSelf,
    pbivnTObjectDestroy,
    pbivnWith,
    pbitnAnonymousPostfix,
    pbitnIntDouble,
    pbitnTI,
    pbitnTIClass,
    pbitnTIClassRef,
    pbitnTIDynArray,
    pbitnTIEnum,
    pbitnTIInteger,
    pbitnTIMethodVar,
    pbitnTIPointer,
    pbitnTIProcVar,
    pbitnTIRecord,
    pbitnTIRefToProcVar,
    pbitnTISet,
    pbitnTIStaticArray,
    pbitnUIntDouble
    );

const
  Pas2JSBuiltInNames: array[TPas2JSBuiltInName] of string = (
    'arrayConcat', // rtl.arrayConcat
    'arrayCopy', // rtl.arrayCopy
    'length', // rtl.length
    'arraySetLength', // rtl.arraySetLength
    '$clone',
    'as', // rtl.as
    'asExt', // rtl.asExt
    'checkMethodCall',
    '$destroy',
    '$create',
    'createClass', // rtl.createClass
    'createClassExt', // rtl.createClassExt
    'getChar', // rtl.getChar
    'getNumber', // rtl.getNumber
    'getObject', // rtl.getObject
    'getResStr', // rtl.getResStr
    'is', // rtl.is
    'isExt', // rtl.isExt
    'floatToStr', // rtl.floatToStr
    'freeLoc', // rtl.freeLoc
    'free', // rtl.free
    'createCallback', // rtl.createCallback
    'eqCallback', // rtl.eqCallback
    '$main',
    'rc',
    '$equal',
    'addField',
    'addFields',
    'addMethod',
    'addProperty',
    '$Class',
    '$ClassRef',
    '$DynArray',
    '$Enum',
    '$Int',
    '$MethodVar',
    '$Pointer',
    'newTIProcSig',
    '$ProcVar',
    '$Record',
    '$RefToProcVar',
    '$Set',
    '$StaticArray',
    'setCharAt', // rtl.setCharAt
    'cloneSet', // rtl.cloneSet
    'createSet', // rtl.createSet [...]
    'diffSet', // rtl.diffSet -
    'eqSet', // rtl.eqSet =
    'excludeSet', // rtl.excludeSet
    'geSet', // rtl.geSet superset >=
    'includeSet', // rtl.includeSet
    'intersectSet', // rtl.intersectSet *
    'leSet', // rtl.leSet subset <=
    'neSet', // rtl.neSet <>
    'refSet', // rtl.refSet
    'symDiffSet', // rtl.symDiffSet >< (symmetrical difference)
    'unionSet', // rtl.unionSet +
    'spaceLeft', // rtl.spaceLeft
    'strSetLength', // rtl.strSetLength
    '$init',
    '$e',
    '$impl',
    '$l',
    '$end',
    '$in',
    '$mod',
    'pas',
    '$class',
    '$resourcestrings',
    'org',
    'rtl',
    '$rtti',
    'dims',
    'eltype',
    'instancetype',
    'enumtype',
    'maxvalue',
    'minvalue',
    'ordtype',
    '$r',
    'methodkind',
    'reftype',
    'flags',
    'procsig',
    'Default',
    'index',
    'stored',
    'comptype',
    'Self',
    'tObjectDestroy', // rtl.tObjectDestroy
    '$with',
    '$a',
    'NativeInt',
    'tTypeInfo', // rtl.
    'tTypeInfoClass', // rtl.
    'tTypeInfoClassRef', // rtl.
    'tTypeInfoDynArray', // rtl.
    'tTypeInfoEnum', // rtl.
    'tTypeInfoInteger', // rtl.
    'tTypeInfoMethodVar', // rtl.
    'tTypeInfoPointer', // rtl.
    'tTypeInfoProcVar', // rtl.
    'tTypeInfoRecord', // rtl.
    'tTypeInfoRefToProcVar', // rtl.
    'tTypeInfoSet', // rtl.
    'tTypeInfoStaticArray', // rtl.
    'NativeUInt'
    );

  JSReservedWords: array[0..113] of string = (
     // keep sorted, first uppercase, then lowercase !
     'Array',
     'ArrayBuffer',
     'Boolean',
     'DataView',
     'Date',
     'Error',
     'EvalError',
     'Float32Array',
     'Float64Array',
     'Generator',
     'GeneratorFunction',
     'Infinity',
     'Int16Array',
     'Int32Array',
     'Int8Array',
     'InternalError',
     'JSON',
     'Map',
     'Math',
     'NaN',
     'Number',
     'Object',
     'Promise',
     'Proxy',
     'RangeError',
     'ReferenceError',
     'Reflect',
     'RegExp',
     'Set',
     'String',
     'Symbol',
     'SyntaxError',
     'TypeError',
     'URIError',
     'Uint16Array',
     'Uint32Array',
     'Uint8Array',
     'Uint8ClampedArray',
     'WeakMap',
     'WeakSet',
     '__extends',
     '_super',
     'anonymous',
     'apply',
     'arguments',
     'array',
     'await',
     'bind',
     'break',
     'call',
     'case',
     'catch',
     'charAt',
     'charCodeAt',
     'class',
     'constructor',
     'continue',
     'decodeURI',
     'decodeURIComponent',
     'default',
     'delete',
     'do',
     'each',
     'else',
     'encodeURI',
     'encodeURIComponent',
     'enum',
     'escape',
     'eval',
     'export',
     'extends',
     'false',
     'for',
     'function',
     'getPrototypeOf',
     'hasOwnProperty',
     'if',
     'implements',
     'import',
     'in',
     'instanceof',
     'interface',
     'isFinite',
     'isNaN',
     'isPrototypeOf',
     'let',
     'new',
     'null',
     'package',
     'parseFloat',
     'parseInt',
     'private',
     'propertyIsEnumerable',
     'protected',
     'prototype',
     'public',
     'return',
     'static',
     'super',
     'switch',
     'this',
     'throw',
     'toLocaleString',
     'toString',
     'true',
     'try',
     'undefined',
     'unescape',
     'uneval',
     'valueOf',
     'var',
     'while',
     'with',
     'yield'
    );

const
  ClassVarModifiersType = [vmClass,vmStatic];
  LowJSNativeInt = MinSafeIntDouble;
  HighJSNativeInt = MaxSafeIntDouble;
  LowJSBoolean = false;
  HighJSBoolean = true;
Type

  { EPas2JS }

  EPas2JS = Class(Exception)
  public
    PasElement: TPasElement;
    MsgNumber: integer;
    Args: TMessageArgs;
    Id: int64;
    MsgType: TMessageType;
  end;

//------------------------------------------------------------------------------
// Pas2js built-in types
type
  TPas2jsBaseType = (
    pbtNone,
    pbtJSValue
    );
  TPas2jsBaseTypes = set of TPas2jsBaseType;

const
  Pas2jsBaseTypeNames: array[TPas2jsBaseType] of string = (
    'None',
    'JSValue'
    );

//------------------------------------------------------------------------------
// Element CustomData
type

  { TPas2JsElementData }

  TPas2JsElementData = Class(TPasElementBase)
  private
    FElement: TPasElement;
    procedure SetElement(const AValue: TPasElement);
  public
    Owner: TObject; // e.g. a TPasToJSConverter
    Next: TPas2JsElementData; // TPasToJSConverter uses this for its memory chain
    constructor Create; virtual;
    destructor Destroy; override;
    property Element: TPasElement read FElement write SetElement; // can be TPasElement
  end;
  TPas2JsElementDataClass = class of TPas2JsElementData;

  { TPas2JSModuleScope }

  TPas2JSModuleScope = class(TPasModuleScope)
  public
  end;

  { TPas2JSInitialFinalizationScope }

  TPas2JSInitialFinalizationScope = class(TPasInitialFinalizationScope)
  public
    JS: string; // Option coStoreProcJS
  end;

  { TPas2JSClassScope }

  TPas2JSClassScope = class(TPasClassScope)
  public
    NewInstanceFunction: TPasClassFunction;
  end;

  { TPas2JSProcedureScope }

  TPas2JSProcedureScope = class(TPasProcedureScope)
  public
    ResultVarName: string; // valid in implementation ProcScope, empty means use ResolverResultVar
    BodyJS: string; // Option coStoreProcJS: stored in ImplScope
    GlobalJS: TStringList; // Option coStoreProcJS: stored in ImplScope
    procedure AddGlobalJS(const JS: string);
    destructor Destroy; override;
  end;

  { TPas2JSWithExprScope }

  TPas2JSWithExprScope = class(TPasWithExprScope)
  public
    WithVarName: string;
  end;

  { TResElDataPas2JSBaseType - CustomData for compiler built-in types (TPasUnresolvedSymbolRef), e.g. jsvalue }

  TResElDataPas2JSBaseType = class(TResElDataBaseType)
  public
    JSBaseType: TPas2jsBaseType;
  end;

//------------------------------------------------------------------------------
// TPas2JSResolver
const
  msAllPas2jsModeSwitchesReadOnly = [
    msClass,
    msResult,
    msRepeatForward,
    // ToDo: msPointer2Procedure,
    // ToDo: msAutoDeref,
    msInitFinal,
    msOut,
    msDefaultPara,
    // ToDo: msDuplicateNames
    msProperty,
    // ToDo: msDefaultInline
    msExcept,
    // ToDo: msAdvancedRecords
    msDefaultUnicodestring,
    msCBlocks
    ];
  msAllPas2jsModeSwitches = msAllPas2jsModeSwitchesReadOnly+[
    msDelphi,msObjfpc,
    msHintDirective,msNestedComment,
    msExternalClass,
    msIgnoreInterfaces,
    msIgnoreAttributes];

  msAllPas2jsBoolSwitches = [
    bsAssertions,
    bsRangeChecks,
    bsTypeInfo,
    bsOverflowChecks,
    bsHints,
    bsNotes,
    bsWarnings,
    bsMacro,
    bsScopedEnums,
    bsObjectChecks
    ];

  // default parser+scanner options
  po_Pas2js = po_Resolver+[
    po_AsmWhole,
    po_ResolveStandardTypes,
    po_ExtClassConstWithoutExpr,
    po_StopOnUnitInterface];

  btAllJSBaseTypes = [
    btChar,
    btWideChar,
    btString,
    btUnicodeString,
    btDouble,
    btBoolean,
    btByteBool,
    btWordBool,
    btLongBool,
    btQWordBool,
    btByte,
    btShortInt,
    btWord,
    btSmallInt,
    btLongWord,
    btLongint,
    btUIntDouble,
    btIntDouble,
    btPointer
    ];
  bfAllJSBaseProcs = bfAllStandardProcs;

  btAllJSStrings = [btString];
  btAllJSChars = [btChar];
  btAllJSStringAndChars = btAllJSStrings+btAllJSChars;
  btAllJSFloats = [btDouble];
  btAllJSBooleans = [btBoolean];
  btAllJSInteger = [btByte,btShortInt,btWord,btSmallInt,btLongWord,btLongint,
    btIntDouble,btUIntDouble];
  btAllJSValueSrcTypes = [btNil,btUntyped,btPointer]+btAllJSInteger
      +btAllJSStringAndChars+btAllJSFloats+btAllJSBooleans;
  btAllJSValueTypeCastTo = btAllJSInteger
      +btAllJSStringAndChars+btAllJSFloats+btAllJSBooleans+[btPointer];


  DefaultPasResolverOptions = [
    proFixCaseOfOverrides,
    proClassPropertyNonStatic,
    proPropertyAsVarParam,
    proClassOfIs,
    proExtClassInstanceNoTypeMembers,
    proOpenAsDynArrays,
    proProcTypeWithoutIsNested,
    proMethodAddrAsPointer
    ];
type
  TPas2JSResolver = class(TPasResolver)
  private
    FJSBaseTypes: array[TPas2jsBaseType] of TPasUnresolvedSymbolRef;
    FExternalNames: TFPHashList; // list of list of TPasIdentifier
    FFirstElementData, FLastElementData: TPas2JsElementData;
    function GetJSBaseTypes(aBaseType: TPas2jsBaseType): TPasUnresolvedSymbolRef; inline;
    procedure InternalAdd(Item: TPasIdentifier);
    procedure OnClearHashItem(Item, Dummy: pointer);
  protected
    FOverloadScopes: TFPList; // list of TPasIdentifierScope
    function HasOverloadIndex(El: TPasElement): boolean; virtual;
    function GetOverloadIndex(Identifier: TPasIdentifier;
      StopAt: TPasElement): integer;
    function GetOverloadAt(Identifier: TPasIdentifier; var Index: integer): TPasIdentifier;
    function GetOverloadIndex(El: TPasElement): integer;
    function GetOverloadAt(const aName: String; Index: integer): TPasIdentifier;
    function RenameOverload(El: TPasElement): boolean;
    procedure RenameOverloadsInSection(aSection: TPasSection);
    procedure RenameOverloads(DeclEl: TPasElement; Declarations: TFPList);
    procedure RenameSubOverloads(Declarations: TFPList);
    procedure PushOverloadScope(Scope: TPasIdentifierScope);
    procedure PopOverloadScope;
    procedure AddType(El: TPasType); override;
    procedure ResolveImplAsm(El: TPasImplAsmStatement); override;
    procedure ResolveNameExpr(El: TPasExpr; const aName: string;
      Access: TResolvedRefAccess); override;
    procedure FinishModule(CurModule: TPasModule); override;
    procedure FinishEnumType(El: TPasEnumType); override;
    procedure FinishSetType(El: TPasSetType); override;
    procedure FinishRecordType(El: TPasRecordType); override;
    procedure FinishClassType(El: TPasClassType); override;
    procedure FinishVariable(El: TPasVariable); override;
    procedure FinishProcedureType(El: TPasProcedureType); override;
    procedure FinishPropertyOfClass(PropEl: TPasProperty); override;
    procedure CheckConditionExpr(El: TPasExpr;
      const ResolvedEl: TPasResolverResult); override;
    procedure CheckNewInstanceFunction(ClassScope: TPas2JSClassScope); virtual;
    function AddExternalName(const aName: string; El: TPasElement): TPasIdentifier; virtual;
    function FindExternalName(const aName: String): TPasIdentifier; virtual;
    procedure AddExternalPath(aName: string; El: TPasElement);
    procedure ClearElementData; virtual;
  protected
    const
      cJSValueConversion = 2*cTypeConversion;
    // additional base types
    function AddJSBaseType(const aName: string; Typ: TPas2jsBaseType): TResElDataPas2JSBaseType;
    function CheckAssignCompatibilityCustom(const LHS,
      RHS: TPasResolverResult; ErrorEl: TPasElement;
      RaiseOnIncompatible: boolean; var Handled: boolean): integer; override;
    function CheckTypeCastClassInstanceToClass(const FromClassRes,
      ToClassRes: TPasResolverResult; ErrorEl: TPasElement): integer; override;
    function CheckEqualCompatibilityCustomType(const LHS,
      RHS: TPasResolverResult; ErrorEl: TPasElement;
      RaiseOnIncompatible: boolean): integer; override;
    procedure ComputeBinaryExprRes(Bin: TBinaryExpr; out
      ResolvedEl: TPasResolverResult; Flags: TPasResolverComputeFlags;
      var LeftResolved, RightResolved: TPasResolverResult); override;
    procedure BI_TypeInfo_OnGetCallResult(Proc: TResElDataBuiltInProc;
      Params: TParamsExpr; out ResolvedEl: TPasResolverResult); override;
  public
    constructor Create;
    destructor Destroy; override;
    // base types
    function IsJSBaseType(TypeEl: TPasType; Typ: TPas2jsBaseType): boolean;
    function IsJSBaseType(const TypeResolved: TPasResolverResult;
      Typ: TPas2jsBaseType; HasValue: boolean = false): boolean;
    procedure AddObjFPCBuiltInIdentifiers(
      const TheBaseTypes: TResolveBaseTypes;
      const TheBaseProcs: TResolverBuiltInProcs); override;
    function CheckTypeCastRes(const FromResolved,
      ToResolved: TPasResolverResult; ErrorEl: TPasElement;
      RaiseOnError: boolean): integer; override;
    function FindLocalBuiltInSymbol(El: TPasElement): TPasElement; override;
    property JSBaseTypes[aBaseType: TPas2jsBaseType]: TPasUnresolvedSymbolRef read GetJSBaseTypes;
    // compute literals and constants
    function ExtractPasStringLiteral(El: TPasElement; const S: String): TJSString; virtual;
    function ResolverToJSValue(Value: TResEvalValue; ErrorEl: TPasElement): TJSValue; virtual;
    function ComputeConstString(Expr: TPasExpr; StoreCustomData, NotEmpty: boolean): String; virtual;
    procedure CheckAssignExprRangeToCustom(
      const LeftResolved: TPasResolverResult; RValue: TResEvalValue;
      RHS: TPasExpr); override;
    function HasStaticArrayCloneFunc(Arr: TPasArrayType): boolean;
    // CustomData
    function GetElementData(El: TPasElementBase;
      DataClass: TPas2JsElementDataClass): TPas2JsElementData; virtual;
    procedure AddElementData(Data: TPas2JsElementData); virtual;
    function CreateElementData(DataClass: TPas2JsElementDataClass;
      El: TPasElement): TPas2JsElementData; virtual;
    // utility
    function GetBaseDescription(const R: TPasResolverResult; AddPath: boolean=
      false): string; override;
    function HasTypeInfo(El: TPasType): boolean; override;
    function IsTObjectFreeMethod(El: TPasExpr): boolean; virtual;
    function IsExternalBracketAccessor(El: TPasElement): boolean;
  end;

//------------------------------------------------------------------------------
// TConvertContext
type
  TCtxAccess = (
    caRead,  // normal read
    caAssign, // needs setter
    caByReference // needs path, getter and setter
    );

  TFunctionContext = Class;

  { TConvertContext }

  TConvertContextClass = Class of TConvertContext;
  TConvertContext = Class(TObject)
  public
    PasElement: TPasElement;
    JSElement: TJSElement;
    Resolver: TPas2JSResolver;
    Parent: TConvertContext;
    IsGlobal: boolean; // can hold constants and types
    Access: TCtxAccess;
    AccessContext: TConvertContext;
    TmpVarCount: integer;
    ScannerBoolSwitches: TBoolSwitches;
    constructor Create(PasEl: TPasElement; JSEl: TJSElement; aParent: TConvertContext); virtual;
    function GetRootModule: TPasModule;
    function GetFunctionContext: TFunctionContext;
    function GetLocalName(El: TPasElement): string; virtual;
    function GetSelfContext: TFunctionContext;
    function GetContextOfType(aType: TConvertContextClass): TConvertContext;
    function CreateLocalIdentifier(const Prefix: string): string;
    function CurrentModeSwitches: TModeSwitches;
    function GetGlobalFunc: TFunctionContext;
    procedure WriteStack;
    procedure DoWriteStack(Index: integer); virtual;
    function ToString: string; override;
  end;

  { TRootContext }

  TRootContext = Class(TConvertContext)
  public
    ResourceStrings: TJSVarDeclaration;
  end;

  { TFCLocalVar }

  TFCLocalVar = class
  public
    Element: TPasElement;
    Name: string;
    constructor Create(const aName: string; TheEl: TPasElement);
  end;
  TFCLocalVars = array of TFCLocalVar;

  { TFunctionContext
    Module Function: PasElement is TPasProcedure, ThisPas=nil
    Method: PasElement is TPasProcedure, ThisPas is TPasClassType }

  TFunctionContext = Class(TConvertContext)
  public
    LocalVars: TFCLocalVars;
    ThisPas: TPasElement;
    destructor Destroy; override;
    procedure AddLocalVar(const aName: string; El: TPasElement);
    function ToString: string; override;
    function GetLocalName(El: TPasElement): string; override;
    function IndexOfLocalVar(const aName: string): integer;
    function IndexOfLocalVar(El: TPasElement): integer;
    function FindLocalVar(const aName: string): TFCLocalVar;
    function FindLocalVar(El: TPasElement): TFCLocalVar;
    procedure DoWriteStack(Index: integer); override;
  end;

  { TObjectContext }

  TObjectContext  = Class(TConvertContext)
  end;

  { TSectionContext - interface/implementation/program/library
    interface/program/library: PasElement is TPasModule, ThisPas is TPasModule
    implementation: PasElement is TImplementationSection, ThisPas is TPasModule }

  TSectionContext = Class(TFunctionContext)
  public
    constructor Create(PasEl: TPasElement; JSEl: TJSElement; aParent: TConvertContext); override;
  end;

  { TDotContext - used for converting eopSubIdent }

  TDotContext = Class(TConvertContext)
  public
    LeftResolved: TPasResolverResult;
  end;

  { TAssignContext - used for left side of an assign statement }

  TAssignContext = Class(TConvertContext)
  public
    // set when creating:
    LeftResolved: TPasResolverResult;
    RightResolved: TPasResolverResult;
    RightSide: TJSElement;
    // created by ConvertElement:
    PropertyEl: TPasProperty;
    Setter: TPasElement;
    Call: TJSCallExpression;
    constructor Create(PasEl: TPasElement; JSEl: TJSElement; aParent: TConvertContext); override;
  end;

  { TParamContext }

  TParamContext = Class(TConvertContext)
  public
    // set when creating:
    Arg: TPasArgument;
    Expr: TPasExpr;
    ResolvedExpr: TPasResolverResult;
    // created by ConvertElement:
    Getter: TJSElement;
    Setter: TJSElement;
    ReusingReference: boolean; // true = result is a reference, do not create another
    constructor Create(PasEl: TPasElement; JSEl: TJSElement; aParent: TConvertContext); override;
  end;

//------------------------------------------------------------------------------
// TPasToJSConverter
type
  TPasToJsConverterOption = (
    coLowerCase, // lowercase all identifiers, except conflicts with JS reserved words
    coSwitchStatement, // convert case-of into switch instead of if-then-else
    coEnumNumbers, // use enum numbers instead of names
    coUseStrict,   // insert 'use strict'
    coNoTypeInfo,  // do not generate RTTI
    coEliminateDeadCode,  // skip code that is never executed
    coStoreImplJS  // store references to JS code in procscopes
    );
  TPasToJsConverterOptions = set of TPasToJsConverterOption;

  TPas2JSIsElementUsedEvent = function(Sender: TObject; El: TPasElement): boolean of object;

  TPasToJsPlatform = (
    PlatformBrowser,
    PlatformNodeJS
    );
  TPasToJsPlatforms = set of TPasToJsPlatform;
const
  PasToJsPlatformNames: array[TPasToJsPlatform] of string = (
   'Browser',
   'NodeJS'
    );
type
  TPasToJsProcessor = (
    ProcessorECMAScript5,
    ProcessorECMAScript6
    );
  TPasToJsProcessors = set of TPasToJsProcessor;
const
  PasToJsProcessorNames: array[TPasToJsProcessor] of string = (
   'ECMAScript5',
   'ECMAScript6'
    );

type
  TJSReservedWordList = array of String;

  TRefPathKind = (
    rpkPath,      // e.g. "TObject"
    rpkPathWithDot, // e.g. "TObject."
    rpkPathAndName // e.g. "TObject.ClassName"
    );

  { TPasToJSConverter }

  TPasToJSConverter = Class(TObject)
  private
    // inline at top, only functions declared after the inline implementation actually use it
    function GetUseEnumNumbers: boolean; inline;
    function GetUseLowerCase: boolean; inline;
    function GetUseSwitchStatement: boolean; inline;
  private
    type
      TForLoopFindData = record
        ForLoop: TPasImplForLoop;
        LoopVar: TPasElement;
        FoundLoop: boolean;
        LoopVarWrite: boolean; // true if first access of LoopVar after loop is a write
        LoopVarRead: boolean; // true if first access of LoopVar after loop is a read
      end;
      PForLoopFindData = ^TForLoopFindData;
    procedure ForLoop_OnProcBodyElement(El: TPasElement; arg: pointer);
  private
    FBuiltInNames: array[TPas2JSBuiltInName] of string;
    FOnIsElementUsed: TPas2JSIsElementUsedEvent;
    FOnIsTypeInfoUsed: TPas2JSIsElementUsedEvent;
    FOptions: TPasToJsConverterOptions;
    FPreservedWords: TJSReservedWordList; // sorted with CompareStr
    FTargetPlatform: TPasToJsPlatform;
    FTargetProcessor: TPasToJsProcessor;
    Function CreatePrimitiveDotExpr(AName: string; Src: TPasElement): TJSElement;
    Function CreateSubDeclNameExpr(El: TPasElement; const Name: string;
      AContext: TConvertContext; PosEl: TPasElement = nil): TJSElement;
    Function CreateIdentifierExpr(El: TPasElement; AContext: TConvertContext): TJSElement;
    Function CreateIdentifierExpr(AName: string; El: TPasElement; AContext: TConvertContext): TJSElement;
    Function CreateSwitchStatement(El: TPasImplCaseOf; AContext: TConvertContext): TJSElement;
    Function CreateTypeDecl(El: TPasType; AContext: TConvertContext): TJSElement;
    Function CreateVarDecl(El: TPasVariable; AContext: TConvertContext): TJSElement;
    Procedure AddToSourceElements(Src: TJSSourceElements; El: TJSElement);
    procedure RemoveFromSourceElements(Src: TJSSourceElements;
      El: TJSElement);
    function GetBuildInNames(bin: TPas2JSBuiltInName): string;
    procedure SetBuildInNames(bin: TPas2JSBuiltInName; const AValue: string);
    procedure SetPreservedWords(const AValue: TJSReservedWordList);
    procedure SetUseEnumNumbers(const AValue: boolean);
    procedure SetUseLowerCase(const AValue: boolean);
    procedure SetUseSwitchStatement(const AValue: boolean);
  protected
    // Error functions
    Procedure DoError(Id: int64; Const Msg : String);
    Procedure DoError(Id: int64; Const Msg : String; Const Args : Array of Const);
    Procedure DoError(Id: int64; MsgNumber: integer; const MsgPattern: string; Const Args : Array of Const; El: TPasElement);
    procedure RaiseNotSupported(El: TPasElement; AContext: TConvertContext; Id: int64; const Msg: string = '');
    procedure RaiseIdentifierNotFound(Identifier: string; El: TPasElement; Id: int64);
    procedure RaiseInconsistency(Id: int64; El: TPasElement);
    // Computation, value conversions
    Function GetExpressionValueType(El: TPasExpr; AContext: TConvertContext ): TJSType; virtual;
    Function GetPasIdentValueType(AName: String; AContext: TConvertContext): TJSType; virtual;
    Function ComputeConstString(Expr: TPasExpr; AContext: TConvertContext; NotEmpty: boolean): String; virtual;
    Function IsExternalClassConstructor(El: TPasElement): boolean;
    Function IsLiteralInteger(El: TJSElement; out Number: MaxPrecInt): boolean;
    // Name mangling
    Function TransformVariableName(El: TPasElement; Const AName: String; AContext : TConvertContext): String; virtual;
    Function TransformVariableName(El: TPasElement; AContext : TConvertContext) : String; virtual;
    Function TransformModuleName(El: TPasModule; AddModulesPrefix: boolean; AContext : TConvertContext) : String; virtual;
    Function IsPreservedWord(const aName: string): boolean; virtual;
    Function GetTypeInfoName(El: TPasType; AContext: TConvertContext;
      ErrorEl: TPasElement): String; virtual;
    // Never create an element manually, always use the below functions
    Function IsElementUsed(El: TPasElement): boolean; virtual;
    Function IsSystemUnit(aModule: TPasModule): boolean; virtual;
    Function HasTypeInfo(El: TPasType; AContext: TConvertContext): boolean; virtual;
    Function IsClassRTTICreatedBefore(aClass: TPasClassType; Before: TPasElement; AConText: TConvertContext): boolean;
    Function CreateElement(C: TJSElementClass; Src: TPasElement): TJSElement; virtual;
    Function CreateFreeOrNewInstanceExpr(Ref: TResolvedReference;
      AContext : TConvertContext): TJSCallExpression; virtual;
    Function CreateFunctionSt(El: TPasElement; WithBody: boolean = true;
      WithSrc: boolean = false): TJSFunctionDeclarationStatement;
    Function CreateFunctionDef(El: TPasElement; WithBody: boolean = true;
      WithSrc: boolean = false): TJSFuncDef;
    Procedure CreateProcedureCall(var Call: TJSCallExpression; Args: TParamsExpr;
      TargetProc: TPasProcedureType; AContext: TConvertContext); virtual;
    Procedure CreateProcedureCallArgs(Elements: TJSArrayLiteralElements;
      Args: TParamsExpr; TargetProc: TPasProcedureType; AContext: TConvertContext); virtual;
    Function CreateProcCallArg(El: TPasExpr; TargetArg: TPasArgument;
      AContext: TConvertContext): TJSElement; virtual;
    Function CreateProcCallArgRef(El: TPasExpr; ResolvedEl: TPasResolverResult;
      TargetArg: TPasArgument;  AContext: TConvertContext): TJSElement; virtual;
    Function CreateArgumentAccess(Arg: TPasArgument; AContext: TConvertContext;
      PosEl: TPasElement): TJSElement; virtual;
    Function CreateUnary(Members: array of string; E: TJSElement): TJSUnary;
    Function CreateMemberExpression(Members: array of string): TJSDotMemberExpression;
    Function CreateCallExpression(El: TPasElement): TJSCallExpression;
    Function CreateCallCharCodeAt(Arg: TJSElement; aNumber: integer; El: TPasElement): TJSCallExpression; virtual;
    Function CreateCallFromCharCode(Arg: TJSElement; El: TPasElement): TJSCallExpression; virtual;
    Function CreateUsesList(UsesSection: TPasSection; AContext : TConvertContext): TJSArrayLiteral;
    Procedure AddToStatementList(var First, Last: TJSStatementList;
      Add: TJSElement; Src: TPasElement);
    Procedure AddToVarStatement(VarStat: TJSVariableStatement; Add: TJSElement;
      Src: TPasElement);
    Function CreateValInit(PasType: TPasType; Expr: TPasExpr; El: TPasElement;
      AContext: TConvertContext): TJSElement; virtual;
    Function CreateVarInit(El: TPasVariable; AContext: TConvertContext): TJSElement; virtual;
    Function CreateVarStatement(const aName: String; Init: TJSElement;
      El: TPasElement): TJSVariableStatement; virtual;
    Function CreateVarDecl(const aName: String; Init: TJSElement; El: TPasElement): TJSVarDeclaration; virtual;
    Function CreateLiteralNumber(El: TPasElement; const n: TJSNumber): TJSLiteral; virtual;
    Function CreateLiteralString(El: TPasElement; const s: string): TJSLiteral; virtual;
    Function CreateLiteralJSString(El: TPasElement; const s: TJSString): TJSLiteral; virtual;
    Function CreateLiteralBoolean(El: TPasElement; b: boolean): TJSLiteral; virtual;
    Function CreateLiteralNull(El: TPasElement): TJSLiteral; virtual;
    Function CreateLiteralUndefined(El: TPasElement): TJSLiteral; virtual;
    Function CreateSetLiteralElement(Expr: TPasExpr; AContext: TConvertContext): TJSElement; virtual;
    Procedure ConvertCharLiteralToInt(Lit: TJSLiteral; ErrorEl: TPasElement; AContext: TConvertContext); virtual;
    Function ClonePrimaryExpression(El: TJSPrimaryExpression; Src: TPasElement): TJSPrimaryExpression;
    Function CreateRecordInit(aRecord: TPasRecordType; Expr: TPasElement;
      El: TPasElement; AContext: TConvertContext): TJSElement; virtual;
    Function CreateArrayInit(ArrayType: TPasArrayType; Expr: TPasExpr;
      El: TPasElement; AContext: TConvertContext): TJSElement; virtual;
    Function CreateCmpArrayWithNil(El: TPasElement; JSArray: TJSElement;
      OpCode: TExprOpCode): TJSElement; virtual;
    Function CreateReferencePath(El: TPasElement; AContext : TConvertContext;
      Kind: TRefPathKind; Full: boolean = false; Ref: TResolvedReference = nil): string; virtual;
    Function CreateReferencePathExpr(El: TPasElement; AContext : TConvertContext;
      Full: boolean = false; Ref: TResolvedReference = nil): TJSElement; virtual;
    Function CreateImplementationSection(El: TPasModule; AContext: TConvertContext): TJSFunctionDeclarationStatement;
    Procedure CreateInitSection(El: TPasModule; Src: TJSSourceElements; AContext: TConvertContext);
    Function CreateDotExpression(aParent: TPasElement; Left, Right: TJSElement): TJSElement; virtual;
    Function CreateReferencedSet(El: TPasElement; SetExpr: TJSElement): TJSElement; virtual;
    Function CreateCloneRecord(El: TPasElement; RecTypeEl: TPasRecordType;
      RecordExpr: TJSElement; AContext: TConvertContext): TJSElement; virtual;
    Function CreateCloneStaticArray(El: TPasElement; ArrTypeEl: TPasArrayType;
      ArrayExpr: TJSElement; AContext: TConvertContext): TJSElement; virtual;
    Function CreateCallback(El: TPasElement; ResolvedEl: TPasResolverResult;
      AContext: TConvertContext): TJSElement; virtual;
    Function CreateAssignStatement(LeftEl: TPasElement; AssignContext: TAssignContext): TJSElement; virtual;
    Function CreateTypeInfoRef(El: TPasType; AContext: TConvertContext;
      ErrorEl: TPasElement): TJSElement; virtual;
    Function CreateRTTIArgList(Parent: TPasElement; Args: TFPList;
      AContext: TConvertContext): TJSElement; virtual;
    Procedure AddRTTIArgument(Arg: TPasArgument; TargetParams: TJSArrayLiteral;
      AContext: TConvertContext); virtual;
    Function CreateRTTINewType(El: TPasType; const CallFuncName: string;
      IsForward: boolean; AContext: TConvertContext; out ObjLit: TJSObjectLiteral): TJSCallExpression; virtual;
    Function CreateRTTIClassField(V: TPasVariable; AContext: TConvertContext): TJSElement; virtual;
    Function CreateRTTIClassMethod(Proc: TPasProcedure; AContext: TConvertContext): TJSElement; virtual;
    Function CreateRTTIClassProperty(Prop: TPasProperty; AContext: TConvertContext): TJSElement; virtual;
    Procedure CreateRTTIAnonymous(El: TPasType; AContext: TConvertContext;
      var First, Last: TJSStatementList); virtual;
    Function CreateGetEnumeratorLoop(El: TPasImplForLoop;
      AContext: TConvertContext): TJSElement; virtual;
    Function CreateCallRTLFreeLoc(Setter, Getter: TJSElement; Src: TPasElement): TJSElement; virtual;
    Function CreatePropertyGet(Prop: TPasProperty; Ref: TResolvedReference;
      AContext: TConvertContext; PosEl: TPasElement): TJSElement; virtual;
    Function StorePrecompiledJS(El: TJSElement): string; virtual;
    // Statements
    Function ConvertImplBlockElements(El: TPasImplBlock; AContext: TConvertContext; NilIfEmpty: boolean): TJSElement; virtual;
    Function ConvertBeginEndStatement(El: TPasImplBeginBlock; AContext: TConvertContext; NilIfEmpty: boolean): TJSElement; virtual;
    Function ConvertStatement(El: TPasImplStatement; AContext: TConvertContext ): TJSElement; virtual;
    Function ConvertAssignStatement(El: TPasImplAssign; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertRaiseStatement(El: TPasImplRaise; AContext: TConvertContext ): TJSElement; virtual;
    Function ConvertIfStatement(El: TPasImplIfElse; AContext: TConvertContext ): TJSElement; virtual;
    Function ConvertWhileStatement(El: TPasImplWhileDo; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertRepeatStatement(El: TPasImplRepeatUntil; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertForStatement(El: TPasImplForLoop; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertFinalizationSection(El: TFinalizationSection; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertInitializationSection(El: TInitializationSection; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertSimpleStatement(El: TPasImplSimple; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertWithStatement(El: TPasImplWithDo; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertTryStatement(El: TPasImplTry; AContext: TConvertContext ): TJSElement; virtual;
    Function ConvertExceptOn(El: TPasImplExceptOn; AContext: TConvertContext): TJSElement;
    Function ConvertCaseOfStatement(El: TPasImplCaseOf; AContext: TConvertContext): TJSElement;
    Function ConvertAsmStatement(El: TPasImplAsmStatement; AContext: TConvertContext): TJSElement;
    // Expressions
    Function ConvertConstValue(Value: TResEvalValue; AContext: TConvertContext; El: TPasElement): TJSElement; virtual;
    Function ConvertArrayValues(El: TArrayValues; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertInheritedExpression(El: TInheritedExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertNilExpr(El: TNilExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertParamsExpression(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertArrayParams(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertFuncParams(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertExternalConstructor(Left: TPasElement; Ref: TResolvedReference;
      ParamsExpr: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertTObjectFree(Bin: TBinaryExpr; NameExpr: TPasExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertTypeCastToBaseType(El: TParamsExpr; AContext: TConvertContext; ToBaseTypeData: TResElDataBaseType): TJSElement; virtual;
    Function ConvertSetLiteral(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertOpenArrayParam(ElType: TPasType; El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBuiltIn_Length(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBuiltIn_SetLength(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBuiltIn_ExcludeInclude(El: TParamsExpr; AContext: TConvertContext; IsInclude: boolean): TJSElement; virtual;
    Function ConvertBuiltInContinue(El: TPasExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBuiltInBreak(El: TPasExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBuiltIn_Exit(El: TPasExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBuiltIn_IncDec(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBuiltIn_Assigned(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBuiltIn_Chr(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBuiltIn_Ord(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBuiltIn_LowHigh(El: TParamsExpr; AContext: TConvertContext; IsLow: boolean): TJSElement; virtual;
    Function ConvertBuiltIn_PredSucc(El: TParamsExpr; AContext: TConvertContext; IsPred: boolean): TJSElement; virtual;
    Function ConvertBuiltIn_StrProc(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBuiltIn_StrFunc(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBuiltInStrParam(El: TPasExpr; AContext: TConvertContext; IsStrFunc, IsFirst: boolean): TJSElement; virtual;
    Function ConvertBuiltIn_ConcatArray(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBuiltIn_CopyArray(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBuiltIn_InsertArray(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBuiltIn_DeleteArray(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBuiltIn_TypeInfo(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBuiltIn_Assert(El: TParamsExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertRecordValues(El: TRecordValues; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertSelfExpression(El: TSelfExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBinaryExpression(El: TBinaryExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBinaryExpressionRes(El: TBinaryExpr; AContext: TConvertContext;
      const LeftResolved, RightResolved: TPasResolverResult; var A,B: TJSElement): TJSElement; virtual;
    Function ConvertSubIdentExpression(El: TBinaryExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertBoolConstExpression(El: TBoolConstExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertPrimitiveExpression(El: TPrimitiveExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertIdentifierExpr(El: TPasExpr; const aName: string; AContext : TConvertContext): TJSElement; virtual;
    Function ConvertUnaryExpression(El: TUnaryExpr; AContext: TConvertContext): TJSElement; virtual;
    // Convert declarations
    Function ConvertElement(El : TPasElement; AContext: TConvertContext) : TJSElement; virtual;
    Function ConvertProperty(El: TPasProperty; AContext: TConvertContext ): TJSElement; virtual;
    Function ConvertConst(El: TPasConst; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertDeclarations(El: TPasDeclarations; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertExportSymbol(El: TPasExportSymbol; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertExpression(El: TPasExpr; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertImplBlock(El: TPasImplBlock; AContext: TConvertContext ): TJSElement; virtual;
    Function ConvertLabelMark(El: TPasImplLabelMark; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertLabels(El: TPasLabels; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertModule(El: TPasModule; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertPackage(El: TPasPackage; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertProcedure(El: TPasProcedure; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertResString(El: TPasResString; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertVariable(El: TPasVariable; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertRecordType(El: TPasRecordType; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertClassType(El: TPasClassType; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertClassForwardType(El: TPasClassType; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertClassExternalType(El: TPasClassType; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertClassOfType(El: TPasClassOfType; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertEnumType(El: TPasEnumType; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertSetType(El: TPasSetType; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertRangeType(El: TPasRangeType; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertPointerType(El: TPasPointerType; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertProcedureType(El: TPasProcedureType; AContext: TConvertContext): TJSElement; virtual;
    Function ConvertArrayType(El: TPasArrayType; AContext: TConvertContext): TJSElement; virtual;
  Public
    // RTTI, TypeInfo constants
    const
      // TParamFlag
      pfVar = 1;
      pfConst = 2;
      pfOut = 4;
      pfArray = 8;
      // TProcedureFlag
      pfStatic = 1;
      pfVarargs = 2;
      pfExternal = 4;
      // PropertyFlag
      pfGetFunction = 1; // getter is a function
      pfSetProcedure = 2; // setter is a function
      pfStoredTrue = 0; // stored true, always
      pfStoredFalse = 4; // stored false, never
      pfStoredField = 8; // stored field, field name is in Stored
      pfStoredFunction = 12; // stored function, function name is in Stored
      pfHasIndex = 16; { if getter is function, append Index as last param
                         if setter is function, append Index as second last param }
    type
      TMethodKind = (
        mkProcedure,      // 0  default
        mkFunction,       // 1
        mkConstructor,    // 2
        mkDestructor,     // 3
        mkClassProcedure, // 4
        mkClassFunction   // 5
        );
      TOrdType  = (
        otSByte,      // 0
        otUByte,      // 1
        otSWord,      // 2
        otUWord,      // 3
        otSLong,      // 4
        otULong,      // 5
        otSIntDouble, // 6 NativeInt
        otUIntDouble  // 7 NativeUInt
        );
    Function GetOrdType(MinValue, MaxValue: MaxPrecInt; ErrorEl: TPasElement): TOrdType; virtual;
  Public
    Constructor Create;
    destructor Destroy; override;
    Function ConvertPasElement(El: TPasElement; Resolver: TPas2JSResolver) : TJSElement;
    // options
    Property Options: TPasToJsConverterOptions read FOptions write FOptions;
    Property TargetPlatform: TPasToJsPlatform read FTargetPlatform write FTargetPlatform;
    Property TargetProcessor: TPasToJsProcessor read FTargetProcessor write FTargetProcessor;
    Property UseLowerCase: boolean read GetUseLowerCase write SetUseLowerCase default true;
    Property UseSwitchStatement: boolean read GetUseSwitchStatement write SetUseSwitchStatement;// default false, because slower than "if" in many engines
    Property UseEnumNumbers: boolean read GetUseEnumNumbers write SetUseEnumNumbers; // default false
    Property OnIsElementUsed: TPas2JSIsElementUsedEvent read FOnIsElementUsed write FOnIsElementUsed;
    Property OnIsTypeInfoUsed: TPas2JSIsElementUsedEvent read FOnIsTypeInfoUsed write FOnIsTypeInfoUsed;
    Property PreservedWords: TJSReservedWordList read FPreservedWords write SetPreservedWords;
    // names
    Property BuildInNames[bin: TPas2JSBuiltInName]: string read GetBuildInNames write SetBuildInNames;
  end;

var
  JSTypeCaptions: array[TJSType] of string = (
    'undefined',
    'null',
    'boolean',
    'number',
    'string',
    'object',
    'reference',
    'completion'
    );

function CodePointToJSString(u: longword): TJSString;
function PosLast(c: char; const s: string): integer;

implementation

const
  TempRefObjGetterName = 'get';
  TempRefObjSetterName = 'set';
  TempRefObjSetterArgName = 'v';

function CodePointToJSString(u: longword): TJSString;
begin
  if u < $10000 then
    // Note: codepoints $D800 - $DFFF are reserved
    Result:=WideChar(u)
  else
    Result:=WideChar($D800+((u - $10000) shr 10))+WideChar($DC00+((u - $10000) and $3ff));
end;

function PosLast(c: char; const s: string): integer;
begin
  Result:=length(s);
  while (Result>0) and (s[Result]<>c) do dec(Result);
end;

{ TPas2JSProcedureScope }

procedure TPas2JSProcedureScope.AddGlobalJS(const JS: string);
begin
  if GlobalJS=nil then
    GlobalJS:=TStringList.Create;
  GlobalJS.Add(Js);
end;

destructor TPas2JSProcedureScope.Destroy;
begin
  FreeAndNil(GlobalJS);
  inherited Destroy;
end;

{ TFCLocalVar }

constructor TFCLocalVar.Create(const aName: string; TheEl: TPasElement);
begin
  Name:=aName;
  Element:=TheEl;
end;

{ TPas2JSResolver }

// inline
function TPas2JSResolver.GetJSBaseTypes(aBaseType: TPas2jsBaseType
  ): TPasUnresolvedSymbolRef;
begin
  Result:=TPasUnresolvedSymbolRef(FJSBaseTypes[aBaseType]);
end;

procedure TPas2JSResolver.InternalAdd(Item: TPasIdentifier);
var
  Index: Integer;
  OldItem: TPasIdentifier;
  aName: ShortString;
begin
  aName:=Item.Identifier;
  Index:=FExternalNames.FindIndexOf(aName);
  {$IFDEF VerbosePasResolver}
  if Item.Owner<>nil then
    raise Exception.Create('20170322235419');
  Item.Owner:=Self;
  {$ENDIF}
  //writeln('  Index=',Index);
  if Index>=0 then
    begin
    // insert LIFO - last in, first out
    OldItem:=TPasIdentifier(FExternalNames.List^[Index].Data);
    {$IFDEF VerbosePasResolver}
    if OldItem.Identifier<>aName then
      raise Exception.Create('20170322235429');
    {$ENDIF}
    Item.NextSameIdentifier:=OldItem;
    FExternalNames.List^[Index].Data:=Item;
    end
  else
    begin
    FExternalNames.Add(aName, Item);
    {$IFDEF VerbosePasResolver}
    if FindExternalName(Item.Identifier)<>Item then
      raise Exception.Create('20170322235433');
    {$ENDIF}
    end;
end;

procedure TPas2JSResolver.OnClearHashItem(Item, Dummy: pointer);
var
  PasIdentifier: TPasIdentifier absolute Item;
  Ident: TPasIdentifier;
begin
  if Dummy=nil then ;
  //writeln('TPas2JSResolver.OnClearItem ',PasIdentifier.Identifier+':'+PasIdentifier.ClassName);
  while PasIdentifier<>nil do
    begin
    Ident:=PasIdentifier;
    PasIdentifier:=PasIdentifier.NextSameIdentifier;
    Ident.Free;
    end;
end;

function TPas2JSResolver.HasOverloadIndex(El: TPasElement): boolean;
var
  C: TClass;
  ProcScope: TPasProcedureScope;
begin
  C:=El.ClassType;
  if C=TPasProperty then
    exit(false)
  else if C=TPasClassType then
    begin
    if TPasClassType(El).IsForward then
      exit(false);
    end
  else if C.InheritsFrom(TPasProcedure) then
    begin
    if TPasProcedure(El).IsOverride then
      exit(true);
    // Note: external proc pollutes the name space
    ProcScope:=TPasProcedureScope(El.CustomData);
    if ProcScope.DeclarationProc<>nil then
      // implementation proc -> only count the header -> skip
      exit(false);
    end;
  Result:=true;
end;

function TPas2JSResolver.GetOverloadIndex(Identifier: TPasIdentifier;
  StopAt: TPasElement): integer;
// if not found return number of overloads
// if found return index in overloads
var
  El: TPasElement;
begin
  Result:=0;
  // iterate from last added to first added
  // Note: the first added has Index=0
  while Identifier<>nil do
    begin
    El:=Identifier.Element;
    Identifier:=Identifier.NextSameIdentifier;
    if El=StopAt then
      begin
      Result:=0;
      continue;
      end;
    if HasOverloadIndex(El) then
      inc(Result);
    end;
end;

function TPas2JSResolver.GetOverloadAt(Identifier: TPasIdentifier;
  var Index: integer): TPasIdentifier;
// if found Result<>nil and Index=0
// if not found Result=nil and Index is reduced by number of overloads
var
  El: TPasElement;
  CurIdent: TPasIdentifier;
  Count: Integer;
begin
  if Identifier=nil then exit(nil);
  // Note: the Identifier chain is from last added to first added
  // -> get length of chain
  Count:=0;
  CurIdent:=Identifier;
  while CurIdent<>nil do
    begin
    El:=CurIdent.Element;
    CurIdent:=CurIdent.NextSameIdentifier;
    if HasOverloadIndex(El) then
      inc(Count);
    end;
  if Count<=Index then
    begin
    // Index is not in this scope
    dec(Index);
    exit(nil);
    end;
  // Index is in this scope -> find it
  CurIdent:=Identifier;
  while CurIdent<>nil do
    begin
    if HasOverloadIndex(CurIdent.Element) then
      begin
      dec(Count);
      if (Index=Count) then
        begin
        Index:=0;
        Result:=CurIdent;
        exit;
        end;
      end;
    CurIdent:=CurIdent.NextSameIdentifier;
    end;
end;

function TPas2JSResolver.GetOverloadIndex(El: TPasElement): integer;
var
  i: Integer;
  Identifier: TPasIdentifier;
begin
  Result:=0;
  for i:=FOverloadScopes.Count-1 downto 0 do
    begin
    // find last added
    Identifier:=TPasIdentifierScope(FOverloadScopes[i]).FindLocalIdentifier(El.Name);
    // add count or index
    inc(Result,GetOverloadIndex(Identifier,El));
    end;
  // find in external names
  Identifier:=FindExternalName(El.Name);
  // add count or index
  inc(Result,GetOverloadIndex(Identifier,El));
end;

function TPas2JSResolver.GetOverloadAt(const aName: String; Index: integer
  ): TPasIdentifier;
var
  i: Integer;
begin
  Result:=nil;
  for i:=FOverloadScopes.Count-1 downto 0 do
    begin
    // find last added
    Result:=TPasIdentifierScope(FOverloadScopes[i]).FindLocalIdentifier(aName);
    Result:=GetOverloadAt(Result,Index);
    if Result<>nil then
      exit;
    end;
  // find in external names
  Result:=FindExternalName(aName);
  Result:=GetOverloadAt(Result,Index);
end;

function TPas2JSResolver.RenameOverload(El: TPasElement): boolean;
var
  OverloadIndex: Integer;

  function GetDuplicate: TPasElement;
  var
    Duplicate: TPasIdentifier;
  begin
    Duplicate:=GetOverloadAt(El.Name,0);
    Result:=Duplicate.Element;
  end;

var
  NewName: String;
  Duplicate: TPasElement;
begin
  // => count overloads in this section
  OverloadIndex:=GetOverloadIndex(El);
  if OverloadIndex=0 then
    exit(false); // there is no overload

  if (El.ClassType=TPasClassFunction)
      and (TPas2JSClassScope(TPasClassType(El.Parent).CustomData).NewInstanceFunction=El) then
    begin
    Duplicate:=GetDuplicate;
    RaiseMsg(20170324234324,nNewInstanceFunctionMustNotHaveOverloadAtX,
      sNewInstanceFunctionMustNotHaveOverloadAtX,[GetElementSourcePosStr(Duplicate)],El);
    end;
  if El.Visibility=visPublished then
    begin
    Duplicate:=GetDuplicate;
    RaiseMsg(20170413220924,nDuplicateIdentifier,sDuplicateIdentifier,
      [Duplicate.Name,GetElementSourcePosStr(Duplicate)],El);
    end;

  NewName:=El.Name+'$'+IntToStr(OverloadIndex);
  {$IFDEF VerbosePas2JS}
  writeln('TPas2JSResolver.RenameOverload "',El.Name,'" has overload. NewName="',NewName,'"');
  {$ENDIF}
  El.Name:=NewName;
  Result:=true;
end;

procedure TPas2JSResolver.RenameOverloadsInSection(aSection: TPasSection);
var
  ImplSection: TImplementationSection;
  SectionClass: TClass;
begin
  if aSection=nil then exit;
  PushOverloadScope(aSection.CustomData as TPasIdentifierScope);
  RenameOverloads(aSection,aSection.Declarations);
  SectionClass:=aSection.ClassType;
  if SectionClass=TInterfaceSection then
    begin
    // unit interface
    // first rename all overloads in interface and implementation
    ImplSection:=(aSection.Parent as TPasModule).ImplementationSection;
    if ImplSection<>nil then
      begin
      PushOverloadScope(ImplSection.CustomData as TPasIdentifierScope);
      RenameOverloads(ImplSection,ImplSection.Declarations);
      end;
    // and then rename all nested overloads (e.g. methods)
    // Important: nested overloads must check both interface and implementation
    RenameSubOverloads(aSection.Declarations);
    if ImplSection<>nil then
      begin
      RenameSubOverloads(ImplSection.Declarations);
      PopOverloadScope;
      end;
    end
  else
    begin
    // program or library
    RenameSubOverloads(aSection.Declarations);
    end;
  PopOverloadScope;
  {$IFDEF VerbosePas2JS}
  writeln('TPas2JSResolver.RenameOverloadsInSection END ',GetObjName(aSection));
  {$ENDIF}
end;

procedure TPas2JSResolver.RenameOverloads(DeclEl: TPasElement;
  Declarations: TFPList);
var
  i: Integer;
  El: TPasElement;
  Proc: TPasProcedure;
  ProcScope: TPasProcedureScope;
begin
  //IsExternalClass:=(DeclEl is TPasClassType) and (TPasClassType(DeclEl).IsExternal);
  if DeclEl=nil then;
  for i:=0 to Declarations.Count-1 do
    begin
    El:=TPasElement(Declarations[i]);
    if (El is TPasProcedure) then
      begin
      Proc:=TPasProcedure(El);
      ProcScope:=Proc.CustomData as TPasProcedureScope;
      //writeln('TPas2JSResolver.RenameOverloads Proc=',Proc.Name,' DeclarationProc=',GetObjName(ProcScope.DeclarationProc),' ImplProc=',GetObjName(ProcScope.ImplProc),' ClassScope=',GetObjName(ProcScope.ClassScope));
      if ProcScope.DeclarationProc<>nil then
        begin
        if ProcScope.ImplProc<>nil then
          RaiseInternalError(20170221110853);
        // proc implementation (not forward) -> skip
        continue;
        end;
      if Proc.IsOverride then
        begin
        if ProcScope.OverriddenProc=nil then
          RaiseInternalError(20171205183502);
        if Proc.Name<>ProcScope.OverriddenProc.Name then
          begin
          Proc.Name:=ProcScope.OverriddenProc.Name;
          if ProcScope.ImplProc<>nil then
            ProcScope.ImplProc.Name:=Proc.Name;
          end;
        Continue;
        end
      else if Proc.IsExternal then
        begin
        // Note: Pascal names of external procs are not in the generated JS,
        // so no need to rename them
        continue;
        end;
      // proc declaration (header, not body)
      if RenameOverload(Proc) then
        if ProcScope.ImplProc<>nil then
          ProcScope.ImplProc.Name:=Proc.Name;
      end;
    end;
  {$IFDEF VerbosePas2JS}
  writeln('TPas2JSResolver.RenameOverloads END ',GetObjName(DeclEl));
  {$ENDIF}
end;

procedure TPas2JSResolver.RenameSubOverloads(Declarations: TFPList);
var
  i, OldScopeCount: Integer;
  El: TPasElement;
  Proc, ImplProc: TPasProcedure;
  ProcScope: TPasProcedureScope;
  ClassScope, aScope: TPasClassScope;
  ClassEl: TPasClassType;
  C: TClass;
begin
  for i:=0 to Declarations.Count-1 do
    begin
    El:=TPasElement(Declarations[i]);
    C:=El.ClassType;
    if C.InheritsFrom(TPasProcedure) then
      begin
      Proc:=TPasProcedure(El);
      if Proc.IsAbstract or Proc.IsExternal then continue;
      ProcScope:=Proc.CustomData as TPasProcedureScope;
      {$IFDEF VerbosePas2JS}
      writeln('TPas2JSResolver.RenameSubOverloads Proc=',Proc.Name,' DeclarationProc=',GetObjName(ProcScope.DeclarationProc),' ImplProc=',GetObjName(ProcScope.ImplProc),' ClassScope=',GetObjName(ProcScope.ClassScope));
      {$ENDIF}
      if ProcScope.DeclarationProc<>nil then
        // proc implementation (not forward) -> skip
        continue;
      ImplProc:=Proc;
      if ProcScope.ImplProc<>nil then
        begin
        // this proc has a separate implementation
        // -> switch to implementation
        ImplProc:=ProcScope.ImplProc;
        ProcScope:=ImplProc.CustomData as TPasProcedureScope;
        end;
      PushOverloadScope(ProcScope);
      // first rename all overloads on this level
      RenameOverloads(ImplProc.Body,ImplProc.Body.Declarations);
      // then process nested procedures
      RenameSubOverloads(ImplProc.Body.Declarations);
      PopOverloadScope;
      end
    else if C=TPasClassType then
      begin
      ClassEl:=TPasClassType(El);
      if ClassEl.IsForward then continue;
      if ClassEl.ObjKind=okInterface then
        continue;
      ClassScope:=El.CustomData as TPas2JSClassScope;
      OldScopeCount:=FOverloadScopes.Count;

      // add class and ancestors scopes
      aScope:=ClassScope;
      repeat
        PushOverloadScope(aScope);
        aScope:=aScope.AncestorScope;
      until aScope=nil;

      // first rename all overloads on this level
      RenameOverloads(ClassEl,ClassEl.Members);
      // then process nested procedures
      RenameSubOverloads(ClassEl.Members);

      while FOverloadScopes.Count>OldScopeCount do
        PopOverloadScope;
      end
    else if C=TPasConst then
      RenameOverload(El)
    else if C.InheritsFrom(TPasVariable) and (El.Parent.ClassType=TPasClassType) then
      RenameOverload(El);
    end;
  {$IFDEF VerbosePas2JS}
  writeln('TPas2JSResolver.RenameSubOverloads END');
  {$ENDIF}
end;

procedure TPas2JSResolver.PushOverloadScope(Scope: TPasIdentifierScope);
begin
  FOverloadScopes.Add(Scope);
end;

procedure TPas2JSResolver.PopOverloadScope;
begin
  FOverloadScopes.Delete(FOverloadScopes.Count-1);
end;

procedure TPas2JSResolver.AddType(El: TPasType);
begin
  inherited AddType(El);
  if (El.Name<>'') and (TopScope is TPasClassScope) then
    RaiseNotYetImplemented(20170608232534,El,'nested types');
end;

procedure TPas2JSResolver.ResolveImplAsm(El: TPasImplAsmStatement);
{type
  TAsmToken = (
    atNone,
    atWord,
    atDot,
    atRoundBracketOpen,
    atRoundBracketClose
    );

  procedure Next;
  begin

  end;}

var
  Lines: TStrings;
begin
  Lines:=El.Tokens;
  if Lines=nil then exit;
end;

procedure TPas2JSResolver.ResolveNameExpr(El: TPasExpr; const aName: string;
  Access: TResolvedRefAccess);

  procedure CheckTObjectFree(Ref: TResolvedReference);
  var
    Bin: TBinaryExpr;
    Left: TPasExpr;
    LeftResolved: TPasResolverResult;
    IdentEl: TPasElement;
  begin
    if not IsTObjectFreeMethod(El) then exit;
    if Ref.WithExprScope<>nil then
      begin
      // with expr do free
      if GetNewInstanceExpr(Ref.WithExprScope.Expr)<>nil then
        exit; // with TSomeClass.Free do Free  -> ok
      RaiseMsg(20170517092407,nFreeNeedsVar,sFreeNeedsVar,[],El);
      end;
    if (El.Parent.ClassType<>TBinaryExpr) then
      RaiseMsg(20170516151916,nFreeNeedsVar,sFreeNeedsVar,[],El);
    Bin:=TBinaryExpr(El.Parent);
    if (Bin.right<>El) or (Bin.OpCode<>eopSubIdent) then
      RaiseMsg(20170516151950,nFreeNeedsVar,sFreeNeedsVar,[],El);
    if rrfImplicitCallWithoutParams in Ref.Flags then
      // ".Free;" -> ok
    else if Bin.Parent is TParamsExpr then
      begin
      if Bin.Parent.Parent is TPasExpr then
        RaiseMsg(20170516161345,nFreeNeedsVar,sFreeNeedsVar,[],El);
      // ".Free();" -> ok
      end
    else if Bin.Parent is TPasImplElement then
      // ok
    else
      begin
      {$IFDEF VerbosePas2JS}
      writeln('TPas2JSResolver.ResolveNameExpr.CheckTObjectFree Bin.Parent=',GetObjName(Bin.Parent));
      {$ENDIF}
      RaiseMsg(20170516160347,nFreeNeedsVar,sFreeNeedsVar,[],El);
      end;

    Left:=Bin.left;
    ComputeElement(Left,LeftResolved,[]);
    if not (rrfReadable in LeftResolved.Flags) then
      RaiseMsg(20170516152300,nFreeNeedsVar,sFreeNeedsVar,[],El);
    if not (rrfWritable in LeftResolved.Flags) then
      RaiseMsg(20170516152307,nFreeNeedsVar,sFreeNeedsVar,[],El);
    IdentEl:=LeftResolved.IdentEl;
    if IdentEl=nil then
      RaiseMsg(20170516152401,nFreeNeedsVar,sFreeNeedsVar,[],El);
    if IdentEl.ClassType=TPasArgument then
      exit; // readable and writable argument -> ok
    if (IdentEl.ClassType=TPasVariable)
       or (IdentEl.ClassType=TPasConst) then
      exit; // readable and writable variable -> ok
    if IdentEl.ClassType=TPasResultElement then
      exit; // readable and writable function result -> ok
    RaiseMsg(20170516152455,nFreeNeedsVar,sFreeNeedsVar,[],El);
  end;

  procedure CheckResultEl(Ref: TResolvedReference);
  var
    Func: TPasFunction;
    CurEl: TPasElement;
    Lvl: Integer;
    ProcScope, CurProcScope: TPas2JSProcedureScope;
  begin
    // result refers to a function result
    // -> check if it is referring to a parent function result
    Lvl:=0;
    CurEl:=El;
    CurProcScope:=nil;
    while CurEl<>nil do
      begin
      if CurEl is TPasFunction then
        begin
        inc(Lvl);
        ProcScope:=CurEl.CustomData as TPas2JSProcedureScope;
        Func:=ProcScope.DeclarationProc as TPasFunction;
        if Func=nil then
          Func:=TPasFunction(CurEl);
        if Lvl=1 then
          begin
          // current function (where the statement of El is)
          if (Func.FuncType.ResultEl=Ref.Declaration) then
            exit; // accessing current function -> ok
          // accessing Result variable of higher function -> need rename
          if ProcScope.ResultVarName<>'' then
            exit; // is already renamed
          CurProcScope:=ProcScope;
          end;
        end;
      CurEl:=CurEl.Parent;
      end;
    if Lvl<2 then
      RaiseNotYetImplemented(20171003112020,El);
    // El refers to a higher Result variable
    // -> current function needs another name for its Result variable
    CurProcScope.ResultVarName:=ResolverResultVar+'$'+IntToStr(Lvl-1);
  end;

var
  Ref: TResolvedReference;
begin
  inherited ResolveNameExpr(El, aName, Access);
  if El.CustomData is TResolvedReference then
    begin
    Ref:=TResolvedReference(El.CustomData);
    if (CompareText(aName,'free')=0) then
      CheckTObjectFree(Ref)
    else if (Ref.Declaration is TPasResultElement) then
      CheckResultEl(Ref);
    end;
end;

procedure TPas2JSResolver.FinishModule(CurModule: TPasModule);
var
  ModuleClass: TClass;
begin
  inherited FinishModule(CurModule);
  FOverloadScopes:=TFPList.Create;
  try
    ModuleClass:=CurModule.ClassType;
    if ModuleClass=TPasModule then
      begin
      RenameOverloadsInSection(CurModule.InterfaceSection);
      // Note: ImplementationSection is child of InterfaceSection
      end
    else if ModuleClass=TPasProgram then
      RenameOverloadsInSection(TPasProgram(CurModule).ProgramSection)
    else if CurModule.ClassType=TPasLibrary then
      RenameOverloadsInSection(TPasLibrary(CurModule).LibrarySection)
    else
      RaiseNotYetImplemented(20170221000032,CurModule);
  finally
    FOverloadScopes.Free;
  end;
end;

procedure TPas2JSResolver.FinishEnumType(El: TPasEnumType);
var
  i: Integer;
  EnumValue: TPasEnumValue;
begin
  inherited FinishEnumType(El);
  for i:=0 to El.Values.Count-1 do
    begin
    EnumValue:=TPasEnumValue(El.Values[i]);
    if EnumValue.Value<>nil then
      RaiseNotYetImplemented(20180126202434,EnumValue,'enum const');
    end;
end;

procedure TPas2JSResolver.FinishSetType(El: TPasSetType);
var
  TypeEl: TPasType;
  C: TClass;
  RangeValue: TResEvalValue;
  bt: TResolverBaseType;
begin
  inherited FinishSetType(El);
  TypeEl:=ResolveAliasType(El.EnumType);
  C:=TypeEl.ClassType;
  if C=TPasEnumType then
    exit
  else if C=TPasUnresolvedSymbolRef then
    begin
    if TypeEl.CustomData is TResElDataBaseType then
      begin
      bt:=TResElDataBaseType(TypeEl.CustomData).BaseType;
      if bt in [btBoolean,btByte,btShortInt,btSmallInt,btWord,btChar,btWideChar] then
        exit; // ok
      {$IFDEF VerbosePas2JS}
      writeln('TPas2JSResolver.FinishSetType El='+GetObjName(El)+' TypeEl=',GetObjName(TypeEl),' ',bt);
      {$ENDIF}
      RaiseMsg(20171110150000,nNotSupportedX,sNotSupportedX,['set of '+TypeEl.Name],El);
      end;
    end
  else if C=TPasRangeType then
    begin
    RangeValue:=Eval(TPasRangeType(TypeEl).RangeExpr,[refConst]);
    try
      case RangeValue.Kind of
      revkRangeInt:
        begin
        if TResEvalRangeInt(RangeValue).RangeEnd-TResEvalRangeInt(RangeValue).RangeStart>$ffff then
          begin
          {$IFDEF VerbosePas2JS}
          writeln('TPas2JSResolver.FinishSetType El='+GetObjName(El)+' Range='+RangeValue.AsDebugString,' ',bt);
          {$ENDIF}
          RaiseMsg(20171110150159,nNotSupportedX,sNotSupportedX,['set of '+TypeEl.Name],El);
          end;
        exit;
        end;
      else
        begin
        {$IFDEF VerbosePas2JS}
        writeln('TPas2JSResolver.FinishSetType El='+GetObjName(El)+' Range='+RangeValue.AsDebugString);
        {$ENDIF}
        RaiseMsg(20171110145211,nNotSupportedX,sNotSupportedX,['set of '+TypeEl.Name],El);
        end;
      end;
    finally
      ReleaseEvalValue(RangeValue);
    end;
    end;
  {$IFDEF VerbosePas2JS}
  writeln('TPas2JSResolver.FinishSetType El='+GetObjName(El)+' TypeEl=',GetObjName(TypeEl));
  {$ENDIF}
  RaiseMsg(20170415182320,nNotSupportedX,sNotSupportedX,['set of '+TypeEl.Name],El);
end;

procedure TPas2JSResolver.FinishRecordType(El: TPasRecordType);
begin
  if (El.Variants<>nil) and (El.Variants.Count>0) then
    RaiseMsg(20180104205309,nXIsNotSupported,sXIsNotSupported,['variant record'],TPasElement(El.Variants[0]));
  inherited FinishRecordType(El);
end;

procedure TPas2JSResolver.FinishClassType(El: TPasClassType);
begin
  inherited FinishClassType(El);
  if El.IsExternal then
    begin
    if El.ExternalName='' then
      RaiseMsg(20170321151109,nMissingExternalName,sMissingExternalName,[],El);
    AddExternalPath(El.ExternalName,El);
    end;
end;

procedure TPas2JSResolver.FinishVariable(El: TPasVariable);
const
  ClassFieldModifiersAllowed = [vmClass,vmStatic,vmExternal,vmPublic];
  RecordVarModifiersAllowed = [];
  LocalVarModifiersAllowed = [];
  ImplementationVarModifiersAllowed = [vmExternal];
  SectionVarModifiersAllowed = [vmExternal,vmPublic];

  procedure RaiseVarModifierNotSupported(const Allowed: TVariableModifiers);
  var
    s: String;
    m: TVariableModifier;
  begin
    s:='';
    for m in TVariableModifiers do
      if (m in El.VarModifiers) and not (m in Allowed) then
        begin
        str(m,s);
        RaiseMsg(20170322134418,nInvalidVariableModifier,
          sInvalidVariableModifier,[VariableModifierNames[m]],El);
        end;
  end;

var
  ExtName: String;
  ParentC: TClass;
  AbsExpr: TPasExpr;
  ResolvedAbsol: TPasResolverResult;
  AbsIdent: TPasElement;
begin
  inherited FinishVariable(El);

  ParentC:=El.Parent.ClassType;

  if El.AbsoluteExpr<>nil then
    begin
    // check 'absolute' alias
    if vmExternal in El.VarModifiers then
      RaiseMsg(20171226105002,nXModifierMismatchY,sXModifierMismatchY,
        ['absolute','external'],El.AbsoluteExpr);
    AbsExpr:=El.AbsoluteExpr;
    ComputeElement(AbsExpr,ResolvedAbsol,[rcNoImplicitProc]);
    AbsIdent:=ResolvedAbsol.IdentEl;
    if ParentC=TProcedureBody then
      begin
      // local var
      if (AbsIdent.Parent=El.Parent)
          or ((AbsIdent is TPasArgument)
            and (AbsIdent.Parent.Parent=El.Parent.Parent)) then
        // ok
      else
        begin
        {$IFDEF VerbosePas2JS}
        writeln('TPas2JSResolver.FinishVariable absolute: Parent=',GetObjName(El.Parent),' AbsParent=',GetObjName(AbsIdent.Parent));
        {$ENDIF}
        RaiseMsg(20171226102424,nInvalidAbsoluteLocation,sInvalidAbsoluteLocation,[],El.AbsoluteExpr);
        end;
      end
    else
      begin
      RaiseMsg(20170728133340,nInvalidVariableModifier,
        sInvalidVariableModifier,['absolute'],El);
      end;
    end;

  if (ParentC=TPasClassType) then
    begin
    // class member
    RaiseVarModifierNotSupported(ClassFieldModifiersAllowed);
    if TPasClassType(El.Parent).IsExternal then
      begin
      // external class
      if El.Visibility=visPublished then
        // Note: an external class has no typeinfo
        RaiseMsg(20170413221516,nSymbolCannotBePublished,sSymbolCannotBePublished,
          [],El);
      if not (vmExternal in El.VarModifiers) then
        begin
        // make variable external
        if (El.ClassType=TPasVariable) or (El.ClassType=TPasConst) then
          begin
          if El.ExportName<>nil then
            RaiseMsg(20170322134321,nInvalidVariableModifier,
              sInvalidVariableModifier,['export name'],El.ExportName);
          El.ExportName:=TPrimitiveExpr.Create(El,pekString,''''+El.Name+'''');
          end;
        Include(El.VarModifiers,vmExternal);
        end;
      if (El.ClassType=TPasConst) and (TPasConst(El).Expr<>nil) then
        // external const with expression is not writable
        TPasConst(El).IsConst:=true;
      end;
    end
  else if ParentC=TPasRecordType then
    // record member
    RaiseVarModifierNotSupported(RecordVarModifiersAllowed)
  else if ParentC=TProcedureBody then
    // local var
    RaiseVarModifierNotSupported(LocalVarModifiersAllowed)
  else if ParentC=TImplementationSection then
    // implementation var
    RaiseVarModifierNotSupported(ImplementationVarModifiersAllowed)
  else if ParentC.InheritsFrom(TPasSection) then
    begin
    // interface/program/library var
    RaiseVarModifierNotSupported(SectionVarModifiersAllowed);
    end
  else
    begin
    {$IFDEF VerbosePas2JS}
    writeln('TPas2JSResolver.FinishVariable ',GetObjName(El),' Parent=',GetObjName(El.Parent));
    {$ENDIF}
    RaiseNotYetImplemented(20170324151259,El);
    end;

  if vmExternal in El.VarModifiers then
    begin
    // compute constant
    if El.LibraryName<>nil then
      RaiseMsg(20170227094227,nPasElementNotSupported,sPasElementNotSupported,
        ['library'],El.ExportName);
    if El.ExportName=nil then
      RaiseMsg(20170227100750,nMissingExternalName,sMissingExternalName,[],El);
    ExtName:=ComputeConstString(El.ExportName,true,true);
    if (El.Visibility=visPublished) and (ExtName<>El.Name) then
      RaiseMsg(20170407002940,nPublishedNameMustMatchExternal,
        sPublishedNameMustMatchExternal,[],El.ExportName);
    // add external name to FExternalNames
    if (El.Parent is TPasSection)
        or ((El.ClassType=TPasConst) and (El.Parent is TPasProcedure)) then
      AddExternalPath(ExtName,El.ExportName);
    end;
end;

procedure TPas2JSResolver.FinishProcedureType(El: TPasProcedureType);
var
  Proc: TPasProcedure;
  pm: TProcedureModifier;
  ExtName: String;
  C: TClass;
  AClass: TPasClassType;
  ClassScope: TPas2JSClassScope;
  ptm: TProcTypeModifier;
begin
  inherited FinishProcedureType(El);
  if El.Parent is TPasProcedure then
    begin
    Proc:=TPasProcedure(El.Parent);

    // calling convention
    if Proc.CallingConvention<>ccDefault then
      RaiseMsg(20170211214731,nPasElementNotSupported,sPasElementNotSupported,
        [cCallingConventions[Proc.CallingConvention]],Proc);

    for pm in TProcedureModifiers do
      if (pm in Proc.Modifiers)
          and (not (pm in [pmVirtual, pmAbstract, pmOverride,
                           pmOverload, pmReintroduce,
                           pmInline, pmAssembler, pmPublic,
                           pmExternal, pmForward])) then
        RaiseNotYetImplemented(20170208142159,El,'modifier '+ModifierNames[pm]);
    for ptm in TProcTypeModifiers do
      if (ptm in Proc.ProcType.Modifiers)
          and (not (ptm in [ptmOfObject,ptmVarargs])) then
        RaiseNotYetImplemented(20170411171454,El,'modifier '+ProcTypeModifiers[ptm]);

    // check pmPublic
    if [pmPublic,pmExternal]<=Proc.Modifiers then
      RaiseMsg(20170324150149,nInvalidXModifierY,
        sInvalidXModifierY,[Proc.ElementTypeName,'public, external'],Proc);
    if (Proc.PublicName<>nil) then
      RaiseMsg(20170324150417,nPasElementNotSupported,sPasElementNotSupported,
        ['public name'],Proc.PublicName);

    if (Proc.Parent.ClassType=TPasClassType) then
      begin
      // class member
      AClass:=TPasClassType(Proc.Parent);
      ClassScope:=AClass.CustomData as TPas2JSClassScope;

      if AClass.IsExternal then
        begin
        // external class -> make method external
        if not (pmExternal in Proc.Modifiers) then
          begin
          if Proc.LibrarySymbolName<>nil then
            RaiseMsg(20170322142158,nInvalidXModifierY,
              sInvalidXModifierY,[Proc.ElementTypeName,'symbol name'],Proc.LibrarySymbolName);
          Proc.Modifiers:=Proc.Modifiers+[pmExternal];
          Proc.LibrarySymbolName:=TPrimitiveExpr.Create(El,pekString,''''+Proc.Name+'''');
          end;

        if Proc.Visibility=visPublished then
          // Note: an external class has no typeinfo
          RaiseMsg(20170413221327,nSymbolCannotBePublished,sSymbolCannotBePublished,
            [],Proc);

        C:=Proc.ClassType;
        if (C=TPasProcedure) or (C=TPasFunction)
            or (C=TPasClassProcedure) or (C=TPasClassFunction) then
          // ok
        else if C=TPasConstructor then
          begin
          if Proc.IsVirtual then
            // constructor of external class can't be overriden -> forbid virtual
            RaiseMsg(20170323100447,nInvalidXModifierY,sInvalidXModifierY,
              [Proc.ElementTypeName,'virtual,external'],Proc);
          if CompareText(Proc.Name,'new')=0 then
            begin
            ExtName:=ComputeConstString(Proc.LibrarySymbolName,true,true);
            if ExtName<>Proc.Name then
              RaiseMsg(20170323083511,nVirtualMethodNameMustMatchExternal,
                sVirtualMethodNameMustMatchExternal,[],Proc.LibrarySymbolName);
            end
          else if El.Args.Count>0 then
            RaiseMsg(20170322164357,nNoArgumentsAllowedForExternalObjectConstructor,
              sNoArgumentsAllowedForExternalObjectConstructor,[],TPasArgument(El.Args[0]));
          if pmVirtual in Proc.Modifiers then
            RaiseMsg(20170322183141,nInvalidXModifierY,sInvalidXModifierY,
              [Proc.ElementTypeName,'virtual'],Proc.ProcType);
          end
        else
          RaiseMsg(20170322163210,nPasElementNotSupported,sPasElementNotSupported,
            [Proc.ElementTypeName],Proc);

        end
      else
        begin
        // Pascal class
        if (ClassScope.NewInstanceFunction=nil)
            and (ClassScope.AncestorScope<>nil)
            and (TPasClassType(ClassScope.AncestorScope.Element).IsExternal)
            and (Proc.ClassType=TPasClassFunction)
            and (Proc.Visibility in [visProtected,visPublic,visPublished])
            and (TPasClassFunction(Proc).FuncType.ResultEl.ResultType=AClass)
            and ([pmOverride,pmExternal]*Proc.Modifiers=[]) then
          begin
          // The first non private class function in a Pascal class descending
          // from an external class
          // -> this is the NewInstance function
          ClassScope.NewInstanceFunction:=TPasClassFunction(Proc);
          CheckNewInstanceFunction(ClassScope);
          end;
        end;
      end;

    if pmExternal in Proc.Modifiers then
      begin
      // external proc

      // external override -> unneeded information, probably a bug
      if Proc.IsOverride then
        RaiseMsg(20170321101715,nInvalidXModifierY,sInvalidXModifierY,
          [Proc.ElementTypeName,'override,external'],Proc);

      if Proc.LibraryExpr<>nil then
        RaiseMsg(20170211220712,nPasElementNotSupported,sPasElementNotSupported,
          ['external library name'],Proc.LibraryExpr);
      if Proc.LibrarySymbolName=nil then
        RaiseMsg(20170227095454,nMissingExternalName,sMissingExternalName,
          ['missing external name'],Proc);

      for pm in [pmAssembler,pmForward,pmNoReturn,pmInline] do
        if pm in Proc.Modifiers then
          RaiseMsg(20170323100842,nInvalidXModifierY,sInvalidXModifierY,
            [Proc.ElementTypeName,ModifierNames[pm]],Proc);

      // compute external name
      ExtName:=ComputeConstString(Proc.LibrarySymbolName,true,true);

      // a virtual must have the external name, so that override works
      if Proc.IsVirtual and (Proc.Name<>ExtName) then
        RaiseMsg(20170321090049,nVirtualMethodNameMustMatchExternal,
          sVirtualMethodNameMustMatchExternal,[],Proc.LibrarySymbolName);

      // a published must have the external name, so that streaming works
      if (Proc.Visibility=visPublished) then
        begin
        if (Proc.Name<>ExtName) then
          RaiseMsg(20170407002940,nPublishedNameMustMatchExternal,
            sPublishedNameMustMatchExternal,[],Proc.LibrarySymbolName);
        if ExtName=ExtClassBracketAccessor then
          RaiseMsg(20170409211805,nSymbolCannotBePublished,
            sSymbolCannotBePublished,[],Proc.LibrarySymbolName);
        end;

      if Proc.Parent is TPasSection then
        AddExternalPath(ExtName,Proc.LibrarySymbolName);

      exit;
      end;
    end;
end;

procedure TPas2JSResolver.FinishPropertyOfClass(PropEl: TPasProperty);
var
  Getter, Setter: TPasElement;
  GetterIsBracketAccessor, SetterIsBracketAccessor: Boolean;
  Arg: TPasArgument;
  ArgResolved: TPasResolverResult;
  ParentC: TClass;
  IndexExpr: TPasExpr;
  PropArgs: TFPList;
begin
  inherited FinishPropertyOfClass(PropEl);

  ParentC:=PropEl.Parent.ClassType;
  if (ParentC=TPasClassType) then
    begin
    // class member
    if TPasClassType(PropEl.Parent).IsExternal then
      begin
      // external class
      if PropEl.Visibility=visPublished then
        // Note: an external class has no typeinfo
        RaiseMsg(20170413221703,nSymbolCannotBePublished,sSymbolCannotBePublished,
          [],PropEl);
      end;
    end;

  Getter:=GetPasPropertyGetter(PropEl);
  GetterIsBracketAccessor:=IsExternalBracketAccessor(Getter);
  Setter:=GetPasPropertySetter(PropEl);
  SetterIsBracketAccessor:=IsExternalBracketAccessor(Setter);
  IndexExpr:=GetPasPropertyIndex(PropEl);
  PropArgs:=GetPasPropertyArgs(PropEl);
  if GetterIsBracketAccessor then
    begin
    if (PropArgs.Count<>1) or (IndexExpr<>nil) then
      RaiseMsg(20170403001743,nBracketAccessorOfExternalClassMustHaveOneParameter,
        sBracketAccessorOfExternalClassMustHaveOneParameter,
        [],PropEl);
    end;
  if SetterIsBracketAccessor then
    begin
    if (PropArgs.Count<>1) or (IndexExpr<>nil) then
      RaiseMsg(20170403001806,nBracketAccessorOfExternalClassMustHaveOneParameter,
        sBracketAccessorOfExternalClassMustHaveOneParameter,
        [],PropEl);
    end;
  if GetterIsBracketAccessor or SetterIsBracketAccessor then
    begin
    Arg:=TPasArgument(PropArgs[0]);
    if not (Arg.Access in [argDefault,argConst]) then
      RaiseMsg(20170403090225,nXExpectedButYFound,sXExpectedButYFound,
        ['default or "const"',AccessNames[Arg.Access]],PropEl);
    ComputeElement(Arg,ArgResolved,[rcType],Arg);
    if not (ArgResolved.BaseType in (btAllJSInteger+btAllJSStringAndChars+btAllJSBooleans+btAllJSFloats)) then
      RaiseMsg(20170403090628,nIncompatibleTypesGotExpected,
        sIncompatibleTypesGotExpected,
        [GetResolverResultDescription(ArgResolved,true),'string'],Arg);
    end;
end;

procedure TPas2JSResolver.CheckConditionExpr(El: TPasExpr;
  const ResolvedEl: TPasResolverResult);
begin
  if (ResolvedEl.BaseType=btCustom) and (IsJSBaseType(ResolvedEl,pbtJSValue)) then
    exit;
  inherited CheckConditionExpr(El, ResolvedEl);
end;

procedure TPas2JSResolver.CheckNewInstanceFunction(ClassScope: TPas2JSClassScope
  );
var
  Proc: TPasClassFunction;
  Args: TFPList;
  Arg: TPasArgument;
  ResolvedArg: TPasResolverResult;
begin
  Proc:=ClassScope.NewInstanceFunction;
  // proc modifiers override and external were already checked
  // visibility was already checked
  // function result type was already checked
  if not Proc.IsVirtual then
    RaiseMsg(20170324231040,nNewInstanceFunctionMustBeVirtual,
      sNewInstanceFunctionMustBeVirtual,[],Proc);
  Args:=Proc.ProcType.Args;
  if Args.Count<2 then
    RaiseMsg(20170324232247,nNewInstanceFunctionMustHaveTwoParameters,
      sNewInstanceFunctionMustHaveTwoParameters,[],Proc.ProcType);

  // first param must be a string
  Arg:=TPasArgument(Args[0]);
  if Arg.Access<>argDefault then
    RaiseMsg(20170324232655,nIncompatibleTypeArgNo,sIncompatibleTypeArgNo,
      ['1',AccessNames[Arg.Access],'default (none)'],Arg);
  if Arg.ArgType=nil then
    RaiseMsg(20170324233201,nIncompatibleTypeArgNo,sIncompatibleTypeArgNo,
      ['1','untyped','String'],Arg);
  ComputeElement(Arg.ArgType,ResolvedArg,[rcType]);
  if ResolvedArg.BaseType<>btString then
    RaiseMsg(20170324233348,nIncompatibleTypeArgNo,sIncompatibleTypeArgNo,
      ['1',GetResolverResultDescription(ResolvedArg),'String'],Arg);

  // second param must be const untyped
  Arg:=TPasArgument(Args[1]);
  if Arg.Access<>argConst then
    RaiseMsg(20170324233457,nIncompatibleTypeArgNo,sIncompatibleTypeArgNo,
      ['2',AccessNames[Arg.Access],'const'],Arg);
  if Arg.ArgType<>nil then
    RaiseMsg(20170324233508,nIncompatibleTypeArgNo,sIncompatibleTypeArgNo,
      ['2','type','untyped'],Arg);
end;

function TPas2JSResolver.AddExternalName(const aName: string; El: TPasElement
  ): TPasIdentifier;
var
  Item: TPasIdentifier;
begin
  //writeln('TPas2JSResolver.AddExternalIdentifier Name="',aName,'" El=',GetObjName(El));
  Item:=TPasIdentifier.Create;
  Item.Identifier:=aName;
  Item.Element:=El;

  InternalAdd(Item);
  //writeln('TPas2JSResolver.AddExternalIdentifier END');
  Result:=Item;
end;

function TPas2JSResolver.FindExternalName(const aName: String
  ): TPasIdentifier;
begin
  Result:=TPasIdentifier(FExternalNames.Find(aName));
  {$IFDEF VerbosePasResolver}
  {AllowWriteln}
  if (Result<>nil) and (Result.Owner<>Self) then
    begin
    writeln('TPas2JSResolver.FindExternalName Result.Owner<>Self Owner='+GetObjName(Result.Owner));
    raise Exception.Create('20170322235814');
    end;
  {AllowWriteln-}
  {$ENDIF}
end;

procedure TPas2JSResolver.AddExternalPath(aName: string; El: TPasElement);
// add aName and the first identifier of aName
var
  p: PChar;
  l: integer;
begin
  aName:=Trim(aName);
  if aName='' then exit;
  AddExternalName(aName,El);
  p:=PChar(aName);
  while p^ in ['a'..'z','A'..'Z','0'..'9','_','$'] do inc(p);
  l:=p-PChar(aName);
  if l=length(aName) then exit;
  AddExternalName(LeftStr(aName,l),El);
end;

procedure TPas2JSResolver.ClearElementData;
var
  Data, Next: TPas2JsElementData;
begin
  Data:=FFirstElementData;
  while Data<>nil do
    begin
    Next:=Data.Next;
    Data.Free;
    Data:=Next;
    end;
  FFirstElementData:=nil;
  FLastElementData:=nil;

  FExternalNames.ForEachCall(@OnClearHashItem,nil);
  FExternalNames.Clear;
end;

function TPas2JSResolver.AddJSBaseType(const aName: string; Typ: TPas2jsBaseType
  ): TResElDataPas2JSBaseType;
var
  El: TPasUnresolvedSymbolRef;
begin
  El:=AddCustomBaseType(aName,TResElDataPas2JSBaseType);
  if Typ<>pbtNone then
    FJSBaseTypes[Typ]:=El;
  Result:=TResElDataPas2JSBaseType(El.CustomData);
  Result.JSBaseType:=Typ;
end;

function TPas2JSResolver.CheckAssignCompatibilityCustom(const LHS,
  RHS: TPasResolverResult; ErrorEl: TPasElement; RaiseOnIncompatible: boolean;
  var Handled: boolean): integer;
var
  LeftBaseType: TPas2jsBaseType;
  LArray: TPasArrayType;
  ElTypeResolved: TPasResolverResult;
begin
  Result:=cIncompatible;
  if LHS.BaseType=btCustom then
    begin
    if not (LHS.TypeEl is TPasUnresolvedSymbolRef) then
      begin
      {$IFDEF VerbosePas2JS}
      writeln('TPas2JSResolver.CheckAssignCompatibilityCustomBaseType LHS=',GetResolverResultDbg(LHS));
      {$ENDIF}
      RaiseInternalError(20170325114554);
      end;
    if not (LHS.TypeEl.CustomData is TResElDataPas2JSBaseType) then
      exit;
    Handled:=true;
    LeftBaseType:=TResElDataPas2JSBaseType(LHS.TypeEl.CustomData).JSBaseType;
    if LeftBaseType=pbtJSValue then
      begin
      // assign to a JSValue
      if rrfReadable in RHS.Flags then
        begin
        // RHS is a value
        if (RHS.BaseType in btAllJSValueSrcTypes) then
          Result:=cJSValueConversion // type cast to JSValue
        else if RHS.BaseType=btCustom then
          begin
          if IsJSBaseType(RHS,pbtJSValue) then
            Result:=cExact;
          end
        else if RHS.BaseType=btContext then
          Result:=cJSValueConversion;
        end
      else if RHS.BaseType=btContext then
        begin
        // RHS is not a value
        if RHS.IdentEl<>nil then
          begin
          if RHS.IdentEl.ClassType=TPasClassType then
            Result:=cJSValueConversion; // RHS is a class type
          end;
        end;
      end;
    end
  else if (LHS.BaseType=btContext) and (LHS.TypeEl.ClassType=TPasArrayType)
      and (rrfReadable in RHS.Flags) then
    begin
    LArray:=TPasArrayType(LHS.TypeEl);
    if length(LArray.Ranges)>0 then
      exit;
    if (RHS.BaseType<>btContext) or (RHS.TypeEl.ClassType<>TPasArrayType) then
      exit;
    ComputeElement(LArray.ElType,ElTypeResolved,[rcType]);
    if IsJSBaseType(ElTypeResolved,pbtJSValue) then
      begin
      // array of jsvalue := array
      Handled:=true;
      Result:=cJSValueConversion;
      end;
    end;

  if RaiseOnIncompatible then ;
  if ErrorEl=nil then ;
end;

function TPas2JSResolver.CheckTypeCastClassInstanceToClass(const FromClassRes,
  ToClassRes: TPasResolverResult; ErrorEl: TPasElement): integer;
var
  ToClass: TPasClassType;
  ClassScope: TPasClassScope;
begin
  if FromClassRes.BaseType=btNil then exit(cExact);
  ToClass:=(ToClassRes.TypeEl as TPasClassType);
  ClassScope:=ToClass.CustomData as TPasClassScope;
  if ClassScope.AncestorScope=nil then
    // type cast to root class
    Result:=cTypeConversion+1
  else
    Result:=cIncompatible;
  if ErrorEl=nil then ;
end;

function TPas2JSResolver.CheckEqualCompatibilityCustomType(const LHS,
  RHS: TPasResolverResult; ErrorEl: TPasElement; RaiseOnIncompatible: boolean
  ): integer;
var
  LeftBaseType: TPas2jsBaseType;
begin
  Result:=cIncompatible;
  if LHS.BaseType=btCustom then
    begin
    if not (LHS.TypeEl is TPasUnresolvedSymbolRef) then
      begin
      {$IFDEF VerbosePas2JS}
      writeln('TPas2JSResolver.CheckEqualCompatibilityCustomType LHS=',GetResolverResultDbg(LHS));
      {$ENDIF}
      RaiseInternalError(20170330005841);
      end;
    if not (LHS.TypeEl.CustomData is TResElDataPas2JSBaseType) then
      exit;
    LeftBaseType:=TResElDataPas2JSBaseType(LHS.TypeEl.CustomData).JSBaseType;
    if LeftBaseType=pbtJSValue then
      begin
      if (rrfReadable in LHS.Flags) then
        begin
        if (rrfReadable in RHS.Flags) then
          begin
          if RHS.BaseType in btAllJSValueSrcTypes then
            Result:=cJSValueConversion
          else if RHS.BaseType=btCustom then
            begin
            if IsJSBaseType(RHS,pbtJSValue) then
              Result:=cExact;
            end
          else if RHS.BaseType=btContext then
            Result:=cJSValueConversion;
          end
        else if RHS.BaseType=btContext then
          begin
          // right side is not a value
          if RHS.IdentEl<>nil then
            begin
            if RHS.IdentEl.ClassType=TPasClassType then
              Result:=cJSValueConversion; // RHS is a class
            end;
          end;
        end;
      end;
    end
  else if RHS.BaseType=btCustom then
    exit(CheckEqualCompatibilityCustomType(RHS,LHS,ErrorEl,RaiseOnIncompatible))
  else
    RaiseInternalError(20170330005725);
end;

procedure TPas2JSResolver.ComputeBinaryExprRes(Bin: TBinaryExpr; out
  ResolvedEl: TPasResolverResult; Flags: TPasResolverComputeFlags;
  var LeftResolved, RightResolved: TPasResolverResult);

  procedure SetBaseType(BaseType: TResolverBaseType);
  begin
    SetResolverValueExpr(ResolvedEl,BaseType,BaseTypes[BaseType],Bin,[rrfReadable]);
  end;

var
  RightTypeEl: TPasType;
begin
  if (LeftResolved.BaseType=btCustom)
      or (RightResolved.BaseType=btCustom) then
    case Bin.OpCode of
    eopIs:
      if IsJSBaseType(LeftResolved,pbtJSValue,true) then
        begin
        // aJSValue is x
        if (RightResolved.IdentEl is TPasType)
            and (ResolveAliasType(TPasType(RightResolved.IdentEl)) is TPasClassType) then
          begin
          // e.g. if aJSValue is TObject then ;
          SetBaseType(btBoolean);
          exit;
          end;
        RightTypeEl:=ResolveAliasType(RightResolved.TypeEl);
        if (RightTypeEl is TPasClassOfType) then
          begin
          // e.g. if aJSValue is TClass then ;
          // or  if aJSValue is ImageClass then ;
          SetBaseType(btBoolean);
          exit;
          end;
        end;
    end;

  inherited ComputeBinaryExprRes(Bin, ResolvedEl, Flags, LeftResolved,
    RightResolved);
end;

procedure TPas2JSResolver.BI_TypeInfo_OnGetCallResult(
  Proc: TResElDataBuiltInProc; Params: TParamsExpr; out
  ResolvedEl: TPasResolverResult);
// if an external type with the right name and external name is in scope return
// that, otherwise btPointer
var
  Param: TPasExpr;
  ParamResolved: TPasResolverResult;
  C: TClass;
  TIName: String;
  FindData: TPRFindData;
  Abort: boolean;
  bt: TResolverBaseType;
  jbt: TPas2jsBaseType;
  TypeEl: TPasType;
  FoundClass: TPasClassType;
begin
  Param:=Params.Params[0];
  ComputeElement(Param,ParamResolved,[rcNoImplicitProc]);
  if ParamResolved.TypeEl=nil then
    RaiseInternalError(20170413090726);
  if (ParamResolved.BaseType=btProc) and (ParamResolved.IdentEl is TPasFunction) then
    begin
    // typeinfo of function result -> resolve once
    TypeEl:=TPasFunction(ParamResolved.IdentEl).FuncType.ResultEl.ResultType;
    ComputeElement(TypeEl,ParamResolved,[rcNoImplicitProc]);
    Include(ParamResolved.Flags,rrfReadable);
    if ParamResolved.TypeEl=nil then
      RaiseInternalError(20170421124923);
    end;

  TypeEl:=ResolveAliasType(ParamResolved.TypeEl);
  C:=TypeEl.ClassType;
  TIName:='';
  //writeln('TPas2JSResolver.BI_TypeInfo_OnGetCallResult TypeEl=',GetObjName(TypeEl));

  if C=TPasUnresolvedSymbolRef then
    begin
    if TypeEl.CustomData is TResElDataPas2JSBaseType then
      begin
      jbt:=TResElDataPas2JSBaseType(TypeEl.CustomData).JSBaseType;
      if jbt=pbtJSValue then
        TIName:=Pas2JSBuiltInNames[pbitnTI];
      end
    else if TypeEl.CustomData is TResElDataBaseType then
      begin
      bt:=TResElDataBaseType(TypeEl.CustomData).BaseType;
      if bt in btAllJSInteger then
        TIName:=Pas2JSBuiltInNames[pbitnTIInteger]
      else if bt in [btString,btChar,btDouble,btBoolean] then
        TIName:=Pas2JSBuiltInNames[pbitnTI]
      else if bt=btPointer then
        TIName:=Pas2JSBuiltInNames[pbitnTIPointer];
      end;
    end
  else if ParamResolved.BaseType=btContext then
    begin
    if C=TPasEnumType then
      TIName:=Pas2JSBuiltInNames[pbitnTIEnum]
    else if C=TPasSetType then
      TIName:=Pas2JSBuiltInNames[pbitnTISet]
    else if C.InheritsFrom(TPasProcedureType) then
      begin
      if TPasProcedureType(TypeEl).IsReferenceTo then
        TIName:=Pas2JSBuiltInNames[pbitnTIRefToProcVar]
      else if TPasProcedureType(TypeEl).IsOfObject then
        TIName:=Pas2JSBuiltInNames[pbitnTIMethodVar]
      else
        TIName:=Pas2JSBuiltInNames[pbitnTIProcVar];
      end
    else if C=TPasRecordType then
      TIName:=Pas2JSBuiltInNames[pbitnTIRecord]
    else if C=TPasClassType then
      TIName:=Pas2JSBuiltInNames[pbitnTIClass]
    else if C=TPasClassOfType then
      begin
      if rrfReadable in ParamResolved.Flags then
        TIName:=Pas2JSBuiltInNames[pbitnTIClass]
      else
        TIName:=Pas2JSBuiltInNames[pbitnTIClassRef];
      end
    else if C=TPasArrayType then
      begin
      if length(TPasArrayType(TypeEl).Ranges)>0 then
        TIName:=Pas2JSBuiltInNames[pbitnTIStaticArray]
      else
        TIName:=Pas2JSBuiltInNames[pbitnTIDynArray];
      end
    else if C=TPasPointerType then
      TIName:=Pas2JSBuiltInNames[pbitnTIPointer]
    end
  else if ParamResolved.BaseType=btSet then
    begin
    if ParamResolved.IdentEl is TPasSetType then
      TIName:=Pas2JSBuiltInNames[pbitnTISet];
    end
  else if ParamResolved.BaseType=btRange then
    begin
    ConvertRangeToElement(ParamResolved);
    if ParamResolved.BaseType in btAllJSInteger then
      TIName:=Pas2JSBuiltInNames[pbitnTIInteger]
    else if ParamResolved.BaseType=btContext then
      begin
      TypeEl:=ParamResolved.TypeEl;
      C:=TypeEl.ClassType;
      if C=TPasEnumType then
        TIName:=Pas2JSBuiltInNames[pbitnTIEnum];
      end;
    end;
  if TIName='' then
    begin
    {$IFDEF VerbosePas2JS}
    writeln('TPas2JSResolver.BI_TypeInfo_OnGetCallResult ',GetResolverResultDbg(ParamResolved));
    {$ENDIF}
    RaiseNotYetImplemented(20170413091852,Param);
    end;

  // search for TIName
  FindData:=Default(TPRFindData);
  FindData.ErrorPosEl:=Params;
  Abort:=false;
  IterateElements(TIName,@OnFindFirstElement,@FindData,Abort);
  {$IFDEF VerbosePas2JS}
  writeln('TPas2JSResolver.BI_TypeInfo_OnGetCallResult TIName="',TIName,'" FindData.Found="',GetObjName(FindData.Found),'"');
  {$ENDIF}
  if (FindData.Found<>nil) and (FindData.Found.ClassType=TPasClassType) then
    begin
    FoundClass:=TPasClassType(FindData.Found);
    if FoundClass.IsExternal
        and (FoundClass.ExternalName=Pas2JSBuiltInNames[pbivnRTL]+'.'+TIName) then
      begin
      // use external class definition
      {$IFDEF VerbosePas2JS}
      writeln('TPas2JSResolver.BI_TypeInfo_OnGetCallResult FindData.Found="',FindData.Found.FullName,'"');
      {$ENDIF}
      SetResolverTypeExpr(ResolvedEl,btContext,TPasClassType(FindData.Found),[rrfReadable]);
      exit;
      end;
    end;

  // default: btPointer
  SetResolverTypeExpr(ResolvedEl,btPointer,BaseTypes[btPointer],[rrfReadable]);

  if Proc=nil then ;
end;

constructor TPas2JSResolver.Create;
var
  bt: TPas2jsBaseType;
begin
  inherited;
  ExprEvaluator.DefaultStringCodePage:=CP_UTF8;
  FExternalNames:=TFPHashList.Create;
  StoreSrcColumns:=true;
  Options:=Options+DefaultPasResolverOptions;
  ScopeClass_Class:=TPas2JSClassScope;
  ScopeClass_InitialFinalization:=TPas2JSInitialFinalizationScope;
  ScopeClass_Module:=TPas2JSModuleScope;
  ScopeClass_Procedure:=TPas2JSProcedureScope;
  ScopeClass_WithExpr:=TPas2JSWithExprScope;
  for bt in [pbtJSValue] do
    AddJSBaseType(Pas2jsBaseTypeNames[bt],bt);
  AnonymousElTypePostfix:=Pas2JSBuiltInNames[pbitnAnonymousPostfix];
  BaseTypeChar:=btWideChar;
  BaseTypeString:=btUnicodeString;
  BaseTypeLength:=btIntDouble;
end;

destructor TPas2JSResolver.Destroy;
begin
  ClearElementData;
  FreeAndNil(FExternalNames);
  inherited Destroy;
end;

function TPas2JSResolver.IsJSBaseType(TypeEl: TPasType; Typ: TPas2jsBaseType
  ): boolean;
begin
  Result:=(TypeEl is TPasUnresolvedSymbolRef)
    and (CompareText(TypeEl.Name,Pas2jsBaseTypeNames[Typ])=0)
    and (TypeEl.CustomData is TResElDataPas2JSBaseType);
end;

function TPas2JSResolver.IsJSBaseType(const TypeResolved: TPasResolverResult;
  Typ: TPas2jsBaseType; HasValue: boolean): boolean;
begin
  if (TypeResolved.BaseType<>btCustom) or not IsJSBaseType(TypeResolved.TypeEl,Typ) then
    exit(false);
  if HasValue and not (rrfReadable in TypeResolved.Flags) then
    exit(false);
  Result:=true;
end;

procedure TPas2JSResolver.AddObjFPCBuiltInIdentifiers(
  const TheBaseTypes: TResolveBaseTypes;
  const TheBaseProcs: TResolverBuiltInProcs);
var
  InvalidTypes: TResolveBaseTypes;
  bt: TResolverBaseType;
  InvalidProcs: TResolverBuiltInProcs;
  bf: TResolverBuiltInProc;
begin
  InvalidTypes:=TheBaseTypes-btAllJSBaseTypes;
  if InvalidTypes<>[] then
    for bt in InvalidTypes do
      RaiseInternalError(20170409180202,BaseTypeNames[bt]);
  InvalidProcs:=TheBaseProcs-bfAllJSBaseProcs;
  if InvalidProcs<>[] then
    for bf in InvalidProcs do
      RaiseInternalError(20170409180246,ResolverBuiltInProcNames[bf]);
  inherited AddObjFPCBuiltInIdentifiers(TheBaseTypes-[btUIntDouble,btIntDouble],TheBaseProcs);
  if btUIntDouble in TheBaseTypes then
    AddBaseType(Pas2JSBuiltInNames[pbitnUIntDouble],btUIntDouble);
  if btIntDouble in TheBaseTypes then
    AddBaseType(Pas2JSBuiltInNames[pbitnIntDouble],btIntDouble);
end;

function TPas2JSResolver.CheckTypeCastRes(const FromResolved,
  ToResolved: TPasResolverResult; ErrorEl: TPasElement; RaiseOnError: boolean
  ): integer;
var
  JSBaseType: TPas2jsBaseType;
  C: TClass;
  ToClass: TPasClassType;
begin
  Result:=cIncompatible;
  {$IFDEF VerbosePas2JS}
  writeln('TPas2JSResolver.CheckTypeCastCustomBaseType To=',GetResolverResultDbg(ToResolved),' From=',GetResolverResultDbg(FromResolved));
  {$ENDIF}
  if rrfReadable in FromResolved.Flags then
    begin
    if (ToResolved.BaseType=btCustom) then
      begin
      if not (ToResolved.TypeEl is TPasUnresolvedSymbolRef) then
        RaiseInternalError(20170325142826);
      if (ToResolved.TypeEl.CustomData is TResElDataPas2JSBaseType) then
        begin
        // type cast to pas2js type, e.g. JSValue(V)
        JSBaseType:=TResElDataPas2JSBaseType(ToResolved.TypeEl.CustomData).JSBaseType;
        if JSBaseType=pbtJSValue then
          begin
          if rrfReadable in FromResolved.Flags then
            begin
            if (FromResolved.BaseType in btAllJSValueSrcTypes) then
              Result:=cExact+1 // type cast to JSValue
            else if FromResolved.BaseType=btCustom then
              begin
              if IsJSBaseType(FromResolved,pbtJSValue) then
                Result:=cExact;
              end
            else if FromResolved.BaseType=btContext then
              Result:=cExact+1;
            end;
          end;
        exit;
        end;
      end
    else if FromResolved.BaseType=btCustom then
      begin
      if not (FromResolved.TypeEl is TPasUnresolvedSymbolRef) then
        RaiseInternalError(20170325143016);
      if (FromResolved.TypeEl.CustomData is TResElDataPas2JSBaseType) then
        begin
        // type cast a pas2js value, e.g. T(jsvalue)
        if not (rrfReadable in FromResolved.Flags) then
          exit;
        JSBaseType:=TResElDataPas2JSBaseType(FromResolved.TypeEl.CustomData).JSBaseType;
        if JSBaseType=pbtJSValue then
          begin
          if (ToResolved.BaseType in btAllJSValueTypeCastTo) then
            Result:=cExact+1 // type cast JSValue to simple base type
          else if ToResolved.BaseType=btContext then
            begin
            // typecast JSValue to user type
            Result:=cExact+1;
            end;
          end;
        exit;
        end;
      end
    else if ToResolved.BaseType=btContext then
      begin
      C:=ToResolved.TypeEl.ClassType;
      if C=TPasClassType then
        begin
        ToClass:=TPasClassType(ToResolved.TypeEl);
        if ToClass.IsExternal then
          begin
          if IsExternalClassName(ToClass,'String')
              and (FromResolved.BaseType in btAllJSStringAndChars) then
            exit(cExact);
          if IsExternalClassName(ToClass,'Array')
              and (FromResolved.BaseType=btContext) then
            exit(cExact);
          end;
        end
      else if C=TPasArrayType then
        begin
        if (FromResolved.BaseType=btContext)
            and (FromResolved.TypeEl.ClassType=TPasClassType)
            and TPasClassType(FromResolved.TypeEl).IsExternal
            and IsExternalClassName(TPasClassType(FromResolved.TypeEl),'Array') then
          begin
            // type cast external Array to an array
            exit(cExact+1);
          end;
        end;
      end;
    end;
  Result:=inherited CheckTypeCastRes(FromResolved,ToResolved,ErrorEl,RaiseOnError);
end;

function TPas2JSResolver.FindLocalBuiltInSymbol(El: TPasElement): TPasElement;
begin
  Result:=inherited FindLocalBuiltInSymbol(El);
  if Result<>nil then exit;
  if El.CustomData is TResElDataPas2JSBaseType then
    Result:=JSBaseTypes[TResElDataPas2JSBaseType(El.CustomData).JSBaseType];
end;

function TPas2JSResolver.ExtractPasStringLiteral(El: TPasElement;
  const S: String): TJSString;
{ Extracts the value from a Pascal string literal

  S is a Pascal string literal e.g. 'Line'#10
    ''  empty string
    '''' => "'"
    #decimal
    #$hex
    ^l  l is a letter a-z
}
var
  p, StartP: PChar;
  c: Char;
  i: Integer;
begin
  Result:='';
  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.ExtractPasStringLiteral S="',S,'" ',RawStrToCaption(S,100),' ',length(S));
  {$ENDIF}
  if S='' then
    RaiseInternalError(20170207154543);
  p:=PChar(S);
  repeat
    case p^ of
    #0: break;
    '''':
      begin
      inc(p);
      StartP:=p;
      repeat
        c:=p^;
        case c of
        #0:
          RaiseInternalError(20170207155120);
        '''':
          begin
          if p>StartP then
            Result:=Result+TJSString(UTF8Decode(copy(S,StartP-PChar(S)+1,p-StartP)));
          inc(p);
          StartP:=p;
          if p^<>'''' then
            break;
          Result:=Result+'''';
          inc(p);
          StartP:=p;
          end;
        else
          inc(p);
        end;
      until false;
      if p>StartP then
        Result:=Result+TJSString(UTF8Decode(copy(S,StartP-PChar(S)+1,p-StartP)));
      end;
    '#':
      begin
      inc(p);
      if p^='$' then
        begin
        // #$hexnumber
        inc(p);
        StartP:=p;
        i:=0;
        repeat
          c:=p^;
          case c of
          #0: break;
          '0'..'9': i:=i*16+ord(c)-ord('0');
          'a'..'f': i:=i*16+ord(c)-ord('a')+10;
          'A'..'F': i:=i*16+ord(c)-ord('A')+10;
          else break;
          end;
          if i>$10ffff then
            RaiseNotYetImplemented(20170207164657,El,'maximum codepoint is $10ffff');
          inc(p);
        until false;
        if p=StartP then
          RaiseInternalError(20170207164956);
        Result:=Result+CodePointToJSString(i);
        end
      else
        begin
        // #decimalnumber
        StartP:=p;
        i:=0;
        repeat
          c:=p^;
          case c of
          #0: break;
          '0'..'9': i:=i*10+ord(c)-ord('0');
          else break;
          end;
          if i>$10ffff then
            RaiseNotYetImplemented(20170207171140,El,'maximum codepoint is $10ffff');
          inc(p);
        until false;
        if p=StartP then
          RaiseInternalError(20170207171148);
        Result:=Result+CodePointToJSString(i);
        end;
      end;
    '^':
      begin
      // ^A is #1
      inc(p);
      c:=p^;
      case c of
      'a'..'z': Result:=Result+TJSChar(ord(c)-ord('a')+1);
      'A'..'Z': Result:=Result+TJSChar(ord(c)-ord('A')+1);
      else RaiseInternalError(20170207160412);
      end;
      inc(p);
      end;
    else
      RaiseNotYetImplemented(20170207154653,El,'ord='+IntToStr(ord(p^)));
    end;
  until false;
  {$IFDEF VerbosePas2JS}
  {AllowWriteln}
  writeln('TPasToJSConverter.ExtractPasStringLiteral Result="',Result,'"');
  //for i:=1 to length(Result) do
  //  writeln('  Result[',i,']',HexStr(ord(Result[i]),4));
  {AllowWriteln-}
  {$ENDIF}
end;

function TPas2JSResolver.ResolverToJSValue(Value: TResEvalValue;
  ErrorEl: TPasElement): TJSValue;
begin
  Result:=nil;
  if Value=nil then exit;
  case Value.Kind of
  revkBool: Result:=TJSValue.Create(TResEvalBool(Value).B);
  revkInt: Result:=TJSValue.Create(TJSNumber(TResEvalInt(Value).Int));
  revkUInt: Result:=TJSValue.Create(TJSNumber(TResEvalUInt(Value).UInt));
  revkFloat: Result:=TJSValue.Create(TJSNumber(TResEvalFloat(Value).FloatValue));
  revkString: Result:=TJSValue.Create(TJSString(
    ExprEvaluator.GetUnicodeStr(TResEvalString(Value).S,ErrorEl)));
  revkUnicodeString: Result:=TJSValue.Create(TJSString(TResEvalUTF16(Value).S));
  else
    {$IFDEF VerbosePas2JS}
    writeln('TPas2JSResolver.ResolverToJSValue ',Value.AsDebugString);
    {$ENDIF}
    RaiseNotYetImplemented(20170914092413,ErrorEl,'');
  end;
end;

function TPas2JSResolver.ComputeConstString(Expr: TPasExpr; StoreCustomData,
  NotEmpty: boolean): String;
var
  Value: TResEvalValue;
begin
  Result:='';
  if Expr=nil then
    RaiseInternalError(20170215123600);
  Value:=Eval(Expr,[refAutoConst],StoreCustomData);
  try
    case Value.Kind of
    revkString: Result:=ExprEvaluator.GetUTF8Str(TResEvalString(Value).S,Expr);
    revkUnicodeString: Result:=UTF8Encode(TResEvalUTF16(Value).S);
    else
      str(Value.Kind,Result);
      RaiseXExpectedButYFound(20170211221121,'string literal',Result,Expr);
    end;
  finally
    ReleaseEvalValue(Value);
  end;

  if NotEmpty and (Result='') then
    RaiseXExpectedButYFound(20170321085318,'string literal','empty',Expr);
end;

procedure TPas2JSResolver.CheckAssignExprRangeToCustom(
  const LeftResolved: TPasResolverResult; RValue: TResEvalValue; RHS: TPasExpr);
var
  LeftBaseType: TPas2jsBaseType;
begin
  if (LeftResolved.BaseType<>btCustom) then
    exit;
  if not (LeftResolved.TypeEl is TPasUnresolvedSymbolRef) then
    begin
    {$IFDEF VerbosePas2JS}
    writeln('TPas2JSResolver.CheckAssignExprRangeToCustom LeftResolved=',GetResolverResultDbg(LeftResolved));
    {$ENDIF}
    RaiseInternalError(20170902165913);
    end;
  if not (LeftResolved.TypeEl.CustomData is TResElDataPas2JSBaseType) then
    exit;
  LeftBaseType:=TResElDataPas2JSBaseType(LeftResolved.TypeEl.CustomData).JSBaseType;
  if LeftBaseType=pbtJSValue then
    // jsvalue:=someconst   ->  ok
  else
    RaiseNotYetImplemented(20170902170153,RHS);

  if RHS=nil then ;
  if RValue=nil then ;
end;

function TPas2JSResolver.HasStaticArrayCloneFunc(Arr: TPasArrayType): boolean;
var
  l: Integer;
  ElType: TPasType;
begin
  l:=length(Arr.Ranges);
  if l=0 then exit(false);
  if l>1 then exit(true);
  ElType:=ResolveAliasType(Arr.ElType);
  if ElType is TPasArrayType then
    Result:=length(TPasArrayType(ElType).Ranges)>0
  else if ElType is TPasRecordType then
    Result:=true
  else if ElType is TPasSetType then
    Result:=true
  else
    Result:=false;
end;

function TPas2JSResolver.GetElementData(El: TPasElementBase;
  DataClass: TPas2JsElementDataClass): TPas2JsElementData;
begin
  Result:=nil;
  repeat
    if El.InheritsFrom(DataClass) then
      exit(TPas2JsElementData(El));
    if El.CustomData=nil then exit;
    El:=El.CustomData as TPasElementBase;
  until false;
end;

procedure TPas2JSResolver.AddElementData(Data: TPas2JsElementData);
begin
  Data.Owner:=Self;
  if FFirstElementData<>nil then
    begin
    FLastElementData.Next:=Data;
    FLastElementData:=Data;
    end
  else
    begin
    FFirstElementData:=Data;
    FLastElementData:=Data;
    end;
end;

function TPas2JSResolver.CreateElementData(DataClass: TPas2JsElementDataClass;
  El: TPasElement): TPas2JsElementData;
begin
  Result:=DataClass.Create;
  Result.Element:=El;
  AddElementData(Result);
end;

function TPas2JSResolver.GetBaseDescription(const R: TPasResolverResult;
  AddPath: boolean): string;
begin
  if (R.BaseType=btCustom) and (R.TypeEl.CustomData is TResElDataPas2JSBaseType) then
    Result:=Pas2jsBaseTypeNames[TResElDataPas2JSBaseType(R.TypeEl.CustomData).JSBaseType]
  else
    Result:=inherited GetBaseDescription(R, AddPath);
end;

function TPas2JSResolver.HasTypeInfo(El: TPasType): boolean;
begin
  Result:=inherited HasTypeInfo(El);
  if not Result then exit;
  if (El.ClassType=TPasClassType) and TPasClassType(El).IsExternal then
    exit(false);
  if El.Parent is TProcedureBody then
    Result:=false;
end;

function TPas2JSResolver.IsTObjectFreeMethod(El: TPasExpr): boolean;
var
  Ref: TResolvedReference;
  Decl: TPasElement;
begin
  Result:=false;
  if El=nil then exit;
  if El.ClassType<>TPrimitiveExpr then exit;
  if not (El.CustomData is TResolvedReference) then exit;
  Ref:=TResolvedReference(El.CustomData);
  if CompareText(TPrimitiveExpr(El).Value,'free')<>0 then exit;
  Decl:=Ref.Declaration;
  if not (Decl.ClassType=TPasProcedure)
      or (Decl.Parent.ClassType<>TPasClassType)
      or (CompareText(Decl.Parent.Name,'tobject')<>0)
      or (pmExternal in TPasProcedure(Decl).Modifiers)
      or (TPasProcedure(Decl).ProcType.Args.Count>0) then
    exit;
  Result:=true;
end;

function TPas2JSResolver.IsExternalBracketAccessor(El: TPasElement): boolean;
var
  ExtName: String;
begin
  if (not (El is TPasProcedure)) or (TPasProcedure(El).LibrarySymbolName=nil) then
    exit(false);
  ExtName:=ComputeConstString(TPasProcedure(El).LibrarySymbolName,false,false);
  Result:=ExtName=ExtClassBracketAccessor;
end;

{ TParamContext }

constructor TParamContext.Create(PasEl: TPasElement; JSEl: TJSElement;
  aParent: TConvertContext);
begin
  inherited Create(PasEl, JSEl, aParent);
  Access:=caAssign;
  AccessContext:=Self;
end;

{ TPas2JsElementData }

procedure TPas2JsElementData.SetElement(const AValue: TPasElement);
var
  Data: TPasElementBase;
begin
  if FElement=AValue then Exit;
  if FElement<>nil then
    begin
    Data:=FElement;
    while Data.CustomData<>Self do
      if Data.CustomData is TPasElementBase then
        Data:=TPasElementBase(Data.CustomData)
      else
        begin
        {$IFDEF VerbosePas2JS}
        writeln('TPas2JsElementData.SetElement REMOVE ',ClassName);
        writeln('  ',GetObjName(Data.CustomData));
        {$ENDIF}
        raise EPas2JS.Create('');
        end;
    Data.CustomData:=CustomData;
    TPasElement(FElement).Release;
    end;
  FElement:=AValue;
  if FElement<>nil then
    begin
    TPasElement(FElement).AddRef;
    Data:=FElement;
    while Data.CustomData is TPasElementBase do
      Data:=TPasElementBase(Data.CustomData);
    if Data.CustomData<>nil then
      begin
      {$IFDEF VerbosePas2JS}
      writeln('TPas2JsElementData.SetElement INSERT ',ClassName);
      writeln('  ',GetObjName(Data.CustomData));
      {$ENDIF}
      raise EPas2JS.Create('');
      end;
    Data.CustomData:=Self;
    end;
end;

constructor TPas2JsElementData.Create;
begin

end;

destructor TPas2JsElementData.Destroy;
begin
  Element:=nil;
  Next:=nil;
  Owner:=nil;
  inherited Destroy;
end;

{ TAssignContext }

constructor TAssignContext.Create(PasEl: TPasElement; JSEl: TJSElement;
  aParent: TConvertContext);
begin
  inherited Create(PasEl, JSEl, aParent);
  Access:=caAssign;
  AccessContext:=Self;
end;

{ TSectionContext }

constructor TSectionContext.Create(PasEl: TPasElement; JSEl: TJSElement;
  aParent: TConvertContext);
begin
  inherited;
  IsGlobal:=true;
end;

{ TFunctionContext }

destructor TFunctionContext.Destroy;
var
  i: Integer;
begin
  for i:=0 to length(LocalVars)-1 do
    FreeAndNil(LocalVars[i]);
  inherited Destroy;
end;

procedure TFunctionContext.AddLocalVar(const aName: string; El: TPasElement);
var
  l: Integer;
begin
  l:=length(LocalVars);
  SetLength(LocalVars,l+1);
  LocalVars[l]:=TFCLocalVar.Create(aName,El);
end;

function TFunctionContext.ToString: string;
var
  V: TFCLocalVar;
begin
  Result:=inherited ToString;
  if ThisPas<>nil then
    begin
    Result:=Result+' this';
    V:=FindLocalVar(ThisPas);
    if V<>nil then
      Result:=Result+'="'+V.Name+'"';
    Result:=Result+'='+GetObjName(ThisPas);
    end;
end;

function TFunctionContext.GetLocalName(El: TPasElement): string;
var
  V: TFCLocalVar;
begin
  if El=nil then exit('');
  V:=FindLocalVar(El);
  if V<>nil then
    Result:=V.Name
  else if ThisPas=El then
    Result:='this'
  else
    Result:=inherited GetLocalName(El);
end;

function TFunctionContext.IndexOfLocalVar(const aName: string): integer;
var
  i: Integer;
begin
  for i:=0 to length(LocalVars)-1 do
    if LocalVars[i].Name=aName then exit(i);
  Result:=-1;
end;

function TFunctionContext.IndexOfLocalVar(El: TPasElement): integer;
var
  i: Integer;
begin
  if El=nil then exit(-1);
  for i:=0 to length(LocalVars)-1 do
    if LocalVars[i].Element=El then exit(i);
  Result:=-1;
end;

function TFunctionContext.FindLocalVar(const aName: string): TFCLocalVar;
var
  i: Integer;
begin
  i:=IndexOfLocalVar(aName);
  if i>=0 then
    Result:=LocalVars[i]
  else
    Result:=nil;
end;

function TFunctionContext.FindLocalVar(El: TPasElement): TFCLocalVar;
var
  i: Integer;
begin
  i:=IndexOfLocalVar(El);
  if i>=0 then
    Result:=LocalVars[i]
  else
    Result:=nil;
end;

procedure TFunctionContext.DoWriteStack(Index: integer);
var
  i: Integer;
begin
  inherited DoWriteStack(Index);
  {AllowWriteln}
  for i:=0 to length(LocalVars)-1 do
    writeln('    ',i,' ',LocalVars[i].Name,': ',GetObjName(LocalVars[i].Element));
  {AllowWriteln-}
end;

{ TConvertContext }

constructor TConvertContext.Create(PasEl: TPasElement; JSEl: TJSElement;
  aParent: TConvertContext);
begin
  PasElement:=PasEl;
  JSElement:=JsEl;
  Parent:=aParent;
  if Parent<>nil then
    begin
    Resolver:=Parent.Resolver;
    Access:=aParent.Access;
    AccessContext:=aParent.AccessContext;
    ScannerBoolSwitches:=aParent.ScannerBoolSwitches;
    end;
end;

function TConvertContext.GetRootModule: TPasModule;
var
  aContext: TConvertContext;
begin
  aContext:=Self;
  while aContext.Parent<>nil do
    aContext:=aContext.Parent;
  if aContext.PasElement is TPasModule then
    Result:=TPasModule(aContext.PasElement)
  else
    Result:=nil;
end;

function TConvertContext.GetFunctionContext: TFunctionContext;
begin
  Result:=TFunctionContext(GetContextOfType(TFunctionContext));
end;

function TConvertContext.GetLocalName(El: TPasElement): string;
begin
  if Parent<>nil then
    Result:=Parent.GetLocalName(El)
  else
    Result:='';
end;

function TConvertContext.GetSelfContext: TFunctionContext;
var
  Ctx: TConvertContext;
begin
  Ctx:=Self;
  while Ctx<>nil do
    begin
    if (Ctx is TFunctionContext) and (TFunctionContext(Ctx).ThisPas is TPasClassType) then
      exit(TFunctionContext(Ctx));
    Ctx:=Ctx.Parent;
    end;
  Result:=nil;
end;

function TConvertContext.GetContextOfType(aType: TConvertContextClass
  ): TConvertContext;
var
  ctx: TConvertContext;
begin
  Result:=nil;
  ctx:=Self;
  repeat
    if ctx is aType then
      exit(ctx);
    ctx:=ctx.Parent;
  until ctx=nil;
end;

function TConvertContext.CreateLocalIdentifier(const Prefix: string): string;
begin
  inc(TmpVarCount);
  Result:=Prefix+IntToStr(TmpVarCount);
end;

function TConvertContext.CurrentModeSwitches: TModeSwitches;
begin
  if Resolver=nil then
    Result:=OBJFPCModeSwitches
  else
    Result:=Resolver.CurrentParser.CurrentModeswitches;
end;

function TConvertContext.GetGlobalFunc: TFunctionContext;
var
  Ctx: TConvertContext;
begin
  Ctx:=Self;
  while (Ctx<>nil) do
    begin
    if Ctx.IsGlobal and (Ctx.JSElement<>nil) and (Ctx is TFunctionContext) then
      exit(TFunctionContext(Ctx));
    Ctx:=Ctx.Parent;
    end;
end;

procedure TConvertContext.WriteStack;
{AllowWriteln}

  procedure W(Index: integer; AContext: TConvertContext);
  begin
    AContext.DoWriteStack(Index);
    if AContext.Parent<>nil then
      W(Index+1,AContext.Parent);
  end;

begin
  writeln('TConvertContext.WriteStack: ');
  W(1,Self);
end;
{AllowWriteln-}

procedure TConvertContext.DoWriteStack(Index: integer);
begin
  {AllowWriteln}
  writeln('  ',Index,' ',ToString);
  {AllowWriteln-}
end;

function TConvertContext.ToString: string;
begin
  Result:='['+ClassName+']'
    +' pas='+GetObjName(PasElement)
    +' js='+GetObjName(JSElement)
    +' Global='+BoolToStr(IsGlobal,true);
end;

{ TPasToJSConverter }

// inline
function TPasToJSConverter.GetUseEnumNumbers: boolean;
begin
  Result:=coEnumNumbers in FOptions;
end;

// inline
function TPasToJSConverter.GetUseLowerCase: boolean;
begin
  Result:=coLowerCase in FOptions;
end;

// inline
function TPasToJSConverter.GetUseSwitchStatement: boolean;
begin
  Result:=coSwitchStatement in FOptions;
end;

procedure TPasToJSConverter.AddToSourceElements(Src: TJSSourceElements;
  El: TJSElement);

Var
  List : TJSStatementList;
  AddEl : TJSElement;

begin
  While El<>nil do
  begin
    if El is TJSStatementList then
      begin
      List:=El as TJSStatementList;
      // List.A is first statement, List.B is next in list, chained.
      // -> add A, continue with B and free List
      AddEl:=List.A;
      El:=List.B;
      List.A:=Nil;
      List.B:=Nil;
      FreeAndNil(List);
      end
    else
      begin
      AddEl:=El;
      El:=Nil;
      end;
    Src.Statements.AddNode.Node:=AddEl;
  end;
end;

procedure TPasToJSConverter.RemoveFromSourceElements(Src: TJSSourceElements;
  El: TJSElement);
var
  Statements: TJSElementNodes;
  i: Integer;
begin
  Statements:=Src.Statements;
  for i:=Statements.Count-1 downto 0 do
    if Statements[i].Node=El then
      Statements.Delete(i);
end;

function TPasToJSConverter.GetBuildInNames(bin: TPas2JSBuiltInName): string;
begin
  Result:=FBuiltInNames[bin];
end;

procedure TPasToJSConverter.SetBuildInNames(bin: TPas2JSBuiltInName;
  const AValue: string);
begin
  FBuiltInNames[bin]:=AValue;
end;

procedure TPasToJSConverter.SetPreservedWords(const AValue: TJSReservedWordList
  );
var
  i: Integer;
begin
  if FPreservedWords=AValue then Exit;
  for i:=0 to length(AValue)-2 do
    if CompareStr(AValue[i],AValue[i+1])>=0 then
      raise Exception.Create('TPasToJSConverter.SetPreservedWords "'+AValue[i]+'" >= "'+AValue[i+1]+'"');
  FPreservedWords:=AValue;
end;

function TPasToJSConverter.ConvertModule(El: TPasModule;
  AContext: TConvertContext): TJSElement;
(*
Program:
 rtl.module('program',
    [<uses1>,<uses2>, ...],
    function(){
      <programsection>
      this.$main=function(){
        <initialization>
        };
    });

Unit:
 rtl.module('<unitname>',
    [<interface uses1>,<uses2>, ...],
    function(){
      var $impl = {};
      this.$impl = $impl;
      <interface>
      this.$init=function(){
        <initialization>
        };
    },
    [<implementation uses1>,<uses2>, ...],
    function(){
      var $impl = this.$impl;
      <implementation>
    });
*)
Var
  OuterSrc , Src: TJSSourceElements;
  RegModuleCall: TJSCallExpression;
  ArgArray: TJSArguments;
  FunDecl, ImplFunc: TJSFunctionDeclarationStatement;
  UsesSection: TPasSection;
  ModuleName, ModVarName: String;
  IntfContext: TSectionContext;
  ImplVarSt: TJSVariableStatement;
  HasImplUsesClause: Boolean;
  UsesClause: TPasUsesClause;
begin
  Result:=Nil;
  OuterSrc:=TJSSourceElements(CreateElement(TJSSourceElements, El));
  Result:=OuterSrc;

  // create 'rtl.module(...)'
  RegModuleCall:=CreateCallExpression(El);
  AddToSourceElements(OuterSrc,RegModuleCall);
  RegModuleCall.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],'module']);
  ArgArray := RegModuleCall.Args;
  RegModuleCall.Args:=ArgArray;

  // add unitname parameter: unitname
  ModuleName:=TransformModuleName(El,false,AContext);
  ArgArray.Elements.AddElement.Expr:=CreateLiteralString(El,ModuleName);

  // add interface-uses-section parameter: [<interface uses1>,<uses2>, ...]
  UsesSection:=nil;
  if (El is TPasProgram) then
    UsesSection:=TPasProgram(El).ProgramSection
  else if (El is TPasLibrary) then
    UsesSection:=TPasLibrary(El).LibrarySection
  else
    UsesSection:=El.InterfaceSection;
  ArgArray.Elements.AddElement.Expr:=CreateUsesList(UsesSection,AContext);

  // add interface parameter: function(){}
  FunDecl:=CreateFunctionSt(El,true,true);
  ArgArray.AddElement(FunDecl);
  Src:=FunDecl.AFunction.Body.A as TJSSourceElements;

  if coUseStrict in Options then
    // "use strict" must be the first statement in a function
    AddToSourceElements(Src,CreateLiteralString(El,'use strict'));

  ImplVarSt:=nil;
  HasImplUsesClause:=false;

  IntfContext:=TSectionContext.Create(El,Src,AContext);
  try
    // add "var $mod = this;"
    IntfContext.ThisPas:=El;
    if El.CustomData is TPasModuleScope then
      IntfContext.ScannerBoolSwitches:=TPasModuleScope(El.CustomData).BoolSwitches;
    ModVarName:=FBuiltInNames[pbivnModule];
    IntfContext.AddLocalVar(ModVarName,El);
    AddToSourceElements(Src,CreateVarStatement(ModVarName,
      CreatePrimitiveDotExpr('this',El),El));

    if (El is TPasProgram) then
      begin // program
      if Assigned(TPasProgram(El).ProgramSection) then
        AddToSourceElements(Src,ConvertDeclarations(TPasProgram(El).ProgramSection,IntfContext));
      CreateInitSection(El,Src,IntfContext);
      end
    else if El is TPasLibrary then
      begin // library
      if Assigned(TPasLibrary(El).LibrarySection) then
        AddToSourceElements(Src,ConvertDeclarations(TPasLibrary(El).LibrarySection,IntfContext));
      CreateInitSection(El,Src,IntfContext);
      end
    else
      begin // unit
      if Assigned(El.ImplementationSection) then
        begin
        // add var $impl = $mod.$impl
        ImplVarSt:=CreateVarStatement(FBuiltInNames[pbivnImplementation],
          CreateMemberExpression([ModVarName,FBuiltInNames[pbivnImplementation]]),El);
        AddToSourceElements(Src,ImplVarSt);
        // register local var $impl
        IntfContext.AddLocalVar(FBuiltInNames[pbivnImplementation],El.ImplementationSection);
        end;
      if Assigned(El.InterfaceSection) then
        AddToSourceElements(Src,ConvertDeclarations(El.InterfaceSection,IntfContext));
      CreateInitSection(El,Src,IntfContext);

      // add optional implementation uses list: [<implementation uses1>,<uses2>, ...]
      if Assigned(El.ImplementationSection) then
        begin
        UsesClause:=El.ImplementationSection.UsesClause;
        if length(UsesClause)>0 then
          begin
          ArgArray.AddElement(CreateUsesList(El.ImplementationSection,AContext));
          HasImplUsesClause:=true;
          end;
        end;

      end;
  finally
    IntfContext.Free;
  end;

  // add implementation function
  if ImplVarSt<>nil then
    begin
    ImplFunc:=CreateImplementationSection(El,AContext);
    if ImplFunc=nil then
      begin
      // remove unneeded $impl from interface
      RemoveFromSourceElements(Src,ImplVarSt);
      end
    else
      begin
      // add param
      if not HasImplUsesClause then
        ArgArray.AddElement(CreateLiteralNull(El));
      ArgArray.AddElement(ImplFunc);
      end;
    end;
end;

function TPasToJSConverter.CreateElement(C: TJSElementClass; Src: TPasElement
  ): TJSElement;

var
  Line, Col: Integer;
begin
  if Assigned(Src) then
    begin
    TPasResolver.UnmangleSourceLineNumber(Src.SourceLinenumber,Line,Col);
    Result:=C.Create(Line,Col,Src.SourceFilename);
    end
  else
    Result:=C.Create(0,0);
end;

function TPasToJSConverter.CreateFreeOrNewInstanceExpr(Ref: TResolvedReference;
  AContext: TConvertContext): TJSCallExpression;
// create "$create("funcname");"
var
  ok: Boolean;
  C: TJSCallExpression;
  Proc: TPasProcedure;
  ProcScope: TPasProcedureScope;
  ClassScope: TPasClassScope;
  aClass: TPasElement;
  ArgEx: TJSLiteral;
  ArgElems: TJSArrayLiteralElements;
  FunName: String;
begin
  Result:=nil;
  //writeln('TPasToJSConverter.CreateFreeOrNewInstanceExpr Ref.Declaration=',GetObjName(Ref.Declaration));
  Proc:=Ref.Declaration as TPasProcedure;
  if Proc.Name='' then
    RaiseInconsistency(20170125191914,Proc);
  //writeln('TPasToJSConverter.CreateFreeOrNewInstanceExpr Proc.Name=',Proc.Name);
  ProcScope:=Proc.CustomData as TPasProcedureScope;
  //writeln('TPasToJSConverter.CreateFreeOrNewInstanceExpr ProcScope.Element=',GetObjName(ProcScope.Element),' ProcScope.ClassScope=',GetObjName(ProcScope.ClassScope),' ProcScope.DeclarationProc=',GetObjName(ProcScope.DeclarationProc),' ProcScope.ImplProc=',GetObjName(ProcScope.ImplProc),' ProcScope.CustomData=',GetObjName(ProcScope.CustomData));
  ClassScope:=ProcScope.ClassScope;
  aClass:=ClassScope.Element;
  if aClass.Name='' then
    RaiseInconsistency(20170125191923,aClass);
  //writeln('TPasToJSConverter.CreateFreeOrNewInstanceExpr aClass.Name=',aClass.Name);
  C:=CreateCallExpression(Ref.Element);
  ok:=false;
  try
    // add "$create()"
    if rrfNewInstance in Ref.Flags then
      FunName:=FBuiltInNames[pbifnClassInstanceNew]
    else
      FunName:=FBuiltInNames[pbifnClassInstanceFree];
    FunName:=CreateReferencePath(Proc,AContext,rpkPathWithDot,false,Ref)+FunName;
    C.Expr:=CreatePrimitiveDotExpr(FunName,Ref.Element);
    ArgElems:=C.Args.Elements;
    // parameter: "funcname"
    ArgEx := CreateLiteralString(Ref.Element,TransformVariableName(Proc,AContext));
    ArgElems.AddElement.Expr:=ArgEx;
    ok:=true;
  finally
    if not ok then
      C.Free;
  end;
  Result:=C;
end;

function TPasToJSConverter.CreateFunctionSt(El: TPasElement; WithBody: boolean;
  WithSrc: boolean): TJSFunctionDeclarationStatement;
var
  FuncSt: TJSFunctionDeclarationStatement;
begin
  FuncSt:=TJSFunctionDeclarationStatement(CreateElement(TJSFunctionDeclarationStatement,El));
  Result:=FuncSt;
  FuncSt.AFunction:=CreateFunctionDef(El,WithBody,WithSrc);
end;

function TPasToJSConverter.CreateFunctionDef(El: TPasElement;
  WithBody: boolean; WithSrc: boolean): TJSFuncDef;
begin
  Result:=TJSFuncDef.Create;
  if WithBody then
    begin
    Result.Body:=TJSFunctionBody(CreateElement(TJSFunctionBody,El));
    if WithSrc then
      Result.Body.A:=TJSSourceElements(CreateElement(TJSSourceElements, El));
    end;
end;

function TPasToJSConverter.ConvertUnaryExpression(El: TUnaryExpr;
  AContext: TConvertContext): TJSElement;

  procedure NotSupported;
  begin
    DoError(20170215134950,nUnaryOpcodeNotSupported,sUnaryOpcodeNotSupported,
            [OpcodeStrings[El.OpCode]],El);
  end;

Var
  U : TJSUnaryExpression;
  E : TJSElement;
  ResolvedOp, ResolvedEl: TPasResolverResult;
  BitwiseNot: Boolean;

begin
  if AContext=nil then ;
  Result:=Nil;
  U:=nil;
  Case El.OpCode of
    eopAdd:
      begin
      E:=ConvertElement(El.Operand,AContext);
      U:=TJSUnaryPlusExpression(CreateElement(TJSUnaryPlusExpression,El));
      U.A:=E;
      end;
    eopSubtract:
      begin
      E:=ConvertElement(El.Operand,AContext);
      U:=TJSUnaryMinusExpression(CreateElement(TJSUnaryMinusExpression,El));
      U.A:=E;
      end;
    eopNot:
      begin
      E:=ConvertElement(El.Operand,AContext);
      BitwiseNot:=true;
      if AContext.Resolver<>nil then
        begin
        AContext.Resolver.ComputeElement(El.Operand,ResolvedOp,[]);
        BitwiseNot:=ResolvedOp.BaseType in btAllJSInteger;
        end;
      if BitwiseNot then
        U:=TJSUnaryInvExpression(CreateElement(TJSUnaryInvExpression,El))
      else
        U:=TJSUnaryNotExpression(CreateElement(TJSUnaryNotExpression,El));
      U.A:=E;
      end;
    eopAddress:
      begin
      if AContext.Resolver=nil then
        NotSupported;
      AContext.Resolver.ComputeElement(El.Operand,ResolvedEl,[rcNoImplicitProc]);
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.ConvertUnaryExpression ',GetResolverResultDbg(ResolvedEl));
      {$ENDIF}
      if ResolvedEl.BaseType=btProc then
        begin
        if ResolvedEl.IdentEl is TPasProcedure then
          begin
          Result:=CreateCallback(El.Operand,ResolvedEl,AContext);
          exit;
          end;
        end;
      end;
    eopMemAddress:
      begin
      // @@ProcVar -> ProcVar
      Result:=ConvertElement(El.Operand,AContext);
      exit;
      end;
  end;
  if U=nil then
    NotSupported;
  Result:=U;
end;

function TPasToJSConverter.GetExpressionValueType(El: TPasExpr;
  AContext: TConvertContext): TJSType;

  Function CombineValueType(A,B : TJSType) : TJSType;

  begin
    If (A=jstUNDEFINED) then
      Result:=B
    else if (B=jstUNDEFINED) then
      Result:=A
    else
      Result:=A; // pick the first
  end;

Var
  A,B : TJSType;

begin
  if (El is TBoolConstExpr) then
    Result:=jstBoolean
  else if (El is TPrimitiveExpr) then
    begin
    Case El.Kind of
      pekIdent : Result:=GetPasIdentValueType(El.Name,AContext);
      pekNumber : Result:=jstNumber;
      pekString : Result:=jstString;
      pekSet : Result:=jstUNDEFINED;
      pekNil : Result:=jstNull;
      pekBoolConst : Result:=jstBoolean;
      pekRange : Result:=jstUNDEFINED;
      pekFuncParams : Result:=jstUNDEFINED;
      pekArrayParams : Result:=jstUNDEFINED;
      pekListOfExp : Result:=jstUNDEFINED;
      pekInherited : Result:=jstUNDEFINED;
      pekSelf : Result:=jstObject;
    end
    end
  else if (El is TUnaryExpr) then
    Result:=GetExpressionValueType(TUnaryExpr(El).Operand,AContext)
  else if (El is TBinaryExpr) then
    begin
    A:=GetExpressionValueType(TBinaryExpr(El).Left,AContext);
    B:=GetExpressionValueType(TBinaryExpr(El).Right,AContext);
    Result:=CombineValueType(A,B);
    end
  else
    result:=jstUndefined
end;

function TPasToJSConverter.GetPasIdentValueType(AName: String;
  AContext: TConvertContext): TJSType;

begin
  if AContext=nil then ;
  if AName='' then ;
  Result:=jstUNDEFINED;
end;

function TPasToJSConverter.ComputeConstString(Expr: TPasExpr;
  AContext: TConvertContext; NotEmpty: boolean): String;
var
  Prim: TPrimitiveExpr;
begin
  if AContext.Resolver<>nil then
    Result:=AContext.Resolver.ComputeConstString(Expr,false,NotEmpty)
  else
    begin
    // fall back:
    Result:='';
    if Expr is TPrimitiveExpr then
      begin
      Prim:=TPrimitiveExpr(Expr);
      if Prim.Kind=pekString then
        Result:=Prim.Value
      else
        RaiseNotSupported(Prim,AContext,20170215124733);
      end
    else
      RaiseNotSupported(Expr,AContext,20170322121331);
    end;
end;

function TPasToJSConverter.IsExternalClassConstructor(El: TPasElement): boolean;
var
  P: TPasElement;
begin
  if (El.ClassType=TPasConstructor)
      and (pmExternal in TPasConstructor(El).Modifiers) then
    begin
    P:=El.Parent;
    if (P<>nil) and (P.ClassType=TPasClassType) and TPasClassType(P).IsExternal then
      exit(true);
    end;
  Result:=false;
end;

function TPasToJSConverter.IsLiteralInteger(El: TJSElement; out
  Number: MaxPrecInt): boolean;
begin
  Result:=false;
  if not (El is TJSLiteral) then exit;
  if (TJSLiteral(El).Value.ValueType=jstNumber) then
    try
      Number:=Round(TJSLiteral(El).Value.AsNumber);
      if Number=TJSLiteral(El).Value.AsNumber then
        exit(true);
    except
    end;
end;

function TPasToJSConverter.ConvertBinaryExpression(El: TBinaryExpr;
  AContext: TConvertContext): TJSElement;
Const
  BinClasses : Array [TExprOpCode] of TJSBinaryClass = (
   Nil, //eopEmpty,
   TJSAdditiveExpressionPlus, // +
   TJSAdditiveExpressionMinus, // -
   TJSMultiplicativeExpressionMul, // *
   TJSMultiplicativeExpressionDiv, // /
   TJSMultiplicativeExpressionDiv, // div
   TJSMultiplicativeExpressionMod, // mod
   Nil, //eopPower
   TJSURShiftExpression, // shr
   TJSLShiftExpression, // shl
   Nil, // Not
   Nil, // And
   Nil, // Or
   Nil, // XOr
   TJSEqualityExpressionSEQ,
   TJSEqualityExpressionSNE,
   TJSRelationalExpressionLT,
   TJSRelationalExpressionGT,
   TJSRelationalExpressionLE,
   TJSRelationalExpressionGE,
   Nil, // In
   TJSRelationalExpressionInstanceOf, // is
   Nil, // As
   Nil, // Symmetrical diff
   Nil, // Address,
   Nil, // Deref
   Nil, // MemAddress
   Nil  // SubIndent,
  );

Var
  R : TJSBinary;
  C : TJSBinaryClass;
  A,B: TJSElement;
  UseBitwiseOp: Boolean;
  Call: TJSCallExpression;
  LeftResolved, RightResolved: TPasResolverResult;
  Flags: TPasResolverComputeFlags;
  ModeSwitches: TModeSwitches;
begin
  Result:=Nil;

  case El.OpCode of
  eopSubIdent:
    begin
    Result:=ConvertSubIdentExpression(El,AContext);
    exit;
    end;
  eopNone:
    if El.left is TInheritedExpr then
      begin
      Result:=ConvertInheritedExpression(TInheritedExpr(El.left),AContext);
      exit;
      end;
  end;

  if AContext.Access<>caRead then
    begin
    {$IFDEF VerbosePas2JS}
    writeln('TPasToJSConverter.ConvertBinaryExpression OpCode=',El.OpCode,' AContext.Access=',AContext.Access);
    {$ENDIF}
    DoError(20170209152633,nVariableIdentifierExpected,sVariableIdentifierExpected,[],El);
    end;

  Call:=nil;
  A:=ConvertElement(El.left,AContext);
  B:=nil;
  try
    B:=ConvertElement(El.right,AContext);

    if AContext.Resolver<>nil then
      begin
      ModeSwitches:=AContext.CurrentModeSwitches;
      // compute left
      Flags:=[];
      if El.OpCode in [eopEqual,eopNotEqual] then
        if not (msDelphi in ModeSwitches) then
          Flags:=[rcNoImplicitProcType];
      AContext.Resolver.ComputeElement(El.left,LeftResolved,Flags);

      // compute right
      Flags:=[];
      if (El.OpCode in [eopEqual,eopNotEqual])
          and not (msDelphi in ModeSwitches) then
        begin
        if LeftResolved.BaseType=btNil then
          Flags:=[rcNoImplicitProcType]
        else if AContext.Resolver.IsProcedureType(LeftResolved,true) then
          Flags:=[rcNoImplicitProcType]
        else
          Flags:=[];
        end;
      AContext.Resolver.ComputeElement(El.right,RightResolved,Flags);

      Result:=ConvertBinaryExpressionRes(El,AContext,LeftResolved,RightResolved,A,B);
      if Result<>nil then exit;
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.ConvertBinaryExpression Left=',GetResolverResultDbg(LeftResolved),' Right=',GetResolverResultDbg(RightResolved));
      {$ENDIF}
      end;

    C:=BinClasses[El.OpCode];
    if C=nil then
      Case El.OpCode of
        eopAs :
          begin
          // "A as B"
          Call:=CreateCallExpression(El);
          if (RightResolved.TypeEl is TPasClassType)
              and TPasClassType(RightResolved.TypeEl).IsExternal then
            // B is external class -> "rtl.asExt(A,B)"
            Call.Expr:=CreatePrimitiveDotExpr(FBuiltInNames[pbivnRTL]+'.'+FBuiltInNames[pbifnAsExt],El)
          else
            // otherwise -> "rtl.as(A,B)"
            Call.Expr:=CreatePrimitiveDotExpr(FBuiltInNames[pbivnRTL]+'.'+FBuiltInNames[pbifnAs],El);
          Call.AddArg(A);
          Call.AddArg(B);
          Result:=Call;
          exit;
          end;
        eopAnd,
        eopOr,
        eopXor:
          begin
          if AContext.Resolver<>nil then
            UseBitwiseOp:=((LeftResolved.BaseType in btAllJSInteger)
                       or (RightResolved.BaseType in btAllJSInteger))
          else
            UseBitwiseOp:=(GetExpressionValueType(El.left,AContext)=jstNumber)
              or (GetExpressionValueType(El.right,AContext)=jstNumber);
          if UseBitwiseOp then
            Case El.OpCode of
              eopAnd : C:=TJSBitwiseAndExpression;
              eopOr : C:=TJSBitwiseOrExpression;
              eopXor : C:=TJSBitwiseXOrExpression;
            end
          else
            Case El.OpCode of
              eopAnd : C:=TJSLogicalAndExpression;
              eopOr : C:=TJSLogicalOrExpression;
              eopXor : C:=TJSBitwiseXOrExpression;
            else
              DoError(20161024191234,nBinaryOpcodeNotSupported,sBinaryOpcodeNotSupported,['logical XOR'],El);
            end;
          end;
        eopPower:
          begin
          Call:=CreateCallExpression(El);
          Call.Expr:=CreatePrimitiveDotExpr('Math.pow',El);
          Call.AddArg(A);
          Call.AddArg(B);
          Result:=Call;
          end
        else
          if C=nil then
            DoError(20161024191244,nBinaryOpcodeNotSupported,sBinaryOpcodeNotSupported,[OpcodeStrings[El.OpCode]],El);
      end;
    if (Result=Nil) and (C<>Nil) then
      begin
      R:=TJSBinary(CreateElement(C,El));
      R.A:=A; A:=nil;
      R.B:=B; B:=nil;
      Result:=R;

      if El.OpCode=eopDiv then
        begin
        // convert "a div b" to "Math.floor(a/b)"
        Call:=CreateCallExpression(El);
        Call.AddArg(R);
        Call.Expr:=CreatePrimitiveDotExpr('Math.floor',El);
        Result:=Call;
        end;
      end;
  finally
    if Result=nil then
      begin
      A.Free;
      B.Free;
      end;
  end;
end;

function TPasToJSConverter.ConvertBinaryExpressionRes(El: TBinaryExpr;
  AContext: TConvertContext; const LeftResolved,
  RightResolved: TPasResolverResult; var A, B: TJSElement): TJSElement;

  function CreateEqualCallback: TJSElement;
  var
    Call: TJSCallExpression;
    NotEl: TJSUnaryNotExpression;
  begin
    // convert "proctypeA = proctypeB" to "rtl.eqCallback(proctypeA,proctypeB)"
    Call:=CreateCallExpression(El);
    Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnProcType_Equal]]);
    Call.AddArg(A);
    A:=nil;
    Call.AddArg(B);
    B:=nil;
    if El.OpCode=eopNotEqual then
      begin
      // convert "proctypeA <> proctypeB" to "!rtl.eqCallback(proctypeA,proctypeB)"
      NotEl:=TJSUnaryNotExpression(CreateElement(TJSUnaryNotExpression,El));
      NotEl.A:=Call;
      Result:=NotEl;
      end
    else
      Result:=Call;
  end;

var
  FunName: String;
  Call: TJSCallExpression;
  DotExpr: TJSDotMemberExpression;
  NotEl: TJSUnaryNotExpression;
  InOp: TJSRelationalExpressionIn;
  TypeEl, LeftTypeEl, RightTypeEl: TPasType;
begin
  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.ConvertBinaryExpressionRes OpCode="',OpcodeStrings[El.OpCode],'" Left=',GetResolverResultDbg(LeftResolved),' Right=',GetResolverResultDbg(RightResolved));
  {$ENDIF}
  Result:=nil;
  if LeftResolved.BaseType=btSet then
    begin
    // set operators -> rtl.operatorfunction(a,b)
    case El.OpCode of
    eopAdd: FunName:=FBuiltInNames[pbifnSet_Union];
    eopSubtract: FunName:=FBuiltInNames[pbifnSet_Difference];
    eopMultiply: FunName:=FBuiltInNames[pbifnSet_Intersect];
    eopSymmetricaldifference: FunName:=FBuiltInNames[pbifnSet_SymDiffSet];
    eopEqual: FunName:=FBuiltInNames[pbifnSet_Equal];
    eopNotEqual: FunName:=FBuiltInNames[pbifnSet_NotEqual];
    eopGreaterThanEqual: FunName:=FBuiltInNames[pbifnSet_GreaterEqual];
    eopLessthanEqual: FunName:=FBuiltInNames[pbifnSet_LowerEqual];
    else
      DoError(20170209151300,nBinaryOpcodeNotSupported,sBinaryOpcodeNotSupported,[OpcodeStrings[El.OpCode]],El);
    end;
    Call:=CreateCallExpression(El);
    Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FunName]);
    Call.AddArg(A);
    A:=nil;
    Call.AddArg(B);
    B:=nil;
    Result:=Call;
    exit;
    end
  else if (RightResolved.BaseType=btSet) and (El.OpCode=eopIn) then
    begin
    // a in b -> a in b
    if not (A is TJSLiteral) or (TJSLiteral(A).Value.ValueType<>jstNumber) then
      begin
      FreeAndNil(A);
      A:=CreateSetLiteralElement(El.left,AContext);
      end;
    InOp:=TJSRelationalExpressionIn(CreateElement(TJSRelationalExpressionIn,El));
    InOp.A:=A;
    A:=nil;
    InOp.B:=B;
    B:=nil;
    Result:=InOp;
    exit;
    end
  else if (El.OpCode=eopIs) then
    begin
    // "A is B"
    LeftTypeEl:=AContext.Resolver.ResolveAliasType(LeftResolved.TypeEl);
    RightTypeEl:=AContext.Resolver.ResolveAliasType(RightResolved.TypeEl);
    Call:=CreateCallExpression(El);
    Result:=Call;
    Call.AddArg(A); A:=nil;
    if (RightResolved.IdentEl is TPasType) then
      TypeEl:=AContext.Resolver.ResolveAliasType(TPasType(RightResolved.IdentEl))
    else
      TypeEl:=nil;
    if (TypeEl is TPasClassOfType) then
      begin
      // "A is class-of-type" -> use the class
      FreeAndNil(B);
      TypeEl:=AContext.Resolver.ResolveAliasType(TPasClassOfType(TypeEl).DestType);
      B:=CreateReferencePathExpr(TypeEl,AContext);
      end;
    if (LeftResolved.BaseType=btCustom) then
      begin
      // aJSValue is ... -> "rtl.isExt(A,B,mode)"
      Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnIsExt]]);
      Call.AddArg(B); B:=nil;
      if RightTypeEl is TPasClassType then
        Call.AddArg(CreateLiteralNumber(El.right,IsExtModePasClassInstance))
      else if RightTypeEl is TPasClassOfType then
        Call.AddArg(CreateLiteralNumber(El.right,IsExtModePasClass))
      else
        RaiseNotSupported(El,AContext,20180119005904);
      end
    else if (RightTypeEl is TPasClassType) and TPasClassType(RightTypeEl).IsExternal then
      begin
      // B is an external class -> "rtl.isExt(A,B)"
      Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnIsExt]]);
      Call.AddArg(B); B:=nil;
      end
    else if LeftTypeEl is TPasClassOfType then
      begin
      // A is a TPasClassOfType -> "rtl.is(A,B)"
      Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnIs]]);
      Call.AddArg(B); B:=nil;
      end
    else
      begin
      // use directly "B.isPrototypeOf(A)"
      DotExpr:=TJSDotMemberExpression(CreateElement(TJSDotMemberExpression,El));
      DotExpr.MExpr:=B; B:=nil;
      DotExpr.Name:='isPrototypeOf';
      Call.Expr:=DotExpr;
      end;
    exit;
    end
  else if (El.OpCode in [eopEqual,eopNotEqual]) then
    begin
    if AContext.Resolver.IsProcedureType(LeftResolved,true) then
      begin
      if RightResolved.BaseType=btNil then
      else if AContext.Resolver.IsProcedureType(RightResolved,true)
          or AContext.Resolver.IsJSBaseType(RightResolved,pbtJSValue,true) then
        exit(CreateEqualCallback);
      end
    else if AContext.Resolver.IsProcedureType(RightResolved,true) then
      begin
      if LeftResolved.BaseType=btNil then
      else if AContext.Resolver.IsJSBaseType(LeftResolved,pbtJSValue,true) then
        exit(CreateEqualCallback);
      end
    else if LeftResolved.TypeEl is TPasRecordType then
      begin
      // convert "recordA = recordB" to "recordA.$equal(recordB)"
      Call:=CreateCallExpression(El);
      Call.Expr:=CreateDotExpression(El,A,CreatePrimitiveDotExpr(FBuiltInNames[pbifnRecordEqual],El));
      A:=nil;
      Call.AddArg(B);
      B:=nil;
      if El.OpCode=eopNotEqual then
        begin
        // convert "recordA = recordB" to "!recordA.$equal(recordB)"
        NotEl:=TJSUnaryNotExpression(CreateElement(TJSUnaryNotExpression,El));
        NotEl.A:=Call;
        Result:=NotEl;
        end
      else
        Result:=Call;
      exit;
      end
    else if LeftResolved.TypeEl is TPasArrayType then
      begin
      if RightResolved.BaseType=btNil then
        begin
        // convert "array = nil" to "rtl.length(array) > 0"
        FreeAndNil(B);
        Result:=CreateCmpArrayWithNil(El,A,El.OpCode);
        A:=nil;
        exit;
        end;
      end
    else if RightResolved.TypeEl is TPasArrayType then
      begin
      if LeftResolved.BaseType=btNil then
        begin
        // convert "nil = array" to "0 < rtl.length(array)"
        FreeAndNil(A);
        Result:=CreateCmpArrayWithNil(El,B,El.OpCode);
        B:=nil;
        exit;
        end;
      end
    else if AContext.Resolver.IsJSBaseType(LeftResolved,pbtJSValue)
        or AContext.Resolver.IsJSBaseType(RightResolved,pbtJSValue) then
      begin
        // convert "jsvalue = something" to "jsvalue == something" (not strict)
        // Note: default "=" is converted to "===" (strict equal)
        if El.OpCode=eopEqual then
          Result:=TJSEqualityExpressionEQ(CreateElement(TJSEqualityExpressionEQ,El))
        else
          Result:=TJSEqualityExpressionNE(CreateElement(TJSEqualityExpressionNE,El));
        TJSBinaryExpression(Result).A:=A; A:=nil;
        TJSBinaryExpression(Result).B:=B; B:=nil;
        exit;
      end;
    end;
end;

function TPasToJSConverter.ConvertSubIdentExpression(El: TBinaryExpr;
  AContext: TConvertContext): TJSElement;
// connect El.left and El.right with a dot.
var
  Left, Right: TJSElement;
  DotContext: TDotContext;
  OldAccess: TCtxAccess;
  LeftResolved: TPasResolverResult;
  RightRef: TResolvedReference;
  ParamsExpr: TParamsExpr;
  RightEl: TPasExpr;
begin
  Result:=nil;

  ParamsExpr:=nil;
  RightEl:=El.right;
  while RightEl.ClassType=TParamsExpr do
    begin
    ParamsExpr:=TParamsExpr(RightEl);
    RightEl:=ParamsExpr.Value;
    end;

  if (RightEl.ClassType=TPrimitiveExpr)
      and (RightEl.CustomData is TResolvedReference) then
    begin
    RightRef:=TResolvedReference(RightEl.CustomData);
    if IsExternalClassConstructor(RightRef.Declaration) then
      begin
      if ParamsExpr<>nil then
        begin
        // left side is done in ConvertFuncParams
        Result:=ConvertParamsExpression(El.right as TParamsExpr,AContext);
        end
      else
        Result:=ConvertExternalConstructor(El.left,RightRef,nil,AContext);
      exit;
      end
    else if AContext.Resolver.IsTObjectFreeMethod(RightEl) then
      begin
      Result:=ConvertTObjectFree(El,RightEl,AContext);
      exit;
      end;
    end;

  if AContext.Resolver<>nil then
    begin
    AContext.Resolver.ComputeElement(El.left,LeftResolved,[]);
    if LeftResolved.BaseType=btModule then
      begin
      // e.g. System.ExitCode
      // unit prefix is automatically created -> omit
      Result:=ConvertElement(El.right,AContext);
      exit;
      end;
    end;
  // convert left side
  OldAccess:=AContext.Access;
  AContext.Access:=caRead;
  Left:=ConvertElement(El.left,AContext);
  if Left=nil then
    RaiseInconsistency(20170201140821,El);
  AContext.Access:=OldAccess;
  // convert right side
  DotContext:=TDotContext.Create(El,Left,AContext);
  Right:=nil;
  try
    DotContext.LeftResolved:=LeftResolved;
    Right:=ConvertElement(El.right,DotContext);
  finally
    DotContext.Free;
    if Right=nil then
      Left.Free;
  end;
  if Right is TJSLiteral then
    begin
    FreeAndNil(Left);
    exit(Right);
    end;
  // connect via dot
  Result:=CreateDotExpression(El,Left,Right);
end;

function TPasToJSConverter.CreateIdentifierExpr(El: TPasElement;
  AContext: TConvertContext): TJSElement;
begin
  Result:=CreatePrimitiveDotExpr(TransformVariableName(El,AContext),El);
end;

function TPasToJSConverter.CreateIdentifierExpr(AName: string; El: TPasElement;
  AContext: TConvertContext): TJSElement;
begin
  Result:=CreatePrimitiveDotExpr(TransformVariableName(El,AName,AContext),El);
end;

function TPasToJSConverter.CreateSubDeclNameExpr(El: TPasElement;
  const Name: string; AContext: TConvertContext; PosEl: TPasElement
  ): TJSElement;
var
  CurName, ParentName: String;
begin
  if PosEl=nil then PosEl:=El;
  CurName:=TransformVariableName(El,Name,AContext);
  ParentName:=AContext.GetLocalName(El.Parent);
  if ParentName='' then
    ParentName:='this';
  CurName:=ParentName+'.'+CurName;
  Result:=CreatePrimitiveDotExpr(CurName,PosEl);
end;

function TPasToJSConverter.ConvertPrimitiveExpression(El: TPrimitiveExpr;
  AContext: TConvertContext): TJSElement;

Var
  L : TJSLiteral;
  Number : TJSNumber;
  ConversionError : Integer;
  i: Int64;
  S: String;
begin
  {$IFDEF VerbosePas2JS}
  str(El.Kind,S);
  writeln('TPasToJSConverter.ConvertPrimitiveExpression El=',GetObjName(El),' Context=',GetObjName(AContext),' El.Kind=',S);
  {$ENDIF}
  Result:=Nil;
  case El.Kind of
    pekString:
      begin
      if AContext.Resolver<>nil then
        Result:=CreateLiteralJSString(El,
          AContext.Resolver.ExtractPasStringLiteral(El,El.Value))
      else
        begin
        S:=AnsiDequotedStr(El.Value,'''');
        Result:=CreateLiteralString(El,S);
        end;
      //writeln('TPasToJSConverter.ConvertPrimitiveExpression Result="',TJSLiteral(Result).Value.AsString,'" ',GetObjName(AContext.Resolver));
      end;
    pekNumber:
      begin
      case El.Value[1] of
      '0'..'9':
        begin
        Val(El.Value,Number,ConversionError);
        if ConversionError<>0 then
          DoError(20161024191248,nInvalidNumber,sInvalidNumber,[El.Value],El);
        L:=CreateLiteralNumber(El,Number);
        L.Value.CustomValue:=TJSString(El.Value);
        end;
      '$','&','%':
        begin
          i:=StrToInt64Def(El.Value,-1);
          if i<0 then
            DoError(20161024224442,nInvalidNumber,sInvalidNumber,[El.Value],El);
          Number:=i;
          if Number<>i then
            // number was rounded -> we lost precision
            DoError(20161024230812,nInvalidNumber,sInvalidNumber,[El.Value],El);
          L:=CreateLiteralNumber(El,Number);
          S:=copy(El.Value,2,length(El.Value));
          case El.Value[1] of
          '$': S:='0x'+S;
          '&': if TargetProcessor=ProcessorECMAScript5 then
                 S:='0'+S
               else
                 S:='0o'+S;
          '%': if TargetProcessor=ProcessorECMAScript5 then
                 S:=''
               else
                 S:='0b'+S;
          end;
          L.Value.CustomValue:=TJSString(S);
        end;
      else
        DoError(20161024223232,nInvalidNumber,sInvalidNumber,[El.Value],El);
      end;
      Result:=L;
      end;
    pekIdent:
      Result:=ConvertIdentifierExpr(El,El.Value,AContext);
    else
      RaiseNotSupported(El,AContext,20161024222543);
  end;
end;

function TPasToJSConverter.ConvertIdentifierExpr(El: TPasExpr;
  const aName: string; AContext: TConvertContext): TJSElement;

  function IsClassSelf(Decl: TPasElement): boolean;
  begin
    if (Decl.ClassType<>TPasClassType) or (CompareText(aName,'Self')<>0) then
      exit(false);
    Result:=AContext.GetSelfContext<>nil;
  end;

  procedure CallImplicit(Decl: TPasElement);
  var
    ProcType: TPasProcedureType;
    ResolvedEl: TPasResolverResult;
    Call: TJSCallExpression;
  begin
    // create a call with default parameters
    ProcType:=nil;
    if Decl is TPasProcedure then
      ProcType:=TPasProcedure(Decl).ProcType
    else
      begin
      AContext.Resolver.ComputeElement(El,ResolvedEl,[rcNoImplicitProc]);
      if ResolvedEl.TypeEl is TPasProcedureType then
        ProcType:=TPasProcedureType(ResolvedEl.TypeEl)
      else
        RaiseNotSupported(El,AContext,20170217005025);
      end;

    Call:=nil;
    try
      CreateProcedureCall(Call,nil,ProcType,AContext);
      Call.Expr:=Result;
      Result:=Call;
    finally
      if Result<>Call then
        Call.Free;
    end;
  end;

var
  Decl: TPasElement;
  Name: String;
  Ref: TResolvedReference;
  Call: TJSCallExpression;
  BuiltInProc: TResElDataBuiltInProc;
  Prop: TPasProperty;
  IsImplicitCall: Boolean;
  AssignContext: TAssignContext;
  TargetProcType: TPasProcedureType;
  ArrLit: TJSArrayLiteral;
  IndexExpr: TPasExpr;
  Func: TPasFunction;
  FuncScope: TPas2JSProcedureScope;
  Value: TResEvalValue;
begin
  Result:=nil;
  if not (El.CustomData is TResolvedReference) then
    begin
    if AContext.Resolver<>nil then
      RaiseIdentifierNotFound(aName,El,20161024191306)
    else
      // simple mode
      Result:=CreateIdentifierExpr(aName,El,AContext);
    exit;
    end;

  Ref:=TResolvedReference(El.CustomData);
  Decl:=Ref.Declaration;

  if IsExternalClassConstructor(Decl) then
    begin
    // create external object/function
    Result:=ConvertExternalConstructor(nil,Ref,nil,AContext);
    exit;
    end;

  if [rrfNewInstance,rrfFreeInstance]*Ref.Flags<>[] then
    begin
    // call constructor, destructor
    Call:=CreateFreeOrNewInstanceExpr(Ref,AContext);
    Result:=Call;
    if Decl is TPasProcedure then
      begin
      TargetProcType:=TPasProcedure(Decl).ProcType;
      if TargetProcType.Args.Count>0 then
        begin
        // add default parameters:
        // insert array parameter [], e.g. this.TObject.$create("create",[])
        ArrLit:=TJSArrayLiteral(CreateElement(TJSArrayLiteral,El));
        CreateProcedureCallArgs(ArrLit.Elements,nil,TargetProcType,AContext);
        Call.Args.Elements.AddElement.Expr:=ArrLit;
        end;
      end;
    exit;
    end;

  if (Ref.WithExprScope<>nil) and AContext.Resolver.IsTObjectFreeMethod(El) then
    begin
    Result:=ConvertTObjectFree(nil,El,AContext);
    exit;
    end;

  Prop:=nil;
  AssignContext:=nil;
  IsImplicitCall:=rrfImplicitCallWithoutParams in Ref.Flags;

  if Decl.ClassType=TPasProperty then
    begin
    // Decl is a property -> redirect to getter/setter
    Prop:=TPasProperty(Decl);
    case AContext.Access of
      caAssign:
        begin
        Decl:=AContext.Resolver.GetPasPropertySetter(Prop);
        if Decl is TPasProcedure then
          begin
          AssignContext:=AContext.AccessContext as TAssignContext;
          if AssignContext.Call<>nil then
            RaiseNotSupported(El,AContext,20170206000310);
          AssignContext.PropertyEl:=Prop;
          AssignContext.Setter:=Decl;
          // Setter
          Call:=CreateCallExpression(El);
          AssignContext.Call:=Call;
          Call.Expr:=CreateReferencePathExpr(Decl,AContext,false,Ref);
          IndexExpr:=AContext.Resolver.GetPasPropertyIndex(Prop);
          if IndexExpr<>nil then
            begin
            Value:=AContext.Resolver.Eval(IndexExpr,[refConst]);
            try
              Call.AddArg(ConvertConstValue(Value,AssignContext,El));
            finally
              ReleaseEvalValue(Value);
            end;
            end;
          Call.AddArg(AssignContext.RightSide);
          AssignContext.RightSide:=nil;
          Result:=Call;
          exit;
          end;
        end;
      caRead:
        begin
        Result:=CreatePropertyGet(Prop,Ref,AContext,El);
        if Result is TJSCallExpression then exit;
        if not IsImplicitCall then exit;
        end;
      else
        RaiseNotSupported(El,AContext,20170213212623);
    end;
    end
  else if Decl.ClassType=TPasArgument then
    begin
    Result:=CreateArgumentAccess(TPasArgument(Decl),AContext,El);
    if IsImplicitCall then
      CallImplicit(Decl);
    exit;
    end
  else if Decl.ClassType=TPasConst then
    begin
    if TPasConst(Decl).IsConst and (TPasConst(Decl).Expr<>nil) then
      begin
      Value:=AContext.Resolver.Eval(TPasConst(Decl).Expr,[refConst]);
      if (Value<>nil)
          and (Value.Kind in [revkNil,revkBool,revkInt,revkUInt,revkFloat,revkEnum]) then
        try
          Result:=ConvertConstValue(Value,AContext,El);
          exit;
        finally
          ReleaseEvalValue(Value);
        end;
      if vmExternal in TPasConst(Decl).VarModifiers then
        begin
        // external constant are always added by value, not by reference
        Result:=ConvertElement(TPasConst(Decl).Expr,AContext);
        exit;
        end;
      end;
    end
  else if Decl.ClassType=TPasResString then
    begin
    // read resourcestring -> rtl.getResStr($mod,"name")
    Call:=CreateCallExpression(El);
    Result:=Call;
    Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnGetResourcestring]]);
    Call.AddArg(CreatePrimitiveDotExpr(TransformModuleName(Decl.GetModule,true,AContext),El));
    Call.AddArg(CreateLiteralString(El,TransformVariableName(Decl,AContext)));
    exit;
    end
  else if Decl.CustomData is TResElDataBuiltInProc then
    begin
    BuiltInProc:=TResElDataBuiltInProc(Decl.CustomData);
    {$IFDEF VerbosePas2JS}
    writeln('TPasToJSConverter.ConvertPrimitiveExpression ',Decl.Name,' ',ResolverBuiltInProcNames[BuiltInProc.BuiltIn]);
    {$ENDIF}
    case BuiltInProc.BuiltIn of
      bfBreak: Result:=ConvertBuiltInBreak(El,AContext);
      bfContinue: Result:=ConvertBuiltInContinue(El,AContext);
      bfExit: Result:=ConvertBuiltIn_Exit(El,AContext);
    else
      RaiseNotSupported(El,AContext,20161130164955,'built in proc '+ResolverBuiltInProcNames[BuiltInProc.BuiltIn]);
    end;
    if Result=nil then
      RaiseInconsistency(20170214120048,Decl);
    exit;
    end;

  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.ConvertIdentifierExpr ',GetObjName(El),' Decl=',GetObjName(Decl),' Decl.Parent=',GetObjName(Decl.Parent));
  //if CompareText(aName,'Result')=0 then
  //  begin
  //  writeln('TPasToJSConverter.ConvertIdentifierExpr AContext=',GetObjName(AContext),' SelfContext=',GetObjName(AContext.GetSelfContext),' LocalVar=',AContext.GetLocalName(Decl),' ',GetObjName(Decl));
  //  AContext.WriteStack;
  //  end;
  {$ENDIF}

  if Decl is TPasModule then
    Name:=TransformModuleName(TPasModule(Decl),true,AContext)
  else if (Decl is TPasResultElement) then
    begin
    Name:=ResolverResultVar;
    Func:=Decl.Parent.Parent as TPasFunction;
    FuncScope:=Func.CustomData as TPas2JSProcedureScope;
    if FuncScope.ImplProc<>nil then
      FuncScope:=FuncScope.ImplProc.CustomData as TPas2JSProcedureScope;
    if FuncScope.ResultVarName<>'' then
      Name:=FuncScope.ResultVarName;
    end
  else if Decl.ClassType=TPasEnumValue then
    begin
    if UseEnumNumbers then
      begin
      Result:=CreateLiteralNumber(El,(Decl.Parent as TPasEnumType).Values.IndexOf(Decl));
      exit;
      end
    else
      begin
      // enums always need the full path
      Name:=CreateReferencePath(Decl,AContext,rpkPathAndName,true);
      end;
    end
  else if (CompareText(aName,'Self')=0) and (AContext.GetSelfContext<>nil) then
    Name:=AContext.GetLocalName(Decl)
  else
    Name:=CreateReferencePath(Decl,AContext,rpkPathAndName,false,Ref);
  if Result=nil then
    Result:=CreatePrimitiveDotExpr(Name,El);

  if IsImplicitCall then
    CallImplicit(Decl);
end;

function TPasToJSConverter.ConvertBoolConstExpression(El: TBoolConstExpr;
  AContext: TConvertContext): TJSElement;

begin
  if AContext=nil then ;
  Result:=CreateLiteralBoolean(El,El.Value);
end;

function TPasToJSConverter.ConvertNilExpr(El: TNilExpr;
  AContext: TConvertContext): TJSElement;
begin
  if AContext=nil then ;
  Result:=CreateLiteralNull(El);
end;

function TPasToJSConverter.ConvertInheritedExpression(El: TInheritedExpr;
  AContext: TConvertContext): TJSElement;

  function CreateAncestorCall(ParentEl: TPasElement; Apply: boolean;
    AncestorProc: TPasProcedure; ParamsExpr: TParamsExpr): TJSElement;
  var
    FunName, SelfName: String;
    Call: TJSCallExpression;
    SelfContext: TFunctionContext;
    ClassScope, AncestorScope: TPasClassScope;
    AncestorClass, aClass: TPasClassType;
  begin
    Result:=nil;
    SelfContext:=AContext.GetSelfContext;
    if SelfContext=nil then
      RaiseInconsistency(20170418114702,El);
    SelfName:=SelfContext.GetLocalName(SelfContext.ThisPas);

    if Apply and (SelfContext<>AContext) then
      DoError(20170418204325,nNestedInheritedNeedsParameters,sNestedInheritedNeedsParameters,
        [],El);

    if (AncestorProc.Parent is TPasClassType)
        and TPasClassType(AncestorProc.Parent).IsExternal then
      begin
      // ancestor is in an external class
      // They could be overriden, without a Pascal declaration
      // -> use the direct ancestor class of the current proc
      aClass:=SelfContext.ThisPas as TPasClassType;
      if aClass.CustomData=nil then
        RaiseInconsistency(20170323111252,aClass);
      ClassScope:=TPasClassScope(aClass.CustomData);
      AncestorScope:=ClassScope.AncestorScope;
      if AncestorScope=nil then
        RaiseInconsistency(20170323111306,aClass);
      AncestorClass:=AncestorScope.Element as TPasClassType;
      FunName:=CreateReferencePath(AncestorClass,AContext,rpkPathAndName,true)
        +'.'+TransformVariableName(AncestorProc,AContext);
      end
    else
      FunName:=CreateReferencePath(AncestorProc,AContext,rpkPathAndName,true);
    if Apply and (SelfContext=AContext) then
      // create "ancestor.funcname.apply(this,arguments)"
      FunName:=FunName+'.apply'
    else
      // create "ancestor.funcname.call(this,param1,param2,...)"
      FunName:=FunName+'.call';
    Call:=nil;
    try
      Call:=CreateCallExpression(ParentEl);
      Call.Expr:=CreatePrimitiveDotExpr(FunName,ParentEl);
      Call.AddArg(CreatePrimitiveDotExpr(SelfName,ParentEl));
      if Apply then
        // "inherited;" -> pass the arguments
        Call.AddArg(CreatePrimitiveDotExpr('arguments',ParentEl))
      else
        // "inherited Name(...)" -> pass the user arguments
        CreateProcedureCall(Call,ParamsExpr,AncestorProc.ProcType,AContext);
      Result:=Call;
    finally
      if Result=nil then
        Call.Free;
    end;
  end;

var
  Right: TPasExpr;
  Ref: TResolvedReference;
  PrimExpr: TPrimitiveExpr;
  AncestorProc: TPasProcedure;
  ParamsExpr: TParamsExpr;
begin
  Result:=nil;
  if (El.Parent is TBinaryExpr) and (TBinaryExpr(El.Parent).OpCode=eopNone)
      and (TBinaryExpr(El.Parent).left=El) then
    begin
    // "inherited <name>"
    AncestorProc:=nil;
    ParamsExpr:=nil;
    Right:=TBinaryExpr(El.Parent).right;
    if Right.ClassType=TPrimitiveExpr then
      begin
      PrimExpr:=TPrimitiveExpr(Right);
      Ref:=PrimExpr.CustomData as TResolvedReference;
      if rrfImplicitCallWithoutParams in Ref.Flags then
        begin
        // inherited <function>
        // -> create "AncestorProc.call(this,defaultargs)"
        AncestorProc:=Ref.Declaration as TPasProcedure;
        end
      else
        begin
        // inherited <varname>
        // all variables have unique names -> simply access it
        Result:=ConvertPrimitiveExpression(PrimExpr,AContext);
        exit;
        end;
      end
    else if Right.ClassType=TParamsExpr then
      begin
      ParamsExpr:=TParamsExpr(Right);
      if ParamsExpr.Kind=pekFuncParams then
        begin
        if ParamsExpr.Value is TPrimitiveExpr then
          begin
          // inherited <function>(args)
          // -> create "AncestorProc.call(this,args,defaultargs)"
          PrimExpr:=TPrimitiveExpr(ParamsExpr.Value);
          Ref:=PrimExpr.CustomData as TResolvedReference;
          AncestorProc:=Ref.Declaration as TPasProcedure;
          end
        else
          DoError(20170418205802,nXExpectedButYFound,sXExpectedButYFound,
            ['inherited name()',ParamsExpr.Value.ElementTypeName],ParamsExpr.Value);
        end
      else
        begin
        // inherited <varname>[]
        // all variables have unique names -> simply access it
        Result:=ConvertElement(Right,AContext);
        exit;
        end;
      end
    else
      begin
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.ConvertInheritedExpression Parent=',GetTreeDbg(El.Parent,2));
      {$ENDIF}
      DoError(20170418205955,nXExpectedButYFound,sXExpectedButYFound,
        ['inherited name()',Right.ElementTypeName],Right);
      end;
    if AncestorProc=nil then
      begin
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.ConvertInheritedExpression Right=',GetObjName(Right));
      {$ENDIF}
      RaiseNotSupported(El,AContext,20170201190824);
      end;
    //writeln('TPasToJSConverter.ConvertInheritedExpression Func=',GetObjName(FuncContext.PasElement));
    Result:=CreateAncestorCall(Right,false,AncestorProc,ParamsExpr);
    end
  else
    begin
    // "inherited;"
    if El.CustomData=nil then
      exit; // "inherited;" when there is no AncestorProc proc -> silently ignore
    // create "AncestorProc.apply(this,arguments)"
    Ref:=TResolvedReference(El.CustomData);
    AncestorProc:=Ref.Declaration as TPasProcedure;
    Result:=CreateAncestorCall(El,true,AncestorProc,nil);
    end;
end;

function TPasToJSConverter.ConvertSelfExpression(El: TSelfExpr;
  AContext: TConvertContext): TJSElement;
begin
  Result:=ConvertIdentifierExpr(El,'Self',AContext);
end;

function TPasToJSConverter.ConvertParamsExpression(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
begin
  Result:=Nil;
  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.ConvertParamsExpression ',GetObjName(El),' El.Kind=',ExprKindNames[El.Kind]);
  {$ENDIF}
  Case El.Kind of
    pekFuncParams:
      Result:=ConvertFuncParams(El,AContext);
    pekArrayParams:
      Result:=ConvertArrayParams(El,AContext);
    pekSet:
      Result:=ConvertSetLiteral(El,AContext);
  else
    RaiseNotSupported(El,AContext,20170209103235,ExprKindNames[El.Kind]);
  end;
end;

function TPasToJSConverter.ConvertArrayParams(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
var
  ArgContext: TConvertContext;

  function GetValueReference: TResolvedReference;
  var
    Value: TPasExpr;
  begin
    Result:=nil;
    Value:=El.Value;
    if (Value.ClassType=TPrimitiveExpr)
        and (Value.CustomData is TResolvedReference) then
      exit(TResolvedReference(Value.CustomData));
  end;

  function ConvertIndexMinus1(Param: TPasExpr): TJSElement;
  var
    NeedMinus1: Boolean;
    JSVal: TJSValue;
    MinusJS: TJSAdditiveExpressionMinus;
  begin
    Result:=ConvertElement(Param,ArgContext);
    NeedMinus1:=true;
    if (Result is TJSLiteral) then
      begin
      JSVal:=TJSLiteral(Result).Value;
      if (JSVal.ValueType=jstNumber) then
        begin
        // simply subtract 1 from constant
        JSVal.AsNumber:=JSVal.AsNumber-1;
        NeedMinus1:=false;
        end;
      end;
    if NeedMinus1 then
      begin
      // index-1
      MinusJS:=TJSAdditiveExpressionMinus(CreateElement(TJSAdditiveExpressionMinus,Param));
      MinusJS.A:=Result;
      MinusJS.B:=CreateLiteralNumber(Param,1);
      Result:=MinusJS;
      end;
  end;

  procedure ConvertStringBracket(const ResolvedValue: TPasResolverResult);
  var
    NewValue, SetStrCall: TJSCallExpression;
    Param: TPasExpr;
    DotExpr: TJSDotMemberExpression;
    AssignContext: TAssignContext;
    Elements: TJSArrayLiteralElements;
    AssignSt: TJSSimpleAssignStatement;
    OldAccess: TCtxAccess;
    IndexExpr: TJSElement;
    Arg: TPasArgument;
  begin
    Result:=nil;
    Param:=El.Params[0];
    case AContext.Access of
    caAssign:
      begin
      // s[index] := value
      AssignContext:=AContext.AccessContext as TAssignContext;
      if AssignContext.RightSide=nil then
        RaiseInconsistency(20180123192020,El);

      AssignSt:=nil;
      SetStrCall:=nil;
      NewValue:=nil;
      try
        // NewValue: rtl.setCharAt(s,index,value)

        // rtl.setCharAt
        NewValue:=CreateCallExpression(El);
        NewValue.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnSetCharAt]]);
        // first param  s
        OldAccess:=AContext.Access;
        AContext.Access:=caRead;
        NewValue.AddArg(ConvertElement(El.Value,AContext));
        // second param  index-1
        NewValue.AddArg(ConvertIndexMinus1(Param));
        AContext.Access:=OldAccess;
        // third param  value
        NewValue.AddArg(AssignContext.RightSide);
        AssignContext.RightSide:=nil;

        if ResolvedValue.IdentEl is TPasArgument then
          begin
          Arg:=TPasArgument(ResolvedValue.IdentEl);
          if Arg.Access in [argVar,argOut] then
            begin
            // call by reference
            // s[index] := value  ->  s.set(NewValue)
            SetStrCall:=CreateCallExpression(El.Value);
            SetStrCall.Expr:=CreateMemberExpression([TransformVariableName(Arg,AContext),TempRefObjSetterName]);
            SetStrCall.AddArg(NewValue);
            AssignContext.Call:=NewValue;
            NewValue:=nil;
            Result:=SetStrCall;
            end;
          end
        else if ResolvedValue.IdentEl is TPasProperty then
          RaiseNotSupported(El,AContext,20180124115924);
        if Result=nil then
          begin
          // s[index] := value  ->  s = NewValue
          AssignSt:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,El));
          AssignSt.Expr:=NewValue;
          AssignContext.Call:=NewValue;
          NewValue:=nil;
          OldAccess:=AContext.Access;
          AContext.Access:=caRead;
          AssignSt.LHS:=ConvertElement(El.Value,AContext);
          Result:=AssignSt;
          end;
      finally
        if Result=nil then
          begin
          NewValue.Free;
          SetStrCall.Free;
          AssignSt.Free;
          end;
      end;
      end;
    caRead:
      begin
      NewValue:=CreateCallExpression(El);
      Elements:=NewValue.Args.Elements;
      try
        // s[index]  ->  s.charAt(index-1)
        // add string accessor
        DotExpr:=TJSDotMemberExpression(CreateElement(TJSDotMemberExpression,El));
        NewValue.Expr:=DotExpr;
        DotExpr.MExpr:=ConvertElement(El.Value,AContext);
        DotExpr.Name:='charAt';

        // add parameter "index-1"
        IndexExpr:=ConvertIndexMinus1(Param);
        Elements.AddElement.Expr:=IndexExpr;
        Result:=NewValue;
      finally
        if Result=nil then
          NewValue.Free;
      end;
      end;
    else
      RaiseNotSupported(El,AContext,20170213213101);
    end;
  end;

  procedure ConvertArray(ArrayEl: TPasArrayType);
  var
    B, Sub: TJSBracketMemberExpression;
    i, ArgNo: Integer;
    Arg: TJSElement;
    OldAccess: TCtxAccess;
    Ranges: TPasExprArray;
    Int: MaxPrecInt;
    Param: TPasExpr;
    JSAdd: TJSAdditiveExpression;
    LowRg: TResEvalValue;
    JSUnaryPlus: TJSUnaryPlusExpression;
    w: WideChar;
  begin
    Arg:=nil;
    B:=TJSBracketMemberExpression(CreateElement(TJSBracketMemberExpression,El));
    try
      // add read accessor
      OldAccess:=AContext.Access;
      AContext.Access:=caRead;
      B.MExpr:=ConvertElement(El.Value,AContext);
      AContext.Access:=OldAccess;

      Result:=B;
      ArgNo:=0;
      repeat
        // Note: dynamic array has length(ArrayEl.Ranges)=0
        Ranges:=ArrayEl.Ranges;
        for i:=1 to Max(length(Ranges),1) do
          begin
          // add parameter
          Param:=El.Params[ArgNo];
          ArgContext.Access:=caRead;
          Arg:=ConvertElement(Param,ArgContext);
          ArgContext.Access:=OldAccess;

          if i<=length(Ranges) then
            begin
            // static array
            LowRg:=ArgContext.Resolver.EvalRangeLimit(Ranges[i-1],[refConst],true,El);
            if LowRg=nil then
              RaiseNotSupported(Param,ArgContext,20170910163341);
            Int:=0;
            case LowRg.Kind of
            revkBool:
              if TResEvalBool(LowRg).B=false then
                begin
                // array starts at 'false'
                if (Arg is TJSLiteral) and (TJSLiteral(Arg).Value.ValueType=jstBoolean) then
                  begin
                  // convert Pascal boolean literal to JS number
                  if TJSLiteral(Arg).Value.AsBoolean then
                    TJSLiteral(Arg).Value.AsNumber:=1
                  else
                    TJSLiteral(Arg).Value.AsNumber:=0;
                  end
                else
                  begin
                  // -> convert bool to int with unary plus:  +bool
                  JSUnaryPlus:=TJSUnaryPlusExpression(CreateElement(TJSUnaryPlusExpression,Param));
                  JSUnaryPlus.A:=Arg;
                  Arg:=JSUnaryPlus;
                  end;
                end
              else
                begin
                // array starts at 'true'
                if (Arg is TJSLiteral) and (TJSLiteral(Arg).Value.ValueType=jstBoolean) then
                  begin
                  if TJSLiteral(Arg).Value.AsBoolean then
                    TJSLiteral(Arg).Value.AsNumber:=0
                  else
                    ArgContext.Resolver.ExprEvaluator.EmitRangeCheckConst(
                      20170910203312,'false','true','true',Param,mtError);
                  end
                else
                  begin
                  // convert bool to int with offset: 1-bool
                  JSAdd:=TJSAdditiveExpressionMinus(CreateElement(TJSAdditiveExpressionMinus,Param));
                  JSAdd.A:=CreateLiteralNumber(Param,1);
                  JSAdd.B:=Arg;
                  Arg:=JSAdd;
                  end;
                end;
            revkEnum:
              Int:=TResEvalEnum(LowRg).Index;
            revkInt:
              Int:=TResEvalInt(LowRg).Int;
            revkString:
              begin
              if length(TResEvalString(LowRg).S)<>1 then
                begin
                if ArgContext.Resolver.ExprEvaluator.GetWideChar(TResEvalString(LowRg).S,w) then
                  Int:=ord(w)
                else
                  ArgContext.Resolver.RaiseXExpectedButYFound(20170910213203,'char','string',Param);
                end
              else
                Int:=ord(TResEvalString(LowRg).S[1]);
              if (Arg is TJSLiteral) and (TJSLiteral(Arg).Value.ValueType=jstString) then
                begin
                // convert char literal to int
                ConvertCharLiteralToInt(TJSLiteral(Arg),Param,ArgContext);
                end
              else
                begin
                // convert char to int  ->  Arg.charCodeAt(0)
                Arg:=CreateCallCharCodeAt(Arg,0,Param);
                end;
              end;
            revkUnicodeString:
              if length(TResEvalUTF16(LowRg).S)<>1 then
                ArgContext.Resolver.RaiseXExpectedButYFound(20170910213247,'char','string',Param)
              else
                Int:=ord(TResEvalUTF16(LowRg).S[1]);
            else
              ReleaseEvalValue(LowRg);
              RaiseNotSupported(Param,ArgContext,20170910170446);
            end;
            if Int<>0 then
              begin
              if (Arg is TJSLiteral) and (TJSLiteral(Arg).Value.ValueType=jstNumber) then
                // parameter is single number -> simply subtract the offset
                TJSLiteral(Arg).Value.AsNumber:=TJSLiteral(Arg).Value.AsNumber-Int
              else
                begin
                // parameter is an expression -> add offset
                if Int>0 then
                  begin
                  // Arg-Offset
                  JSAdd:=TJSAdditiveExpressionMinus(CreateElement(TJSAdditiveExpressionMinus,Param));
                  JSAdd.A:=Arg;
                  JSAdd.B:=CreateLiteralNumber(Param,Int);
                  Arg:=JSAdd;
                  end
                else
                  begin
                  // Arg+Offset
                  JSAdd:=TJSAdditiveExpressionPlus(CreateElement(TJSAdditiveExpressionPlus,Param));
                  JSAdd.A:=Arg;
                  JSAdd.B:=CreateLiteralNumber(Param,-Int);
                  Arg:=JSAdd;
                  end;
                end;
              end;
            ReleaseEvalValue(LowRg);
            end;

          if B.Name<>nil then
            begin
            // nested [][]
            Sub:=B;
            B:=TJSBracketMemberExpression(CreateElement(TJSBracketMemberExpression,El));
            B.MExpr:=Sub;
            end;
          B.Name:=Arg;
          Arg:=nil;
          inc(ArgNo);
          if ArgNo>length(El.Params) then
            RaiseInconsistency(20170206180553,El);
          end;
        if ArgNo=length(El.Params) then
          break;
        // continue in sub array
        ArrayEl:=AContext.Resolver.ResolveAliasType(ArrayEl.ElType) as TPasArrayType;
      until false;
      Result:=B;
    finally
      if Result=nil then
        begin
        Arg.Free;
        B.Free;
        end;
    end;
  end;

  procedure ConvertJSObject;
  var
    B: TJSBracketMemberExpression;
    OldAccess: TCtxAccess;
  begin
    B:=TJSBracketMemberExpression(CreateElement(TJSBracketMemberExpression,El));
    try
      // add read accessor
      OldAccess:=AContext.Access;
      AContext.Access:=caRead;
      B.MExpr:=ConvertElement(El.Value,AContext);
      AContext.Access:=OldAccess;

      // add parameter
      ArgContext.Access:=caRead;
      B.Name:=ConvertElement(El.Params[0],ArgContext);
      ArgContext.Access:=OldAccess;

      Result:=B;
    finally
      if Result=nil then
        B.Free;
    end;
  end;

  function IsJSBracketAccessorAndConvert(Prop: TPasProperty;
    AccessEl: TPasElement;
    AContext: TConvertContext; ChompPropName: boolean): boolean;
  // If El.Value contains property name set ChompPropName = true
  var
    Bracket: TJSBracketMemberExpression;
    OldAccess: TCtxAccess;
    PathEl: TPasExpr;
    Ref: TResolvedReference;
    Path: String;
  begin
    if not AContext.Resolver.IsExternalBracketAccessor(AccessEl) then
      exit(false);
    Result:=true;
    // bracket accessor of external class
    if AContext.Resolver.GetPasPropertyArgs(Prop).Count<>1 then
      RaiseInconsistency(20170403003753,Prop);
    // bracket accessor of external class  -> create  PathEl[param]
    Bracket:=TJSBracketMemberExpression(CreateElement(TJSBracketMemberExpression,El.Params[0]));
    try
      PathEl:=El.Value;
      if ChompPropName then
        begin
        if (PathEl is TPrimitiveExpr)
            and (TPrimitiveExpr(PathEl).Kind=pekIdent)
            and (PathEl.CustomData is TResolvedReference) then
          begin
          // propname without path, e.g.  propname[param]
          Ref:=TResolvedReference(PathEl.CustomData);
          Path:=CreateReferencePath(Prop,AContext,rpkPath,false,Ref);
          if Path<>'' then
            Bracket.MExpr:=CreatePrimitiveDotExpr(Path,PathEl);
          PathEl:=nil;
          end
        else if (PathEl is TBinaryExpr)
            and (TBinaryExpr(PathEl).OpCode=eopSubIdent)
            and (TBinaryExpr(PathEl).right is TPrimitiveExpr)
            and (TPrimitiveExpr(TBinaryExpr(PathEl).right).Kind=pekIdent) then
          begin
          // instance.propname[param]  ->  instance[param]
          PathEl:=TBinaryExpr(PathEl).left;
          end
        else
          RaiseNotSupported(El.Value,AContext,20170402225050);
        end;

      if (PathEl<>nil) and (Bracket.MExpr=nil) then
        begin
        OldAccess:=AContext.Access;
        AContext.Access:=caRead;
        Bracket.MExpr:=ConvertElement(PathEl,AContext);
        AContext.Access:=OldAccess;
        end;

      OldAccess:=ArgContext.Access;
      ArgContext.Access:=caRead;
      Bracket.Name:=ConvertElement(El.Params[0],ArgContext);
      ArgContext.Access:=OldAccess;
      ConvertArrayParams:=Bracket;
      Bracket:=nil;
    finally
      Bracket.Free;
    end;
  end;

  procedure ConvertIndexedProperty(Prop: TPasProperty; AContext: TConvertContext);
  var
    Call: TJSCallExpression;
    i: Integer;
    TargetArg: TPasArgument;
    Elements: TJSArrayLiteralElements;
    Arg: TJSElement;
    AccessEl: TPasElement;
    AssignContext: TAssignContext;
    OldAccess: TCtxAccess;
    IndexExpr: TPasExpr;
    Value: TResEvalValue;
    PropArgs: TFPList;
  begin
    Result:=nil;
    AssignContext:=nil;
    Call:=CreateCallExpression(El);
    try
      case AContext.Access of
      caAssign:
        begin
        AccessEl:=AContext.Resolver.GetPasPropertySetter(Prop);
        if IsJSBracketAccessorAndConvert(Prop,AccessEl,AContext,true) then
            exit;
        AssignContext:=AContext.AccessContext as TAssignContext;
        AssignContext.PropertyEl:=Prop;
        AssignContext.Setter:=AccessEl;
        AssignContext.Call:=Call;
        end;
      caRead:
        begin
        AccessEl:=AContext.Resolver.GetPasPropertyGetter(Prop);
        if IsJSBracketAccessorAndConvert(Prop,AccessEl,AContext,true) then
          exit;
        end
      else
        RaiseNotSupported(El,AContext,20170213213317);
      end;
      Call.Expr:=CreateReferencePathExpr(AccessEl,AContext,false,GetValueReference);

      Elements:=Call.Args.Elements;
      OldAccess:=ArgContext.Access;
      // add params
      PropArgs:=AContext.Resolver.GetPasPropertyArgs(Prop);
      i:=0;
      while i<PropArgs.Count do
        begin
        TargetArg:=TPasArgument(PropArgs[i]);
        Arg:=CreateProcCallArg(El.Params[i],TargetArg,ArgContext);
        Elements.AddElement.Expr:=Arg;
        inc(i);
        end;
      // fill up default values
      while i<PropArgs.Count do
        begin
        TargetArg:=TPasArgument(PropArgs[i]);
        if TargetArg.ValueExpr=nil then
          begin
          {$IFDEF VerbosePas2JS}
          writeln('TPasToJSConverter.ConvertArrayParams.ConvertIndexedProperty missing default value: Prop=',Prop.Name,' i=',i);
          {$ENDIF}
          RaiseInconsistency(20170206185126,TargetArg);
          end;
        AContext.Access:=caRead;
        Arg:=ConvertElement(TargetArg.ValueExpr,ArgContext);
        Elements.AddElement.Expr:=Arg;
        inc(i);
        end;
      // add index specifier
      IndexExpr:=AContext.Resolver.GetPasPropertyIndex(Prop);
      if IndexExpr<>nil then
        begin
        Value:=AContext.Resolver.Eval(IndexExpr,[refConst]);
        try
          Elements.AddElement.Expr:=ConvertConstValue(Value,ArgContext,El);
        finally
          ReleaseEvalValue(Value);
        end;
        end;
      // finally add as last parameter the value
      if AssignContext<>nil then
        begin
        Elements.AddElement.Expr:=AssignContext.RightSide;
        AssignContext.RightSide:=nil;
        end;

      ArgContext.Access:=OldAccess;
      Result:=Call;
    finally
      if Result=nil then
        begin
        if (AssignContext<>nil) and (AssignContext.Call=Call) then
          AssignContext.Call:=nil;
        Call.Free;
        end;
    end;
  end;

  procedure ConvertDefaultProperty(const ResolvedEl: TPasResolverResult;
    Prop: TPasProperty);
  var
    DotContext: TDotContext;
    Left, Right: TJSElement;
    OldAccess: TCtxAccess;
    AccessEl, SetAccessEl: TPasElement;
  begin
    case AContext.Access of
    caAssign:
      begin
      AccessEl:=AContext.Resolver.GetPasPropertySetter(Prop);
      if IsJSBracketAccessorAndConvert(Prop,AccessEl,AContext,false) then
        exit;
      end;
    caRead:
      begin
      AccessEl:=AContext.Resolver.GetPasPropertyGetter(Prop);
      if IsJSBracketAccessorAndConvert(Prop,AccessEl,AContext,false) then
        exit;
      end;
    caByReference:
      begin
      //ParamContext:=AContext.AccessContext as TParamContext;
      AccessEl:=AContext.Resolver.GetPasPropertyGetter(Prop);
      SetAccessEl:=AContext.Resolver.GetPasPropertySetter(Prop);
      if AContext.Resolver.IsExternalBracketAccessor(AccessEl) then
        begin
        if AContext.Resolver.IsExternalBracketAccessor(SetAccessEl) then
          begin
          // read and write are brackets -> easy
          if not IsJSBracketAccessorAndConvert(Prop,AccessEl,AContext,false) then
            RaiseNotSupported(El,AContext,20170405090845);
          exit;
          end;
        end;
      RaiseNotSupported(El,AContext,20170403000550);
      end;
    else
      RaiseNotSupported(El,AContext,20170402233834);
    end;

    DotContext:=nil;
    Left:=nil;
    Right:=nil;
    try
      OldAccess:=AContext.Access;
      AContext.Access:=caRead;
      Left:=ConvertElement(El.Value,AContext);
      AContext.Access:=OldAccess;

      DotContext:=TDotContext.Create(El.Value,Left,AContext);
      DotContext.LeftResolved:=ResolvedEl;
      ConvertIndexedProperty(Prop,DotContext);
      Right:=Result;
      Result:=nil;
    finally
      DotContext.Free;
      if Right=nil then
        Left.Free;
    end;
    Result:=CreateDotExpression(El,Left,Right);
  end;

Var
  ResolvedEl: TPasResolverResult;
  TypeEl, DestType: TPasType;
  ClassScope: TPas2JSClassScope;
  B: TJSBracketMemberExpression;
  OldAccess: TCtxAccess;
  aClass: TPasClassType;
begin
  if El.Kind<>pekArrayParams then
    RaiseInconsistency(20170209113713,El);
  ArgContext:=AContext;
  while ArgContext is TDotContext do
    ArgContext:=ArgContext.Parent;
  if AContext.Resolver=nil then
    begin
    // without Resolver
    if Length(El.Params)>1 then
      RaiseNotSupported(El,AContext,20170207151325,'Cannot convert 2-dim arrays');
    B:=TJSBracketMemberExpression(CreateElement(TJSBracketMemberExpression,El));
    try
      // add reference
      OldAccess:=AContext.Access;
      AContext.Access:=caRead;
      B.MExpr:=ConvertElement(El.Value,AContext);

      // add parameter
      OldAccess:=ArgContext.Access;
      ArgContext.Access:=caRead;
      B.Name:=ConvertElement(El.Params[0],ArgContext);
      ArgContext.Access:=OldAccess;

      Result:=B;
    finally
      if Result=nil then
        B.Free;
    end;
    exit;
    end;
  // has Resolver
  AContext.Resolver.ComputeElement(El.Value,ResolvedEl,[]);
  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.ConvertArrayParams Value=',GetResolverResultDbg(ResolvedEl));
  {$ENDIF}
  if ResolvedEl.BaseType in btAllJSStrings then
    // astring[]
    ConvertStringBracket(ResolvedEl)
  else if (ResolvedEl.IdentEl is TPasProperty)
      and (AContext.Resolver.GetPasPropertyArgs(TPasProperty(ResolvedEl.IdentEl)).Count>0) then
    // aproperty[]
    ConvertIndexedProperty(TPasProperty(ResolvedEl.IdentEl),AContext)
  else if ResolvedEl.BaseType=btContext then
    begin
    TypeEl:=AContext.Resolver.ResolveAliasType(ResolvedEl.TypeEl);
    if TypeEl.ClassType=TPasClassType then
      begin
      aClass:=TPasClassType(TypeEl);
      ClassScope:=aClass.CustomData as TPas2JSClassScope;
      if ClassScope.DefaultProperty<>nil then
        // anObject[]
        ConvertDefaultProperty(ResolvedEl,ClassScope.DefaultProperty)
      else
        RaiseInconsistency(20170206180448,aClass);
      end
    else if TypeEl.ClassType=TPasClassOfType then
      begin
      // aClass[]
      DestType:=AContext.Resolver.ResolveAliasType(TPasClassOfType(TypeEl).DestType);
      ClassScope:=DestType.CustomData as TPas2JSClassScope;
      if ClassScope.DefaultProperty=nil then
        RaiseInconsistency(20170206180503,DestType);
      ConvertDefaultProperty(ResolvedEl,ClassScope.DefaultProperty);
      end
    else if TypeEl.ClassType=TPasArrayType then
      // anArray[]
      ConvertArray(TPasArrayType(TypeEl))
    else
      RaiseNotSupported(El,AContext,20170206181220,GetResolverResultDbg(ResolvedEl));
    end
  else
    RaiseNotSupported(El,AContext,20170206180222);
end;

function TPasToJSConverter.ConvertFuncParams(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
var
  Ref: TResolvedReference;
  Decl, Left: TPasElement;
  BuiltInProc: TResElDataBuiltInProc;
  TargetProcType: TPasProcedureType;
  Call: TJSCallExpression;
  Elements: TJSArrayLiteralElements;
  E: TJSArrayLiteral;
  OldAccess: TCtxAccess;
  DeclResolved, ParamResolved, ValueResolved: TPasResolverResult;
  Param: TPasExpr;
  JSBaseType: TPas2jsBaseType;
  C: TClass;
  aName: String;
  aClassTypeEl: TPasClassType;
begin
  Result:=nil;
  if El.Kind<>pekFuncParams then
    RaiseInconsistency(20170209113515,El);
  //writeln('TPasToJSConverter.ConvertFuncParams START pekFuncParams ',GetObjName(El.CustomData),' ',GetObjName(El.Value.CustomData));
  Call:=nil;
  Elements:=nil;
  TargetProcType:=nil;
  if El.Value.CustomData is TResolvedReference then
    begin
    Ref:=TResolvedReference(El.Value.CustomData);
    Decl:=Ref.Declaration;
    if Decl is TPasType then
      Decl:=AContext.Resolver.ResolveAliasType(TPasType(Decl));
    //writeln('TPasToJSConverter.ConvertFuncParams pekFuncParams TResolvedReference ',GetObjName(Ref.Declaration),' ',GetObjName(Ref.Declaration.CustomData));
    C:=Decl.ClassType;

    if C=TPasUnresolvedSymbolRef then
      begin
      if Decl.CustomData is TResElDataBuiltInProc then
        begin
        BuiltInProc:=TResElDataBuiltInProc(Decl.CustomData);
        {$IFDEF VerbosePas2JS}
        writeln('TPasToJSConverter.ConvertFuncParams BuiltInProc ',Decl.Name,' ',ResolverBuiltInProcNames[BuiltInProc.BuiltIn]);
        {$ENDIF}
        case BuiltInProc.BuiltIn of
          bfLength: Result:=ConvertBuiltIn_Length(El,AContext);
          bfSetLength: Result:=ConvertBuiltIn_SetLength(El,AContext);
          bfInclude: Result:=ConvertBuiltIn_ExcludeInclude(El,AContext,true);
          bfExclude: Result:=ConvertBuiltIn_ExcludeInclude(El,AContext,false);
          bfExit: Result:=ConvertBuiltIn_Exit(El,AContext);
          bfInc,
          bfDec: Result:=ConvertBuiltIn_IncDec(El,AContext);
          bfAssigned: Result:=ConvertBuiltIn_Assigned(El,AContext);
          bfChr: Result:=ConvertBuiltIn_Chr(El,AContext);
          bfOrd: Result:=ConvertBuiltIn_Ord(El,AContext);
          bfLow: Result:=ConvertBuiltIn_LowHigh(El,AContext,true);
          bfHigh: Result:=ConvertBuiltIn_LowHigh(El,AContext,false);
          bfPred: Result:=ConvertBuiltIn_PredSucc(El,AContext,true);
          bfSucc: Result:=ConvertBuiltIn_PredSucc(El,AContext,false);
          bfStrProc: Result:=ConvertBuiltIn_StrProc(El,AContext);
          bfStrFunc: Result:=ConvertBuiltIn_StrFunc(El,AContext);
          bfConcatArray: Result:=ConvertBuiltIn_ConcatArray(El,AContext);
          bfCopyArray: Result:=ConvertBuiltIn_CopyArray(El,AContext);
          bfInsertArray: Result:=ConvertBuiltIn_InsertArray(El,AContext);
          bfDeleteArray: Result:=ConvertBuiltIn_DeleteArray(El,AContext);
          bfTypeInfo: Result:=ConvertBuiltIn_TypeInfo(El,AContext);
          bfAssert:
            begin
            Result:=ConvertBuiltIn_Assert(El,AContext);
            if Result=nil then exit;
            end
        else
          RaiseNotSupported(El,AContext,20161130164955,'built in proc '+ResolverBuiltInProcNames[BuiltInProc.BuiltIn]);
        end;
        if Result=nil then
          RaiseInconsistency(20170210121932,El);
        exit;
        end
      else if Decl.CustomData is TResElDataBaseType then
        begin
        // typecast to base type
        Result:=ConvertTypeCastToBaseType(El,AContext,TResElDataBaseType(Decl.CustomData));
        exit;
        end
      else
        RaiseNotSupported(El,AContext,20170325160624);
      end
    else if IsExternalClassConstructor(Decl) then
      begin
      // create external object/function
      // -> check if there is complex left side, e.g. TExtA.Create(params)
      Left:=El;
      while (Left.Parent.ClassType=TParamsExpr) do
        Left:=Left.Parent;
      if (Left.Parent.ClassType=TBinaryExpr) and (TBinaryExpr(Left.Parent).right=Left) then
        Left:=TBinaryExpr(Left.Parent).Left
      else
        Left:=nil;
      Result:=ConvertExternalConstructor(Left,Ref,El,AContext);
      exit;
      end
    else if C.InheritsFrom(TPasProcedure) then
      TargetProcType:=TPasProcedure(Decl).ProcType
    else if (C=TPasClassType)
        or (C=TPasClassOfType)
        or (C=TPasRecordType)
        or (C=TPasEnumType)
        or (C=TPasArrayType) then
      begin
      // typecast
      // default is to simply replace  "aType(value)" with "value"
      Param:=El.Params[0];
      AContext.Resolver.ComputeElement(Param,ParamResolved,[]);

      Result:=ConvertElement(Param,AContext);

      if bsObjectChecks in AContext.ScannerBoolSwitches then
        begin
        if (C=TPasClassType)
           or (C=TPasClassOfType) then
          begin
          // TObject(value) -> rtl.asExt(value,type,mode)
          if C=TPasClassOfType then
            aClassTypeEl:=AContext.Resolver.ResolveAliasType(TPasClassOfType(Decl).DestType) as TPasClassType
          else
            aClassTypeEl:=TPasClassType(Decl);
          aName:=CreateReferencePath(aClassTypeEl,AContext,rpkPathAndName);
          Call:=CreateCallExpression(El);
          Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnAsExt]]);
          Call.AddArg(Result);
          Call.AddArg(CreatePrimitiveDotExpr(aName,El.Value));
          if aClassTypeEl.IsExternal then
          else if C=TPasClassOfType then
            Call.AddArg(CreateLiteralNumber(El.Value,IsExtModePasClass))
          else
            Call.AddArg(CreateLiteralNumber(El.Value,IsExtModePasClassInstance));
          Result:=Call;
          end;
        end
      else if (ParamResolved.BaseType=btCustom)
          and (ParamResolved.TypeEl.CustomData is TResElDataPas2JSBaseType) then
        begin
        JSBaseType:=TResElDataPas2JSBaseType(ParamResolved.TypeEl.CustomData).JSBaseType;
        if JSBaseType=pbtJSValue then
          begin
          if (C=TPasClassType)
              or (C=TPasClassOfType)
              or (C=TPasRecordType) then
            begin
            // TObject(jsvalue)  ->  rtl.getObject(jsvalue)
            Call:=CreateCallExpression(El);
            Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnGetObject]]);
            Call.AddArg(Result);
            Result:=Call;
            end;
          end;
        end;

      exit;
      end
    else if C.InheritsFrom(TPasVariable) then
      begin
      AContext.Resolver.ComputeElement(Decl,DeclResolved,[rcType]);
      if DeclResolved.TypeEl is TPasProcedureType then
        TargetProcType:=TPasProcedureType(DeclResolved.TypeEl)
      else
        RaiseNotSupported(El,AContext,20170217115244);
      end
    else if (C=TPasArgument) then
      begin
      AContext.Resolver.ComputeElement(Decl,DeclResolved,[rcType]);
      if DeclResolved.TypeEl is TPasProcedureType then
        TargetProcType:=TPasProcedureType(DeclResolved.TypeEl)
      else
        RaiseNotSupported(El,AContext,20170328224020);
      end
    else if (C=TPasProcedureType)
        or (C=TPasFunctionType) then
      begin
      AContext.Resolver.ComputeElement(El.Value,ValueResolved,[rcNoImplicitProc]);
      if (ValueResolved.IdentEl is TPasType)
          and (AContext.Resolver.ResolveAliasType(TPasType(ValueResolved.IdentEl)) is TPasProcedureType) then
        begin
        // type cast to proc type
        Param:=El.Params[0];
        Result:=ConvertElement(Param,AContext);
        exit;
        end
      else
        begin
        // calling proc var
        TargetProcType:=TPasProcedureType(Decl);
        end;
      end
    else
      begin
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.ConvertFuncParams El=',GetObjName(El),' Decl=',GetObjName(Decl));
      {$ENDIF}
      RaiseNotSupported(El,AContext,20170215114337);
      end;
    if [rrfNewInstance,rrfFreeInstance]*Ref.Flags<>[] then
      // call constructor, destructor
      Call:=CreateFreeOrNewInstanceExpr(Ref,AContext);
    end;
  if Call=nil then
    begin
    Call:=CreateCallExpression(El);
    Elements:=Call.Args.Elements;
    end;
  OldAccess:=AContext.Access;
  try
    AContext.Access:=caRead;
    if Call.Expr=nil then
      Call.Expr:=ConvertElement(El.Value,AContext);
    //if Call.Expr is TPrimitiveExpr then
    //  writeln('TPasToJSConverter.ConvertFuncParams ',TPrimitiveExpr(Call.Expr).GetDeclaration(true));
    if Call.Args=nil then
      begin
      // append ()
      Call.Args:=TJSArguments(CreateElement(TJSArguments,El));
      Elements:=Call.Args.Elements;
      end
    else if Elements=nil then
      begin
      // insert array parameter [], e.g. this.TObject.$create("create",[])
      Elements:=Call.Args.Elements;
      E:=TJSArrayLiteral(CreateElement(TJSArrayLiteral,El));
      Elements.AddElement.Expr:=E;
      Elements:=TJSArrayLiteral(E).Elements;
      end;
    CreateProcedureCallArgs(Elements,El,TargetProcType,AContext);
    if Elements.Count=0 then
      begin
      Call.Args.Free;
      Call.Args:=nil;
      end;
    Result:=Call;
  finally
    AContext.Access:=OldAccess;
    if Result=nil then
      Call.Free;
  end;
end;

function TPasToJSConverter.ConvertExternalConstructor(Left: TPasElement;
  Ref: TResolvedReference; ParamsExpr: TParamsExpr; AContext: TConvertContext
  ): TJSElement;
var
  Proc: TPasConstructor;
  ExtName: String;
  NewExpr: TJSNewMemberExpression;
  Call: TJSCallExpression;
  LeftResolved: TPasResolverResult;
  OldAccess: TCtxAccess;
  ExtNameEl: TJSElement;
  WithData: TPas2JSWithExprScope;
begin
  Result:=nil;
  NewExpr:=nil;
  Call:=nil;
  ExtNameEl:=nil;
  try
    Proc:=Ref.Declaration as TPasConstructor;
    ExtNameEl:=nil;

    if Left<>nil then
      begin
      if AContext.Resolver<>nil then
        begin
        AContext.Resolver.ComputeElement(Left,LeftResolved,[]);
        if LeftResolved.BaseType=btModule then
          begin
          // e.g. Unit.TExtA
          // ExtName is global -> omit unit
          Left:=nil;
          end
        else ;
        end;
      if Left<>nil then
        begin
        // convert left side
        OldAccess:=AContext.Access;
        AContext.Access:=caRead;
        ExtNameEl:=ConvertElement(Left,AContext);
        AContext.Access:=OldAccess;
        end;
      end;
    if ExtNameEl=nil then
      begin
      if Ref.WithExprScope<>nil then
        begin
        // using local WITH var
        WithData:=Ref.WithExprScope as TPas2JSWithExprScope;
        ExtName:=WithData.WithVarName;
        end
      else
        // use external class name
        ExtName:=(Proc.Parent as TPasClassType).ExternalName;
      ExtNameEl:=CreatePrimitiveDotExpr(ExtName,Ref.Element);
      end;

    if CompareText(Proc.Name,'new')=0 then
      begin
      // create 'new ExtName(params)'
      NewExpr:=TJSNewMemberExpression(CreateElement(TJSNewMemberExpression,Ref.Element));
      NewExpr.MExpr:=ExtNameEl;
      NewExpr.Args:=TJSArguments(CreateElement(TJSArguments,Ref.Element));
      ExtNameEl:=nil;
      if ParamsExpr<>nil then
        CreateProcedureCallArgs(NewExpr.Args.Elements,ParamsExpr,Proc.ProcType,AContext);
      Result:=NewExpr;
      NewExpr:=nil;
      end
    else
      RaiseInconsistency(20170323083214,Proc);
  finally
    ExtNameEl.Free;
    NewExpr.Free;
    Call.Free;
  end;
end;

function TPasToJSConverter.ConvertTObjectFree(Bin: TBinaryExpr;
  NameExpr: TPasExpr; AContext: TConvertContext): TJSElement;

  function CreateCallRTLFree(Obj, Prop: TJSElement): TJSElement;
  // create "rtl.free(obj,prop)"
  var
    Call: TJSCallExpression;
  begin
    Call:=CreateCallExpression(Bin.right);
    Call.Expr:=CreateMemberExpression([GetBuildInNames(pbivnRTL),GetBuildInNames(pbifnFreeVar)]);
    Call.Args.AddElement(Obj);
    Call.Args.AddElement(Prop);
    Result:=Call;
  end;

var
  LeftJS, Obj, Prop, Getter, Setter: TJSElement;
  DotExpr: TJSDotMemberExpression;
  BracketJS: TJSBracketMemberExpression;
  aName: TJSString;
  WithExprScope: TPas2JSWithExprScope;
begin
  Result:=nil;

  LeftJS:=nil;
  try
    WithExprScope:=TResolvedReference(NameExpr.CustomData).WithExprScope as TPas2JSWithExprScope;
    if WithExprScope<>nil then
      begin
      if AContext.Resolver.GetNewInstanceExpr(WithExprScope.Expr)<>nil then
        begin
        // "with TSomeClass.Create do Free"
        // -> "$with1=rtl.freeLoc($with1);
        Getter:=CreatePrimitiveDotExpr(WithExprScope.WithVarName,WithExprScope.Expr);
        Setter:=CreatePrimitiveDotExpr(WithExprScope.WithVarName,WithExprScope.Expr);
        Result:=CreateCallRTLFreeLoc(Setter,Getter,NameExpr);
        exit;
        end;
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.ConvertTObjectFree With=',GetObjName(WithExprScope.Expr));
      {$ENDIF}
      RaiseInconsistency(20170517092248,Bin);
      end;

    LeftJS:=ConvertElement(Bin.left,AContext);
    {$IFDEF VerbosePas2JS}
    writeln('TPasToJSConverter.ConvertTObjectFree ',GetObjName(LeftJS));
    {$ENDIF}

    if LeftJS is TJSPrimaryExpressionIdent then
      begin
      aName:=TJSPrimaryExpressionIdent(LeftJS).Name;
      if Pos('.',aName)>0 then
        RaiseInconsistency(20170516173832,Bin.left);
      // v.free
      // -> v=rtl.freeLoc(v);
      Getter:=LeftJS;
      Setter:=ClonePrimaryExpression(TJSPrimaryExpressionIdent(LeftJS),Bin.left);
      Result:=CreateCallRTLFreeLoc(Setter,Getter,NameExpr);
      end
    else if LeftJS is TJSDotMemberExpression then
      begin
      // obj.prop.free
      // ->  rtl.free(obj,"prop");
      DotExpr:=TJSDotMemberExpression(LeftJS);
      Obj:=DotExpr.MExpr;
      DotExpr.MExpr:=nil;
      Prop:=CreateLiteralJSString(Bin.right,DotExpr.Name);
      FreeAndNil(LeftJS);
      Result:=CreateCallRTLFree(Obj,Prop);
      end
    else if LeftJS is TJSBracketMemberExpression then
      begin
      // obj[prop].free
      // ->  rtl.free(obj,prop);
      BracketJS:=TJSBracketMemberExpression(LeftJS);
      Obj:=BracketJS.MExpr;
      BracketJS.MExpr:=nil;
      Prop:=BracketJS.Name;
      BracketJS.Name:=nil;
      FreeAndNil(LeftJS);
      Result:=CreateCallRTLFree(Obj,Prop);
      end
    else
      RaiseNotSupported(Bin.left,AContext,20170516164659,'invalid scope for Free');
  finally
    if Result=nil then
      LeftJS.Free;
  end;
end;

function TPasToJSConverter.ConvertTypeCastToBaseType(El: TParamsExpr;
  AContext: TConvertContext; ToBaseTypeData: TResElDataBaseType): TJSElement;
var
  to_bt: TResolverBaseType;
  Param: TPasExpr;
  ParamResolved: TPasResolverResult;
  JSBaseType: TPas2jsBaseType;
  JSBaseTypeData: TResElDataPas2JSBaseType;

  function IsParamPas2JSBaseType: boolean;
  var
    TypeEl: TPasType;
  begin
    if ParamResolved.BaseType<>btCustom then exit(false);
    TypeEl:=ParamResolved.TypeEl;
    if TypeEl.ClassType<>TPasUnresolvedSymbolRef then exit(false);
    if not (TypeEl.CustomData is TResElDataPas2JSBaseType) then exit(false);
    Result:=true;
    JSBaseTypeData:=TResElDataPas2JSBaseType(TypeEl.CustomData);
    JSBaseType:=JSBaseTypeData.JSBaseType;
  end;

var
  NotEqual: TJSEqualityExpressionNE;
  CondExpr: TJSConditionalExpression;
  Call: TJSCallExpression;
  NotExpr: TJSUnaryNotExpression;
  AddExpr: TJSAdditiveExpressionPlus;
  TypeEl: TPasType;
  C: TClass;
  Int: MaxPrecInt;
begin
  Result:=nil;
  Param:=El.Params[0];
  AContext.Resolver.ComputeElement(Param,ParamResolved,[]);
  JSBaseTypeData:=nil;
  JSBaseType:=pbtNone;

  to_bt:=ToBaseTypeData.BaseType;
  if to_bt in btAllJSInteger then
    begin
    if ParamResolved.BaseType in btAllJSInteger then
      begin
      // integer to integer -> value
      Result:=ConvertElement(Param,AContext);
      exit;
      end
    else if ParamResolved.BaseType in btAllJSBooleans then
      begin
      // boolean to integer -> value?1:0
      Result:=ConvertElement(Param,AContext);
      // Note: convert value first in case it raises an exception
      CondExpr:=TJSConditionalExpression(CreateElement(TJSConditionalExpression,El));
      CondExpr.A:=Result;
      CondExpr.B:=CreateLiteralNumber(El,1);
      CondExpr.C:=CreateLiteralNumber(El,0);
      Result:=CondExpr;
      exit;
      end
    else if ParamResolved.BaseType=btContext then
      begin
      if ParamResolved.TypeEl.ClassType=TPasEnumType then
        begin
        // e.g. longint(TEnum) -> value
        Result:=ConvertElement(Param,AContext);
        exit;
        end;
      end
    else if IsParamPas2JSBaseType then
      begin
      if JSBaseType=pbtJSValue then
        begin
        // convert jsvalue to integer -> Math.floor(value)
        Result:=ConvertElement(Param,AContext);
        // Note: convert value first in case it raises an exception
        Call:=CreateCallExpression(El);
        Call.Expr:=CreateMemberExpression(['Math','floor']);
        Call.AddArg(Result);
        Result:=Call;
        exit;
        end;
      end;
    end
  else if to_bt in btAllJSBooleans then
    begin
    if ParamResolved.BaseType in btAllJSBooleans then
      begin
      // boolean to boolean -> value
      Result:=ConvertElement(Param,AContext);
      exit;
      end
    else if ParamResolved.BaseType in btAllJSInteger then
      begin
      // integer to boolean -> value!=0
      Result:=ConvertElement(Param,AContext);
      // Note: convert value first in case it raises an exception
      NotEqual:=TJSEqualityExpressionNE(CreateElement(TJSEqualityExpressionNE,El));
      NotEqual.A:=Result;
      NotEqual.B:=CreateLiteralNumber(El,0);
      Result:=NotEqual;
      exit;
      end
    else if IsParamPas2JSBaseType then
      begin
      if JSBaseType=pbtJSValue then
        begin
        // convert jsvalue to boolean -> !(value==false)
        Result:=ConvertElement(Param,AContext);
        // Note: convert value first in case it raises an exception
        NotExpr:=TJSUnaryNotExpression(CreateElement(TJSUnaryNotExpression,El));
        NotExpr.A:=TJSEqualityExpressionEQ(CreateElement(TJSEqualityExpressionEQ,El));
        TJSEqualityExpressionEQ(NotExpr.A).A:=Result;
        TJSEqualityExpressionEQ(NotExpr.A).B:=CreateLiteralBoolean(El,false);
        Result:=NotExpr;
        exit;
        end;
      end;
    end
  else if to_bt in btAllJSFloats then
    begin
    if ParamResolved.BaseType in (btAllJSFloats+btAllJSInteger) then
      begin
      // double to double -> value
      Result:=ConvertElement(Param,AContext);
      exit;
      end
    else if IsParamPas2JSBaseType then
      begin
      if JSBaseType=pbtJSValue then
        begin
        // convert jsvalue to double -> rtl.getNumber(value)
        Result:=ConvertElement(Param,AContext);
        // Note: convert value first in case it raises an exception
        Call:=CreateCallExpression(El);
        Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnGetNumber]]);
        Call.AddArg(Result);
        Result:=Call;
        exit;
        end;
      end;
    end
  else if to_bt in btAllJSStrings then
    begin
    if ParamResolved.BaseType in btAllJSStringAndChars then
      begin
      // string or char to string -> value
      Result:=ConvertElement(Param,AContext);
      exit;
      end
    else if IsParamPas2JSBaseType then
      begin
      if JSBaseType=pbtJSValue then
        begin
        // convert jsvalue to string -> ""+value
        Result:=ConvertElement(Param,AContext);
        // Note: convert value first in case it raises an exception
        AddExpr:=TJSAdditiveExpressionPlus(CreateElement(TJSAdditiveExpressionPlus,El));
        AddExpr.A:=CreateLiteralString(El,'');
        AddExpr.B:=Result;
        Result:=AddExpr;
        exit;
        end;
      end;
    end
  else if to_bt=btChar then
    begin
    if ParamResolved.BaseType=btChar then
      begin
      // char to char
      Result:=ConvertElement(Param,AContext);
      exit;
      end
    else if (ParamResolved.BaseType in btAllInteger)
        or ((ParamResolved.BaseType=btContext)
          and (AContext.Resolver.ResolveAliasType(ParamResolved.TypeEl).ClassType=TPasEnumType))
        then
      begin
      // Note: convert value first in case it raises an exception
      Result:=ConvertElement(Param,AContext);
      if IsLiteralInteger(Result,Int)
          and (Int>=0) and (Int<=$ffff) then
        begin
        FreeAndNil(Result);
        Result:=CreateLiteralJSString(Param,WideChar(Int));
        end
      else
        begin
        // char(integer) -> String.fromCharCode(integer)
        Result:=CreateCallFromCharCode(Result,El);
        end;
      exit;
      end
    else if (ParamResolved.BaseType in (btArrayRangeTypes+[btRange]))
        or (IsParamPas2JSBaseType and (JSBaseType=pbtJSValue)) then
      begin
      // convert value to char -> rtl.getChar(value)
      // Note: convert value first in case it raises an exception
      Result:=ConvertElement(Param,AContext);
      if IsLiteralInteger(Result,Int) then
        begin
        if (Int>=0) and (Int<=$ffff) then
          begin
          FreeAndNil(Result);
          Result:=CreateLiteralJSString(Param,WideChar(Int));
          end
        else
          begin
          // char(integer) -> String.fromCharCode(integer)
          Result:=CreateCallFromCharCode(Result,El);
          end;
        end
      else
        begin
        // convert value to char -> rtl.getChar(value)
        Call:=CreateCallExpression(El);
        Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnGetChar]]);
        Call.AddArg(Result);
        Result:=Call;
        end;
      exit;
      end;
    end
  else if to_bt=btPointer then
    begin
    if IsParamPas2JSBaseType then
      begin
      if JSBaseType=pbtJSValue then
        begin
        // convert jsvalue to pointer -> pass through
        Result:=ConvertElement(Param,AContext);
        exit;
        end;
      end
    else if ParamResolved.BaseType=btContext then
      begin
      // convert user type/value to pointer -> pass through
      Result:=ConvertElement(Param,AContext);
      exit;
      end;
    end
  else if (to_bt=btCustom) and (ToBaseTypeData is TResElDataPas2JSBaseType) then
    begin
    JSBaseType:=TResElDataPas2JSBaseType(ToBaseTypeData).JSBaseType;
    if JSBaseType=pbtJSValue then
      begin
      // type cast to jsvalue
      Result:=ConvertElement(Param,AContext);
      // Note: convert value first in case it raises an exception
      if ParamResolved.BaseType=btContext then
        begin
        TypeEl:=AContext.Resolver.ResolveAliasType(ParamResolved.TypeEl);
        C:=TypeEl.ClassType;
        if C=TPasClassType then
          begin
          // TObject(vsvalue) -> rtl.getObject(vsvalue)
          Call:=CreateCallExpression(El);
          Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnGetObject]]);
          Call.AddArg(Result);
          Result:=Call;
          end;
        end;
      exit;
      end;
    end;
  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.ConvertTypeCastToBaseType BaseTypeData=',AContext.Resolver.BaseTypeNames[to_bt],' ParamResolved=',GetResolverResultDbg(ParamResolved));
  {$ENDIF}
  RaiseNotSupported(El,AContext,20170325161150);
end;

function TPasToJSConverter.ConvertSetLiteral(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
var
  Call: TJSCallExpression;
  ArgContext: TConvertContext;

  procedure AddArg(Expr: TPasExpr);
  begin
    Result:=CreateSetLiteralElement(Expr,ArgContext);
    Call.AddArg(Result);
  end;

var
  i: Integer;
  ArgEl: TPasExpr;
begin
  if El.Kind<>pekSet then
    RaiseInconsistency(20170209112737,El);
  if AContext.Access<>caRead then
    DoError(20170209112926,nCantWriteSetLiteral,sCantWriteSetLiteral,[],El);
  if length(El.Params)=0 then
    Result:=TJSObjectLiteral(CreateElement(TJSObjectLiteral,El))
  else
    begin
    Result:=nil;
    ArgContext:=AContext;
    while ArgContext is TDotContext do
      ArgContext:=ArgContext.Parent;
    Call:=CreateCallExpression(El);
    try
      Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnSet_Create]]);
      for i:=0 to length(El.Params)-1 do
        begin
        ArgEl:=El.Params[i];
        {$IFDEF VerbosePas2JS}
        writeln('TPasToJSConverter.ConvertSetLiteral ',i,' El.Params[i]=',GetObjName(ArgEl));
        {$ENDIF}
        if (ArgEl.ClassType=TBinaryExpr) and (TBinaryExpr(ArgEl).Kind=pekRange) then
          begin
          // range -> add three parameters: null,left,right
          Call.AddArg(CreateLiteralNull(ArgEl));
          AddArg(TBinaryExpr(ArgEl).left);
          AddArg(TBinaryExpr(ArgEl).right);
          end
        else
          AddArg(ArgEl);
        end;
      Result:=Call;
    finally
      if Result=nil then
        Call.Free;
    end;
    end;
end;

function TPasToJSConverter.ConvertOpenArrayParam(ElType: TPasType;
  El: TParamsExpr; AContext: TConvertContext): TJSElement;
var
  ArrLit: TJSArrayLiteral;
  i: Integer;
  NestedElType: TPasType;
  Param: TPasExpr;
  JSParam: TJSElement;
begin
  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.ConvertOpenArrayParam ',GetObjName(ElType));
  {$ENDIF}
  Result:=nil;
  try
    NestedElType:=nil;
    if ElType is TPasArrayType then
      NestedElType:=TPasArrayType(ElType).ElType;
    ArrLit:=TJSArrayLiteral(CreateElement(TJSArrayLiteral,El));
    for i:=0 to length(El.Params)-1 do
      begin
      Param:=El.Params[i];
      if (NestedElType<>nil)
          and (Param is TParamsExpr) and (TParamsExpr(Param).Kind=pekSet) then
        JSParam:=ConvertOpenArrayParam(NestedElType,TParamsExpr(Param),AContext)
      else
        JSParam:=ConvertElement(Param,AContext);
      ArrLit.Elements.AddElement.Expr:=JSParam;
      end;
    Result:=ArrLit;
  finally
    if Result=nil then
      ArrLit.Free;
  end;
end;

function TPasToJSConverter.ConvertBuiltIn_Length(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
var
  Arg: TJSElement;
  Param, RangeEl: TPasExpr;
  ParamResolved: TPasResolverResult;
  Ranges: TPasExprArray;
  Call: TJSCallExpression;
  RgLen: MaxPrecInt;
begin
  Result:=nil;
  Param:=El.Params[0];
  AContext.Resolver.ComputeElement(Param,ParamResolved,[]);
  if ParamResolved.BaseType=btContext then
    begin
    if ParamResolved.TypeEl is TPasArrayType then
      begin
      Ranges:=TPasArrayType(ParamResolved.TypeEl).Ranges;
      if length(Ranges)>0 then
        begin
        // static array -> number literal
        if length(Ranges)>1 then
          RaiseNotSupported(El,AContext,20170223131042);
        RangeEl:=Ranges[0];
        RgLen:=AContext.Resolver.GetRangeLength(RangeEl);
        Result:=CreateLiteralNumber(El,RgLen);
        exit;
        end
      else
        begin
        // dynamic array -> rtl.length(array)
        Result:=ConvertElement(El.Params[0],AContext);
        // Note: convert param first, it may raise an exception
        Call:=CreateCallExpression(El);
        Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnArray_Length]]);
        Call.AddArg(Result);
        Result:=Call;
        exit;
        end;
      end;
    end;

  // default: Param.length
  Arg:=ConvertElement(Param,AContext);
  Result:=CreateDotExpression(El,Arg,CreatePrimitiveDotExpr('length',El));
end;

function TPasToJSConverter.ConvertBuiltIn_SetLength(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
// convert "SetLength(a,Len)" to "a = rtl.arraySetLength(a,Len)"
var
  Param0: TPasExpr;
  ResolvedParam0: TPasResolverResult;
  ArrayType: TPasArrayType;
  Call: TJSCallExpression;
  ValInit: TJSElement;
  AssignContext: TAssignContext;
  ElType: TPasType;
  i: Integer;
begin
  Result:=nil;
  Param0:=El.Params[0];
  if AContext.Access<>caRead then
    RaiseInconsistency(20170213213621,El);
  AContext.Resolver.ComputeElement(Param0,ResolvedParam0,[rcNoImplicitProc]);
  {$IFDEF VerbosePasResolver}
  writeln('TPasToJSConverter.ConvertBuiltInSetLength ',GetResolverResultDbg(ResolvedParam0));
  {$ENDIF}
  if ResolvedParam0.TypeEl is TPasArrayType then
    begin
    // SetLength(AnArray,dim1,dim2,...)
    ArrayType:=TPasArrayType(ResolvedParam0.TypeEl);
    {$IFDEF VerbosePasResolver}
    writeln('TPasToJSConverter.ConvertBuiltInSetLength array');
    {$ENDIF}

    // ->  AnArray = rtl.setArrayLength(AnArray,defaultvalue,dim1,dim2,...)
    AssignContext:=TAssignContext.Create(El,nil,AContext);
    try
      AContext.Resolver.ComputeElement(Param0,AssignContext.LeftResolved,[rcNoImplicitProc]);
      AssignContext.RightResolved:=ResolvedParam0;

      // create right side
      // rtl.setArrayLength()
      Call:=CreateCallExpression(El);
      AssignContext.RightSide:=Call;
      Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnArray_SetLength]]);
      // 1st param: AnArray
      Call.AddArg(ConvertElement(Param0,AContext));
      // 2nd param: default value
      for i:=3 to length(El.Params) do
        begin
        ElType:=AContext.Resolver.ResolveAliasType(ArrayType.ElType);
        ArrayType:=ElType as TPasArrayType;
        end;
      ElType:=AContext.Resolver.ResolveAliasType(ArrayType.ElType);
      if ElType.ClassType=TPasRecordType then
        ValInit:=CreateReferencePathExpr(ElType,AContext)
      else
        ValInit:=CreateValInit(ElType,nil,Param0,AContext);
      Call.AddArg(ValInit);
      // add params: dim1, dim2, ...
      for i:=1 to length(El.Params)-1 do
        Call.AddArg(ConvertElement(El.Params[i],AContext));

      // create left side:  array =
      Result:=CreateAssignStatement(Param0,AssignContext);
    finally
      AssignContext.RightSide.Free;
      AssignContext.Free;
    end;
    end
  else if ResolvedParam0.BaseType=btString then
    begin
    // convert "SetLength(astring,NewLen);" to "astring = rtl.strSetLength(astring,NewLen);"
    {$IFDEF VerbosePasResolver}
    writeln('TPasToJSConverter.ConvertBuiltInSetLength string');
    {$ENDIF}
    AssignContext:=TAssignContext.Create(El,nil,AContext);
    try
      AContext.Resolver.ComputeElement(Param0,AssignContext.LeftResolved,[rcNoImplicitProc]);
      AssignContext.RightResolved:=AssignContext.LeftResolved;

      // create right side  rtl.strSetLength(aString,NewLen)
      Call:=CreateCallExpression(El);
      AssignContext.RightSide:=Call;
      Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnStringSetLength]]);
      Call.AddArg(ConvertElement(Param0,AContext));
      Call.AddArg(ConvertElement(El.Params[1],AContext));

      Result:=CreateAssignStatement(Param0,AssignContext);
    finally
      AssignContext.RightSide.Free;
      AssignContext.Free;
    end;
    end
  else
    RaiseNotSupported(El.Value,AContext,20170130141026,'setlength '+GetResolverResultDbg(ResolvedParam0));
end;

function TPasToJSConverter.ConvertBuiltIn_ExcludeInclude(El: TParamsExpr;
  AContext: TConvertContext; IsInclude: boolean): TJSElement;
// convert "Include(aSet,Enum)" to "aSet=rtl.includeSet(aSet,Enum)"
var
  Call: TJSCallExpression;
  Param0: TPasExpr;
  AssignContext: TAssignContext;
  FunName: String;
begin
  Result:=nil;
  Param0:=El.Params[0];
  AssignContext:=TAssignContext.Create(El,nil,AContext);
  try
    AContext.Resolver.ComputeElement(Param0,AssignContext.LeftResolved,[rcNoImplicitProc]);
    AssignContext.RightResolved:=AssignContext.LeftResolved;

    // create right side  rtl.includeSet(aSet,Enum)
    Call:=CreateCallExpression(El);
    AssignContext.RightSide:=Call;
    if IsInclude then
      FunName:=FBuiltInNames[pbifnSet_Include]
    else
      FunName:=FBuiltInNames[pbifnSet_Exclude];
    Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FunName]);
    Call.AddArg(ConvertElement(Param0,AContext));
    Call.AddArg(ConvertElement(El.Params[1],AContext));

    Result:=CreateAssignStatement(Param0,AssignContext);
  finally
    AssignContext.RightSide.Free;
    AssignContext.Free;
  end;
end;

function TPasToJSConverter.ConvertBuiltInContinue(El: TPasExpr;
  AContext: TConvertContext): TJSElement;
begin
  if AContext=nil then;
  Result:=TJSContinueStatement(CreateElement(TJSContinueStatement,El));
end;

function TPasToJSConverter.ConvertBuiltInBreak(El: TPasExpr;
  AContext: TConvertContext): TJSElement;
begin
  if AContext=nil then;
  Result:=TJSBreakStatement(CreateElement(TJSBreakStatement,El));
end;

function TPasToJSConverter.ConvertBuiltIn_Exit(El: TPasExpr;
  AContext: TConvertContext): TJSElement;
// convert "exit;" -> in a function: "return result;"  in a procedure: "return;"
// convert "exit(param);" -> "return param;"
var
  ProcEl: TPasElement;
  Scope: TPas2JSProcedureScope;
  VarName: String;
begin
  Result:=TJSReturnStatement(CreateElement(TJSReturnStatement,El));
  if (El is TParamsExpr) and (length(TParamsExpr(El).Params)>0) then
    begin
    // with parameter. convert "exit(param);" -> "return param;"
    TJSReturnStatement(Result).Expr:=ConvertExpression(TParamsExpr(El).Params[0],AContext);
    end
  else
    begin
    // without parameter.
    ProcEl:=El.Parent;
    while (ProcEl<>nil) and not (ProcEl is TPasProcedure) do
      ProcEl:=ProcEl.Parent;
    if ProcEl is TPasFunction then
      begin
      // in a function, "return result;"
      Scope:=ProcEl.CustomData as TPas2JSProcedureScope;
      VarName:=Scope.ResultVarName;
      if VarName='' then
        VarName:=ResolverResultVar;
      TJSReturnStatement(Result).Expr:=CreatePrimitiveDotExpr(VarName,El);
      end
    else
      ; // in a procedure, "return;" which means "return undefined;"
    end;
end;

function TPasToJSConverter.ConvertBuiltIn_IncDec(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
{ inc(a) or inc(a,b)
 if a is a variable:
   convert inc(a,b) to a+=b
 if a is a var/out arg:
   convert inc(a,b) to a.set(a.get+b)
 if a is a property
   Getter: field, procedure
 if a is an indexed-property
   Getter: field, procedure
 if a is a property with index-specifier
   Getter: field, procedure
}
var
  AssignSt: TJSAssignStatement;
  Expr, SrcEl: TPasExpr;
  ExprResolved: TPasResolverResult;
  ExprArg: TPasArgument;
  ValueJS: TJSElement;
  Call: TJSCallExpression;
  IsInc: Boolean;
  AddJS: TJSAdditiveExpression;
begin
  Result:=nil;
  IsInc:=CompareText((El.Value as TPrimitiveExpr).Value,'inc')=0;
  Expr:=El.Params[0];
  AContext.Resolver.ComputeElement(Expr,ExprResolved,[]);

  // convert value
  if length(El.Params)=1 then
    ValueJS:=CreateLiteralNumber(El,1)
  else
    ValueJS:=ConvertExpression(El.Params[1],AContext);
  SrcEl:=El.Value;

  // check target variable
  AssignSt:=nil;
  Call:=nil;
  try
    if ExprResolved.IdentEl is TPasArgument then
      begin
      ExprArg:=TPasArgument(ExprResolved.IdentEl);
      if ExprArg.Access in [argVar,argOut] then
        begin
        // target variable is a reference
        // -> convert inc(ref,b)  to  ref.set(ref.get()+b)
        Call:=CreateCallExpression(SrcEl);
        // create "ref.set"
        Call.Expr:=CreateDotExpression(SrcEl,
          CreateIdentifierExpr(ExprResolved.IdentEl,AContext),
          CreatePrimitiveDotExpr(TempRefObjSetterName,SrcEl));
        // create "+"
        if IsInc then
          AddJS:=TJSAdditiveExpressionPlus(CreateElement(TJSAdditiveExpressionPlus,SrcEl))
        else
          AddJS:=TJSAdditiveExpressionMinus(CreateElement(TJSAdditiveExpressionMinus,SrcEl));
        Call.AddArg(AddJS);
        // create "ref.get()"
        AddJS.A:=TJSCallExpression(CreateElement(TJSCallExpression,SrcEl));
        TJSCallExpression(AddJS.A).Expr:=CreateDotExpression(SrcEl,
          CreateIdentifierExpr(ExprResolved.IdentEl,AContext),
          CreatePrimitiveDotExpr(TempRefObjGetterName,SrcEl));
        // add "b"
        AddJS.B:=ValueJS;
        ValueJS:=nil;

        Result:=Call;
        exit;
        end;
      end
    else if ExprResolved.IdentEl is TPasProperty then
      begin
      RaiseNotSupported(Expr,AContext,20170501151316);
      end;

    // convert inc(avar,b)  to  a+=b
    if IsInc then
      AssignSt:=TJSAddEqAssignStatement(CreateElement(TJSAddEqAssignStatement,SrcEl))
    else
      AssignSt:=TJSSubEqAssignStatement(CreateElement(TJSSubEqAssignStatement,SrcEl));
    AssignSt.LHS:=ConvertExpression(El.Params[0],AContext);
    AssignSt.Expr:=ValueJS;
    ValueJS:=nil;
    Result:=AssignSt;
  finally
    ValueJS.Free;
    if Result=nil then
      begin
      AssignSt.Free;
      Call.Free;
      end;
  end;
end;

function TPasToJSConverter.ConvertBuiltIn_Assigned(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
var
  NE: TJSEqualityExpressionNE;
  Param: TPasExpr;
  ParamResolved: TPasResolverResult;
  C: TClass;
  GT: TJSRelationalExpressionGT;
  Call: TJSCallExpression;
begin
  Result:=nil;
  if AContext.Resolver=nil then
    RaiseInconsistency(20170210105235,El);
  Param:=El.Params[0];
  AContext.Resolver.ComputeElement(Param,ParamResolved,[rcNoImplicitProcType]);
  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.ConvertBuiltInAssigned ParamResolved=',GetResolverResultDbg(ParamResolved));
  {$ENDIF}
  if ParamResolved.BaseType=btPointer then
    begin
    // convert Assigned(value)  ->  value!=null
    Result:=ConvertElement(Param,AContext);
    // Note: convert Param first, it may raise an exception
    NE:=TJSEqualityExpressionNE(CreateElement(TJSEqualityExpressionNE,El));
    NE.A:=Result;
    NE.B:=CreateLiteralNull(El);
    Result:=NE;
    end
  else if ParamResolved.BaseType=btContext then
    begin
    C:=ParamResolved.TypeEl.ClassType;
    if (C=TPasClassType)
        or (C=TPasClassOfType)
        or C.InheritsFrom(TPasProcedureType) then
      begin
      // convert Assigned(value)  ->  value!=null
      Result:=ConvertElement(Param,AContext);
      // Note: convert Param first, it may raise an exception
      NE:=TJSEqualityExpressionNE(CreateElement(TJSEqualityExpressionNE,El));
      NE.A:=Result;
      NE.B:=CreateLiteralNull(El);
      Result:=NE;
      end
    else if C=TPasArrayType then
      begin
      // convert Assigned(value)  ->  rtl.length(value)>0
      Result:=ConvertElement(Param,AContext);
      // Note: convert Param first, it may raise an exception
      GT:=TJSRelationalExpressionGT(CreateElement(TJSRelationalExpressionGT,El));
      Call:=CreateCallExpression(El);
      Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnArray_Length]]);
      Call.AddArg(Result);
      GT.A:=Call;
      GT.B:=CreateLiteralNumber(El,0);
      Result:=GT;
      end
    else
      RaiseNotSupported(El,AContext,20170328124606);
    end;
end;

function TPasToJSConverter.ConvertBuiltIn_Chr(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
var
  ParamResolved: TPasResolverResult;
  Param: TPasExpr;
begin
  Result:=nil;
  if AContext.Resolver=nil then
    RaiseInconsistency(20170325185847,El);
  Param:=El.Params[0];
  AContext.Resolver.ComputeElement(Param,ParamResolved,[]);
  if ParamResolved.BaseType in btAllJSInteger then
    begin
    // chr(integer) -> String.fromCharCode(integer)
    Result:=ConvertElement(Param,AContext);
    // Note: convert Param first, as it might raise an exception
    Result:=CreateCallFromCharCode(Result,El);
    exit;
    end;
  DoError(20170325185906,nXExpectedButYFound,sXExpectedButYFound,['integer',
    AContext.Resolver.GetResolverResultDescription(ParamResolved)],Param);
end;

function TPasToJSConverter.ConvertBuiltIn_Ord(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
var
  ParamResolved, SubParamResolved: TPasResolverResult;
  Param, SubParam: TPasExpr;
  Call: TJSCallExpression;
  SubParams: TParamsExpr;
  SubParamJS: TJSElement;
  Minus: TJSAdditiveExpressionMinus;
  Add: TJSAdditiveExpressionPlus;
begin
  Result:=nil;
  if AContext.Resolver=nil then
    RaiseInconsistency(20170210105235,El);
  Param:=El.Params[0];
  AContext.Resolver.ComputeElement(Param,ParamResolved,[]);
  if ParamResolved.BaseType=btChar then
    begin
    if Param is TParamsExpr then
      begin
      SubParams:=TParamsExpr(Param);
      if SubParams.Kind=pekArrayParams then
        begin
        // e.g. ord(something[index])
        SubParam:=SubParams.Value;
        AContext.Resolver.ComputeElement(SubParam,SubParamResolved,[]);
        if SubParamResolved.BaseType in btAllJSStrings then
          begin
          // e.g. ord(aString[index]) -> aString.charCodeAt(index-1)
          SubParamJS:=ConvertElement(SubParam,AContext);
          // Note: convert SubParam first, as it might raise an exception
          Call:=nil;
          try
            Call:=CreateCallExpression(El);
            Call.Expr:=CreateDotExpression(El,SubParamJS,
                        CreatePrimitiveDotExpr('charCodeAt',El));
            Minus:=TJSAdditiveExpressionMinus(CreateElement(TJSAdditiveExpressionMinus,Param));
            Call.AddArg(Minus);
            if length(SubParams.Params)<>1 then
              RaiseInconsistency(20170405231706,El);
            Minus.A:=ConvertElement(SubParams.Params[0],AContext);
            Minus.B:=CreateLiteralNumber(Param,1);
            Result:=Call;
          finally
            if Result=nil then
              Call.Free;
          end;
          exit;
          end;
        end;
      end;
    // ord(aChar) -> aChar.charCodeAt()
    Result:=ConvertElement(Param,AContext);
    // Note: convert Param first, as it might raise an exception
    Result:=CreateCallCharCodeAt(Result,0,El);
    exit;
    end
  else if ParamResolved.BaseType in btAllBooleans then
    begin
    // ord(bool) ->  bool+0
    Result:=ConvertElement(Param,AContext);
    // Note: convert Param first, as it might raise an exception
    Add:=TJSAdditiveExpressionPlus(CreateElement(TJSAdditiveExpressionPlus,El));
    Add.A:=Result;
    Add.B:=CreateLiteralNumber(El,0);
    Result:=Add;
    exit;
    end
  else if ParamResolved.BaseType=btContext then
    begin
    if ParamResolved.TypeEl.ClassType=TPasEnumType then
      begin
      // ord(enum) -> enum
      Result:=ConvertElement(Param,AContext);
      exit;
      end;
    end;
  DoError(20170210105339,nXExpectedButYFound,sXExpectedButYFound,['enum',
    AContext.Resolver.GetResolverResultDescription(ParamResolved)],Param);
end;

function TPasToJSConverter.ConvertBuiltIn_LowHigh(El: TParamsExpr;
  AContext: TConvertContext; IsLow: boolean): TJSElement;
// low(enumtype) -> first enumvalue
// high(enumtype) -> last enumvalue
// low(set var) -> first enumvalue
// high(set var) -> last enumvalue
// low(settype) -> first enumvalue
// high(settype) -> last enumvalue
// low(array var) -> first index
// high(dynamic array) -> array.length-1
// high(static array) -> last index

  procedure CreateEnumValue(TypeEl: TPasEnumType);
  var
    EnumValue: TPasEnumValue;
  begin
    if IsLow then
      EnumValue:=TPasEnumValue(TypeEl.Values[0])
    else
      EnumValue:=TPasEnumValue(TypeEl.Values[TypeEl.Values.Count-1]);
    Result:=CreateReferencePathExpr(EnumValue,AContext);
  end;

var
  ResolvedEl: TPasResolverResult;
  Param: TPasExpr;
  TypeEl: TPasType;
  Ranges: TPasExprArray;
  Value: TResEvalValue;
  Call: TJSCallExpression;
  MinusExpr: TJSAdditiveExpressionMinus;
  MinVal, MaxVal: MaxPrecInt;
begin
  Result:=nil;
  if AContext.Resolver=nil then
    RaiseInconsistency(20170210120659,El);
  Param:=El.Params[0];
  AContext.Resolver.ComputeElement(Param,ResolvedEl,[]);
  case ResolvedEl.BaseType of
    btContext:
      begin
      TypeEl:=ResolvedEl.TypeEl;
      if TypeEl.ClassType=TPasEnumType then
        begin
        CreateEnumValue(TPasEnumType(TypeEl));
        exit;
        end
      else if (TypeEl.ClassType=TPasSetType) then
        begin
        if TPasSetType(TypeEl).EnumType<>nil then
          begin
          TypeEl:=TPasSetType(TypeEl).EnumType;
          CreateEnumValue(TPasEnumType(TypeEl));
          exit;
          end;
        end
      else if TypeEl.ClassType=TPasArrayType then
        begin
        Ranges:=TPasArrayType(TypeEl).Ranges;
        if IsLow then
          begin
          // low(arr)
          if length(Ranges)=0 then
            begin
            // dynamic array starts at 0
            Result:=CreateLiteralNumber(El,0);
            exit;
            end
          else
            begin
            // static array
            Value:=AContext.Resolver.EvalRangeLimit(Ranges[0],[refConst],true,El);
            if Value=nil then
              RaiseNotSupported(El,AContext,20170910160817);
            try
              Result:=ConvertConstValue(Value,AContext,Param);
            finally
              ReleaseEvalValue(Value);
            end;
            exit;
            end;
          end
        else
          begin
          // high(arr)
          if length(Ranges)=0 then
            begin
            // dynamic array -> rtl.length(Param)-1
            Result:=ConvertElement(Param,AContext);
            // Note: convert Param first, it may raise an exception
            Call:=CreateCallExpression(El);
            Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnArray_Length]]);
            Call.AddArg(Result);
            MinusExpr:=TJSAdditiveExpressionMinus(CreateElement(TJSAdditiveExpressionMinus,El));
            MinusExpr.A:=Call;
            MinusExpr.B:=CreateLiteralNumber(El,1);
            Result:=MinusExpr;
            exit;
            end
          else
            begin
            // static array
            Value:=AContext.Resolver.EvalRangeLimit(Ranges[0],[refConst],false,El);
            if Value=nil then
              RaiseNotSupported(El,AContext,20170910161555);
            try
              Result:=ConvertConstValue(Value,AContext,Param);
            finally
              ReleaseEvalValue(Value);
            end;
            exit;
            end;
          end;
        end;
      end;
    btBoolean,btByteBool,btWordBool,btLongBool:
      begin
      if IsLow then
        Result:=CreateLiteralBoolean(El,LowJSBoolean)
      else
        Result:=CreateLiteralBoolean(El,HighJSBoolean);
      exit;
      end;
    btChar,
    btWideChar:
      begin
      if IsLow then
        Result:=CreateLiteralJSString(El,#0)
      else
        Result:=CreateLiteralJSString(El,#$ffff);
      exit;
      end;
    btByte..btInt64:
      begin
      TypeEl:=AContext.Resolver.ResolveAliasType(ResolvedEl.TypeEl);
      if TypeEl.ClassType=TPasUnresolvedSymbolRef then
        begin
        if TypeEl.CustomData is TResElDataBaseType then
          begin
          AContext.Resolver.GetIntegerRange(ResolvedEl.BaseType,MinVal,MaxVal);
          if IsLow then
            Result:=CreateLiteralNumber(El,MinVal)
          else
            Result:=CreateLiteralNumber(El,MaxVal);
          exit;
          end;
        end
      else if TypeEl.ClassType=TPasRangeType then
        begin
        Value:=AContext.Resolver.EvalRangeLimit(TPasRangeType(TypeEl).RangeExpr,
                                                [refConst],IsLow,El);
        try
          case Value.Kind of
          revkInt:
            Result:=CreateLiteralNumber(El,TResEvalInt(Value).Int);
          revkUInt:
            Result:=CreateLiteralNumber(El,TResEvalUInt(Value).UInt);
          else
            RaiseNotSupported(El,AContext,20170925214317);
          end;
          exit;
        finally
          ReleaseEvalValue(Value);
        end;
        end;
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.ConvertBuiltIn_LowHigh ',GetResolverResultDbg(ResolvedEl));
      {$ENDIF}
      RaiseNotSupported(El,AContext,20170925214351);
      end;
    btSet:
      begin
      TypeEl:=ResolvedEl.TypeEl;
      if TypeEl.ClassType=TPasEnumType then
        begin
        CreateEnumValue(TPasEnumType(TypeEl));
        exit;
        end;
      end;
  end;
  DoError(20170210110717,nXExpectedButYFound,sXExpectedButYFound,['enum or array',
    AContext.Resolver.GetResolverResultDescription(ResolvedEl)],Param);
end;

function TPasToJSConverter.ConvertBuiltIn_PredSucc(El: TParamsExpr;
  AContext: TConvertContext; IsPred: boolean): TJSElement;
// pred(enumvalue) -> enumvalue-1
// succ(enumvalue) -> enumvalue+1
var
  ResolvedEl: TPasResolverResult;
  Param: TPasExpr;
  V: TJSElement;
  Expr: TJSAdditiveExpression;
begin
  Result:=nil;
  if AContext.Resolver=nil then
    RaiseInconsistency(20170210120648,El);
  Param:=El.Params[0];
  AContext.Resolver.ComputeElement(Param,ResolvedEl,[]);
  if (ResolvedEl.BaseType in btAllJSInteger)
      or ((ResolvedEl.BaseType=btContext)
        and (ResolvedEl.TypeEl.ClassType=TPasEnumType)) then
    begin
    V:=ConvertElement(Param,AContext);
    if IsPred then
      Expr:=TJSAdditiveExpressionMinus(CreateElement(TJSAdditiveExpressionMinus,El))
    else
      Expr:=TJSAdditiveExpressionPlus(CreateElement(TJSAdditiveExpressionPlus,El));
    Expr.A:=V;
    Expr.B:=CreateLiteralNumber(El,1);
    Result:=Expr;
    exit;
    end
  else if ResolvedEl.BaseType in btAllJSBooleans then
    begin
    if IsPred then
      Result:=CreateLiteralBoolean(El,false)
    else
      Result:=CreateLiteralBoolean(El,true);
    exit;
    end;
  DoError(20170210120039,nXExpectedButYFound,sXExpectedButYFound,['enum',
    AContext.Resolver.GetResolverResultDescription(ResolvedEl)],Param);
end;

function TPasToJSConverter.ConvertBuiltIn_StrProc(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
// convert 'str(value,aString)' to 'aString = <string>'
// for the conversion see ConvertBuiltInStrParam
var
  AssignContext: TAssignContext;
  StrVar: TPasExpr;
begin
  Result:=nil;
  AssignContext:=TAssignContext.Create(El,nil,AContext);
  try
    StrVar:=El.Params[1];
    AContext.Resolver.ComputeElement(StrVar,AssignContext.LeftResolved,[rcNoImplicitProc]);

    // create right side
    AssignContext.RightSide:=ConvertBuiltInStrParam(El.Params[0],AContext,false,true);
    SetResolverValueExpr(AssignContext.RightResolved,btString,
      AContext.Resolver.BaseTypes[btString],El,[rrfReadable]);

    // create 'StrVar = rightside'
    Result:=CreateAssignStatement(StrVar,AssignContext);
  finally
    AssignContext.RightSide.Free;
    AssignContext.Free;
  end;
end;

function TPasToJSConverter.ConvertBuiltIn_StrFunc(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
// convert 'str(boolean)' to '""+boolean'
// convert 'str(integer)' to '""+integer'
// convert 'str(float)' to '""+float'
// convert 'str(float:width)' to rtl.spaceLeft('""+float,width)'
// convert 'str(float:width:precision)' to 'rtl.spaceLeft(float.toFixed(precision),width)'
var
  i: Integer;
  Param: TPasExpr;
  Sum, Add: TJSElement;
  AddEl: TJSAdditiveExpressionPlus;
begin
  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.ConvertBuiltInStrFunc Count=',length(El.Params));
  {$ENDIF}
  Result:=nil;
  Sum:=nil;
  Add:=nil;
  try
    for i:=0 to length(El.Params)-1 do
      begin
      Param:=El.Params[i];
      Add:=ConvertBuiltInStrParam(Param,AContext,true,i=0);
      if Sum=nil then
        Sum:=Add
      else
        begin
        AddEl:=TJSAdditiveExpressionPlus(CreateElement(TJSAdditiveExpressionPlus,Param));
        AddEl.A:=Sum;
        AddEl.B:=Add;
        Sum:=AddEl;
        end;
      Add:=nil;
      end;
    Result:=Sum;
  finally
    Add.Free;
    if Result=nil then
      Sum.Free;
  end;
end;

function TPasToJSConverter.ConvertBuiltInStrParam(El: TPasExpr;
  AContext: TConvertContext; IsStrFunc, IsFirst: boolean): TJSElement;
var
  ResolvedEl: TPasResolverResult;
  NeedStrLit: Boolean;
  Add: TJSElement;
  Call: TJSCallExpression;
  PlusEl: TJSAdditiveExpressionPlus;
  Bracket: TJSBracketMemberExpression;

  procedure PrependStrLit;
  begin
    PlusEl:=TJSAdditiveExpressionPlus(CreateElement(TJSAdditiveExpressionPlus,El));
    PlusEl.A:=CreateLiteralString(El,'');
    PlusEl.B:=Add;
    Add:=PlusEl;
  end;

begin
  Result:=nil;
  AContext.Resolver.ComputeElement(El,ResolvedEl,[]);
  Add:=nil;
  Call:=nil;
  Bracket:=nil;
  try
    NeedStrLit:=false;
    if ResolvedEl.BaseType in (btAllJSBooleans+btAllJSInteger) then
      begin
      NeedStrLit:=true;
      Add:=ConvertElement(El,AContext);
      end
    else if ResolvedEl.BaseType in btAllJSFloats then
      begin
      // convert to rtl.floatToStr(El,width,precision)
      Call:=CreateCallExpression(El);
      Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnFloatToStr]]);
      Call.AddArg(ConvertElement(El,AContext));
      if El.format1<>nil then
        Call.AddArg(ConvertElement(El.format1,AContext));
      if El.format2<>nil then
        Call.AddArg(ConvertElement(El.format2,AContext));
      Result:=Call;
      Call:=nil;
      exit;
      end
    else if IsStrFunc and (ResolvedEl.BaseType in btAllJSStringAndChars) then
      Add:=ConvertElement(El,AContext)
    else if ResolvedEl.BaseType=btContext then
      begin
      if ResolvedEl.TypeEl.ClassType=TPasEnumType then
        begin
        // create enumtype[enumvalue]
        Bracket:=TJSBracketMemberExpression(CreateElement(TJSBracketMemberExpression,El));
        Bracket.MExpr:=CreateReferencePathExpr(TPasEnumType(ResolvedEl.TypeEl),AContext);
        Bracket.Name:=ConvertElement(El,AContext);
        Add:=Bracket;
        Bracket:=nil;
        end
      else
        RaiseNotSupported(El,AContext,20170320123827);
      end
    else
      RaiseNotSupported(El,AContext,20170320093001);

    if El.format1<>nil then
      begin
      // width -> leading spaces
      if NeedStrLit then
        PrependStrLit;
      // create 'rtl.spaceLeft(add,width)'
      Call:=CreateCallExpression(El);
      Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnSpaceLeft]]);
      Call.AddArg(Add);
      Add:=nil;
      Call.AddArg(ConvertElement(El.format1,AContext));
      Add:=Call;
      Call:=nil;
      end
    else if IsFirst and NeedStrLit then
      PrependStrLit;
    Result:=Add;
  finally
    Call.Free;
    Bracket.Free;
    if Result=nil then
      Add.Free;
  end;
end;

function TPasToJSConverter.ConvertBuiltIn_ConcatArray(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
// concat(array1, array2)
var
  Param0Resolved, ElTypeResolved: TPasResolverResult;
  Param0: TPasExpr;
  ArrayType: TPasArrayType;
  Call: TJSCallExpression;
  i: Integer;
begin
  if length(El.Params)<1 then
    RaiseInconsistency(20170331000332,El);
  if length(El.Params)=1 then
    begin
    // concat(array1)  ->  array1
    {$IFDEF VerbosePas2JS}
    writeln('TPasToJSConverter.ConvertBuiltInConcatArray Count=',length(El.Params));
    {$ENDIF}
    Result:=ConvertElement(El.Params[0],AContext);
    end
  else
    begin
    // concat(array1,array2,...)
    Param0:=El.Params[0];
    AContext.Resolver.ComputeElement(Param0,Param0Resolved,[]);
    if Param0Resolved.BaseType<>btContext then
      RaiseNotSupported(Param0,AContext,20170331000819);
    if Param0Resolved.TypeEl.ClassType<>TPasArrayType then
      RaiseNotSupported(Param0,AContext,20170331000846);
    ArrayType:=TPasArrayType(Param0Resolved.TypeEl);
    if length(ArrayType.Ranges)>0 then
      RaiseNotSupported(Param0,AContext,20170331001021);
    AContext.Resolver.ComputeElement(ArrayType.ElType,ElTypeResolved,[rcType]);
    Call:=CreateCallExpression(El);
    try
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.ConvertBuiltInConcatArray Count=',length(El.Params),' ElType=',GetResolverResultDbg(ElTypeResolved));
      {$ENDIF}
      if ElTypeResolved.BaseType=btContext then
        begin
        if ElTypeResolved.TypeEl.ClassType=TPasRecordType then
          begin
          // record: rtl.arrayConcat(RecordType,array1,array2,...)
          Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnArray_Concat]]);
          Call.AddArg(CreateReferencePathExpr(ElTypeResolved.TypeEl,AContext));
          end;
        end
      else if ElTypeResolved.BaseType=btSet then
        begin
        // set: rtl.arrayConcat("refSet",array1,array2,...)
        Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnArray_Concat]]);
        Call.AddArg(CreateLiteralString(El,FBuiltInNames[pbifnSet_Reference]));
        end;
      if Call.Expr=nil then
        // default: array1.concat(array2,...)
        Call.Expr:=CreateDotExpression(El,ConvertElement(Param0,AContext),
                                     CreatePrimitiveDotExpr('concat',El));
      for i:=1 to length(El.Params)-1 do
        Call.AddArg(ConvertElement(El.Params[i],AContext));
      Result:=Call;
    finally
      if Result=nil then
        Call.Free;
    end;
    end;
end;

function TPasToJSConverter.ConvertBuiltIn_CopyArray(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
var
  Param: TPasExpr;
  ParamResolved, ElTypeResolved: TPasResolverResult;
  C: TClass;
  TypeParam: TJSElement;
  Call: TJSCallExpression;
  ArrayType: TPasArrayType;
begin
  Result:=nil;
  Call:=nil;
  try
    Param:=El.Params[0];
    AContext.Resolver.ComputeElement(El,ParamResolved,[]);
    if ParamResolved.BaseType<>btContext then
      RaiseInconsistency(20170401003242,El);
    if ParamResolved.TypeEl.ClassType<>TPasArrayType then
      RaiseInconsistency(20170401003256,El);
    ArrayType:=TPasArrayType(ParamResolved.TypeEl);
    AContext.Resolver.ComputeElement(ArrayType.ElType,ElTypeResolved,[rcType]);
    // rtl.arrayCopy(type,src,start,count)
    TypeParam:=nil;
    if ElTypeResolved.BaseType=btContext then
      begin
      C:=ElTypeResolved.TypeEl.ClassType;
      if C=TPasRecordType then
        TypeParam:=CreateReferencePathExpr(TPasRecordType(ElTypeResolved.TypeEl),AContext);
      end
    else if ElTypeResolved.BaseType=btSet then
      TypeParam:=CreateLiteralString(El,FBuiltInNames[pbifnSet_Reference]);
    if TypeParam=nil then
      TypeParam:=CreateLiteralNumber(El,0);
    Call:=CreateCallExpression(El);
    // rtl.arrayCopy
    Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnArray_Copy]]);
    // param: type
    Call.AddArg(TypeParam);
    // param: src
    Call.AddArg(ConvertElement(Param,AContext));
    // param: start
    if length(El.Params)=1 then
      Call.AddArg(CreateLiteralNumber(El,0))
    else
      Call.AddArg(ConvertElement(El.Params[1],AContext));
    // param: count
    if length(El.Params)>=3 then
      Call.AddArg(ConvertElement(El.Params[2],AContext));
    Result:=Call;
  finally
    if Result=nil then
      Call.Free;
  end;

  if El=nil then ;
  if AContext=nil then;
end;

function TPasToJSConverter.ConvertBuiltIn_InsertArray(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
// procedure insert(item,var array,const position)
// ->  array.splice(position,0,item);
var
  ArrEl: TJSElement;
  Call: TJSCallExpression;
begin
  Result:=nil;
  Call:=nil;
  try
    Call:=CreateCallExpression(El);
    ArrEl:=ConvertElement(El.Params[1],AContext);
    Call.Expr:=CreateDotExpression(El,ArrEl,CreatePrimitiveDotExpr('splice',El));
    Call.AddArg(ConvertElement(El.Params[2],AContext));
    Call.AddArg(CreateLiteralNumber(El,0));
    Call.AddArg(ConvertElement(El.Params[0],AContext));
    Result:=Call;
  finally
    if Result=nil then
      Call.Free;
  end;
end;

function TPasToJSConverter.ConvertBuiltIn_DeleteArray(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
// proc delete(var array,const start,count)
// ->  array.splice(start,count)
var
  ArrEl: TJSElement;
  Call: TJSCallExpression;
begin
  Result:=nil;
  Call:=nil;
  try
    Call:=CreateCallExpression(El);
    ArrEl:=ConvertElement(El.Params[0],AContext);
    Call.Expr:=CreateDotExpression(El,ArrEl,CreatePrimitiveDotExpr('splice',El));
    Call.AddArg(ConvertElement(El.Params[1],AContext));
    Call.AddArg(ConvertElement(El.Params[2],AContext));
    Result:=Call;
  finally
    if Result=nil then
      Call.Free;
  end;
end;

function TPasToJSConverter.ConvertBuiltIn_TypeInfo(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
var
  ParamResolved: TPasResolverResult;
  Param: TPasExpr;
  ResultEl: TPasResultElement;
  TypeEl: TPasType;
begin
  Result:=nil;
  Param:=El.Params[0];
  AContext.Resolver.ComputeElement(Param,ParamResolved,[rcNoImplicitProc]);
  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.ConvertBuiltIn_TypeInfo ',GetResolverResultDbg(ParamResolved));
  {$ENDIF}
  if (ParamResolved.BaseType=btProc) and (ParamResolved.IdentEl is TPasFunction) then
    begin
    // typeinfo(function) ->
    ResultEl:=TPasFunction(ParamResolved.IdentEl).FuncType.ResultEl;
    AContext.Resolver.ComputeElement(ResultEl.ResultType,ParamResolved,[rcNoImplicitProc]);
    {$IFDEF VerbosePas2JS}
    writeln('TPasToJSConverter.ConvertBuiltIn_TypeInfo FuncResult=',GetResolverResultDbg(ParamResolved));
    {$ENDIF}
    Include(ParamResolved.Flags,rrfReadable);
    ParamResolved.IdentEl:=ResultEl;
    end;
  TypeEl:=AContext.Resolver.ResolveAliasType(ParamResolved.TypeEl);
  if TypeEl=nil then
    RaiseNotSupported(El,AContext,20170413001544)
  else if ParamResolved.IdentEl is TPasType then
    Result:=CreateTypeInfoRef(TPasType(ParamResolved.IdentEl),AContext,Param)
  else if (rrfReadable in ParamResolved.Flags)
      and ((TypeEl.ClassType=TPasClassType)
        or (TypeEl.ClassType=TPasClassOfType))
      and ((ParamResolved.IdentEl is TPasVariable)
        or (ParamResolved.IdentEl.ClassType=TPasArgument)
        or (ParamResolved.IdentEl.ClassType=TPasResultElement)) then
    begin
    // typeinfo(classinstance) -> classinstance.$rtti
    // typeinfo(classof) -> classof.$rtti
    Result:=ConvertElement(Param,AContext);
    Result:=CreateDotExpression(El,Result,CreatePrimitiveDotExpr(FBuiltInNames[pbivnRTTI],Param));
    end
  else
    Result:=CreateTypeInfoRef(TypeEl,AContext,Param);
end;

function TPasToJSConverter.ConvertBuiltIn_Assert(El: TParamsExpr;
  AContext: TConvertContext): TJSElement;
// throw pas.SysUtils.EAssertionFailed.$create("Create");
// throw pas.SysUtils.EAssertionFailed.$create("Create$1",["text"]);
// throw "text"
var
  IfSt: TJSIfStatement;
  ThrowSt: TJSThrowStatement;
  ModScope: TPasModuleScope;
  aConstructor: TPasConstructor;
  Ref: TResolvedReference;
  ArrLit: TJSArrayLiteral;
  Call: TJSCallExpression;
  FunName: String;
  PosEl: TPasExpr;
begin
  Result:=nil;

  // check if assertions are enabled
  if not (bsAssertions in AContext.ScannerBoolSwitches) then
    exit;

  Ref:=nil;
  IfSt:=TJSIfStatement(CreateElement(TJSIfStatement,El));
  try
    PosEl:=El.Params[0];
    IfSt.Cond:=ConvertExpression(El.Params[0],AContext);
    ThrowSt:=TJSThrowStatement(CreateElement(TJSThrowStatement,PosEl));
    IfSt.BTrue:=ThrowSt;

    // using sysutils.EAssertionFailed if available
    aConstructor:=nil;
    if El.CustomData is TResolvedReference then
      begin
      Ref:=TResolvedReference(El.CustomData);
      if Ref.Declaration is TPasConstructor then
        aConstructor:=TPasConstructor(Ref.Declaration);
      Ref:=nil;
      end;
    //writeln('TPasToJSConverter.ConvertBuiltIn_Assert ',GetObjName(aConstructor));
    if aConstructor<>nil then
      begin
      Ref:=TResolvedReference.Create;
      ModScope:=El.GetModule.CustomData as TPasModuleScope;
      Ref.Declaration:=ModScope.AssertClass;
      // pas.sysutils.EAssertionFailed
      FunName:=CreateReferencePath(ModScope.AssertClass,AContext,rpkPathAndName,true,Ref);
      // append .$create('Create')
      FunName:=FunName+'.'+FBuiltInNames[pbifnClassInstanceNew];
      Call:=CreateCallExpression(PosEl);
      Call.Expr:=CreatePrimitiveDotExpr(FunName,PosEl);
      // parameter: "Create"
      Call.AddArg(CreateLiteralString(PosEl,TransformVariableName(aConstructor,AContext)));
      ThrowSt.A:=Call;
      if length(El.Params)>1 then
        begin
        // add [msg]
        ArrLit:=TJSArrayLiteral(CreateElement(TJSArrayLiteral,El.Params[1]));
        Call.AddArg(ArrLit);
        ArrLit.AddElement(ConvertExpression(El.Params[1],AContext));
        end;
      end;
    if ThrowSt.A=nil then
      begin
      // fallback: throw msg
      if length(El.Params)>1 then
        ThrowSt.A:=ConvertExpression(El.Params[1],AContext)
      else
        ThrowSt.A:=CreateLiteralJSString(El.Params[0],'assert failed');
      end;
    Result:=IfSt;
  finally
    Ref.Free;
    if Result=nil then
      IfSt.Free;
  end;
end;

function TPasToJSConverter.ConvertRecordValues(El: TRecordValues;
  AContext: TConvertContext): TJSElement;

Var
  R :  TJSObjectLiteral;
  I : Integer;
  It : TRecordValuesItem;
  rel : TJSObjectLiteralElement;

begin
  R:=TJSObjectLiteral(CreateElement(TJSObjectLiteral,El));
  For I:=0 to Length(El.Fields)-1 do
    begin
    it:=El.Fields[i];
    Rel:=R.Elements.AddElement;
    Rel.Name:=TJSString(it.Name);
    Rel.Expr:=ConvertElement(it.ValueExp,AContext);
    end;
  Result:=R;
end;

function TPasToJSConverter.ConvertArrayValues(El: TArrayValues;
  AContext: TConvertContext): TJSElement;
Var
  ArrLit :  TJSArrayLiteral;
  I : Integer;
begin
  ArrLit:=TJSArrayLiteral(CreateElement(TJSArrayLiteral,El));
  For I:=0 to Length(El.Values)-1 do
    begin
    ArrLit.AddElement(ConvertElement(El.Values[i],AContext));
    end;
  Result:=ArrLit;
end;

function TPasToJSConverter.ConvertExpression(El: TPasExpr;
  AContext: TConvertContext): TJSElement;
begin
  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.ConvertExpression El=',GetObjName(El),' Context=',GetObjName(AContext));
  {$ENDIF}
  Result:=Nil;
  if (El.ClassType=TUnaryExpr) then
    Result:=ConvertUnaryExpression(TUnaryExpr(El),AContext)
  else if (El.ClassType=TBinaryExpr) then
    Result:=ConvertBinaryExpression(TBinaryExpr(El),AContext)
  else if (El.ClassType=TPrimitiveExpr) then
    Result:=ConvertPrimitiveExpression(TPrimitiveExpr(El),AContext)
  else if (El.ClassType=TBoolConstExpr) then
    Result:=ConvertBoolConstExpression(TBoolConstExpr(El),AContext)
  else if (El.ClassType=TNilExpr) then
    Result:=ConvertNilExpr(TNilExpr(El),AContext)
  else if (El.ClassType=TInheritedExpr) then
    Result:=ConvertInheritedExpression(TInheritedExpr(El),AContext)
  else if (El.ClassType=TSelfExpr) then
    Result:=ConvertSelfExpression(TSelfExpr(El),AContext)
  else if (El.ClassType=TParamsExpr) then
    Result:=ConvertParamsExpression(TParamsExpr(El),AContext)
  else if (El.ClassType=TRecordValues) then
    Result:=ConvertRecordValues(TRecordValues(El),AContext)
  else if (El.ClassType=TArrayValues) then
    Result:=ConvertArrayValues(TArrayValues(El),AContext)
  else
    RaiseNotSupported(El,AContext,20161024191314);
end;

function TPasToJSConverter.CreatePrimitiveDotExpr(AName: string;
  Src: TPasElement): TJSElement;
var
  p: Integer;
  DotExpr: TJSDotMemberExpression;
  Ident: TJSPrimaryExpressionIdent;
begin
  if AName='' then
    RaiseInconsistency(20170402230134,Src);
  p:=PosLast('.',AName);
  if p>0 then
    begin
    if Src<>nil then
      DotExpr:=TJSDotMemberExpression(CreateElement(TJSDotMemberExpression,Src))
    else
      DotExpr:=TJSDotMemberExpression.Create(0,0);
    DotExpr.Name:=TJSString(copy(AName,p+1,length(AName))); // do not lowercase
    DotExpr.MExpr:=CreatePrimitiveDotExpr(LeftStr(AName,p-1),Src);
    Result:=DotExpr;
    end
  else
    begin
    if Src<>nil then
      Ident:=TJSPrimaryExpressionIdent(CreateElement(TJSPrimaryExpressionIdent,Src))
    else
      Ident:=TJSPrimaryExpressionIdent.Create(0,0);
    Ident.Name:=TJSString(AName); // do not lowercase
    Result:=Ident;
    end;
end;

function TPasToJSConverter.CreateTypeDecl(El: TPasType;
  AContext: TConvertContext): TJSElement;

var
  C: TClass;
begin
  Result:=Nil;
  C:=El.ClassType;
  if C=TPasClassType then
    Result := ConvertClassType(TPasClassType(El), AContext)
  else if (C=TPasClassOfType) then
    Result := ConvertClassOfType(TPasClassOfType(El), AContext)
  else if C=TPasRecordType then
    Result := ConvertRecordType(TPasRecordType(El), AContext)
  else if C=TPasEnumType then
    Result := ConvertEnumType(TPasEnumType(El), AContext)
  else if (C=TPasSetType) then
    Result := ConvertSetType(TPasSetType(El), AContext)
  else if (C=TPasRangeType) then
    Result:=ConvertRangeType(TPasRangeType(El),AContext)
  else if (C=TPasAliasType) then
  else if (C=TPasPointerType) then
    Result:=ConvertPointerType(TPasPointerType(El),AContext)
  else if (C=TPasProcedureType)
       or (C=TPasFunctionType) then
    Result:=ConvertProcedureType(TPasProcedureType(El),AContext)
  else if (C=TPasArrayType) then
    Result:=ConvertArrayType(TPasArrayType(El),AContext)
  else
    begin
    {$IFDEF VerbosePas2JS}
    writeln('TPasToJSConverter.CreateTypeDecl El=',GetObjName(El));
    {$ENDIF}
    RaiseNotSupported(El,AContext,20170208144053);
    end;
end;

function TPasToJSConverter.CreateVarDecl(El: TPasVariable;
  AContext: TConvertContext): TJSElement;

Var
  C : TJSElement;
  V : TJSVariableStatement;
  AssignSt: TJSSimpleAssignStatement;
  Obj: TJSObjectLiteral;
  ObjLit: TJSObjectLiteralElement;
begin
  Result:=nil;
  if El.AbsoluteExpr<>nil then
    exit; // absolute: do not add a declaration
  if vmExternal in El.VarModifiers then
    exit; // external: do not add a declaration
  if AContext is TObjectContext then
    begin
    // create 'A: initvalue'
    Obj:=TObjectContext(AContext).JSElement as TJSObjectLiteral;
    ObjLit:=Obj.Elements.AddElement;
    ObjLit.Name:=TJSString(TransformVariableName(El,AContext));
    ObjLit.Expr:=CreateVarInit(El,AContext);
    end
  else if AContext.IsGlobal then
    begin
    // create 'this.A=initvalue'
    AssignSt:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,El));
    Result:=AssignSt;
    AssignSt.LHS:=CreateSubDeclNameExpr(El,El.Name,AContext);
    AssignSt.Expr:=CreateVarInit(El,AContext);
    end
  else
    begin
    // create 'var A=initvalue'
    C:=ConvertVariable(El,AContext);
    V:=TJSVariableStatement(CreateElement(TJSVariableStatement,El));
    V.A:=C;
    Result:=V;
    end;
end;

function TPasToJSConverter.CreateSwitchStatement(El: TPasImplCaseOf;
  AContext: TConvertContext): TJSElement;
var
  SwitchEl: TJSSwitchStatement;
  JSCaseEl: TJSCaseElement;
  SubEl: TPasImplElement;
  St: TPasImplCaseStatement;
  ok: Boolean;
  i, j: Integer;
  BreakSt: TJSBreakStatement;
  BodySt: TJSElement;
  StList: TJSStatementList;
  Expr: TPasExpr;
begin
  Result:=nil;
  SwitchEl:=TJSSwitchStatement(CreateElement(TJSSwitchStatement,El));
  ok:=false;
  try
    SwitchEl.Cond:=ConvertExpression(El.CaseExpr,AContext);
    for i:=0 to El.Elements.Count-1 do
      begin
      SubEl:=TPasImplElement(El.Elements[i]);
      if not (SubEl is TPasImplCaseStatement) then
        continue;
      St:=TPasImplCaseStatement(SubEl);
      JSCaseEl:=nil;
      for j:=0 to St.Expressions.Count-1 do
        begin
        Expr:=TPasExpr(St.Expressions[j]);
        JSCaseEl:=SwitchEl.Cases.AddCase;
        JSCaseEl.Expr:=ConvertExpression(Expr,AContext);
        end;
      BodySt:=nil;
      if St.Body<>nil then
        BodySt:=ConvertElement(St.Body,AContext);
      // add break
      BreakSt:=TJSBreakStatement(CreateElement(TJSBreakStatement,St));
      if BodySt=nil then
        // no Pascal statement -> add only one 'break;'
        BodySt:=BreakSt
      else
        begin
        if (BodySt is TJSStatementList) then
          begin
          // list of statements -> append 'break;' to end
          StList:=TJSStatementList(BodySt);
          AddToStatementList(TJSStatementList(BodySt),StList,BreakSt,St);
          end
        else
          begin
          // single statement -> create list of old and 'break;'
          StList:=TJSStatementList(CreateElement(TJSStatementList,St));
          StList.A:=BodySt;
          StList.B:=BreakSt;
          BodySt:=StList;
          end;
        end;
      JSCaseEl.Body:=BodySt;
      end;
    if El.ElseBranch<>nil then
      begin
      JSCaseEl:=SwitchEl.Cases.AddCase;
      JSCaseEl.Body:=ConvertImplBlockElements(El.ElseBranch,AContext,false);
      SwitchEl.TheDefault:=JSCaseEl;
      end;
    ok:=true;
  finally
    if not ok then
      SwitchEl.Free;
  end;
  Result:=SwitchEl;
end;

function TPasToJSConverter.ConvertDeclarations(El: TPasDeclarations;
  AContext: TConvertContext): TJSElement;

Var
  E : TJSElement;
  SLFirst, SLLast: TJSStatementList;
  P: TPasElement;
  IsProcBody, IsFunction, IsAssembler, HasResult: boolean;
  I : Integer;
  PasProc: TPasProcedure;
  ProcScope: TPasProcedureScope;
  ProcBody: TPasImplBlock;
  ResultEl: TPasResultElement;
  ResultVarName: String;
  C: TClass;
  ResStrVarEl: TJSVarDeclaration;
  ResStrVarElAdd: boolean;

  Procedure Add(NewEl: TJSElement; PosEl: TPasElement);
  begin
    if AContext is TObjectContext then
      begin
      // NewEl is already added
      end
    else if AContext.IsGlobal and (AContext.JSElement is TJSSourceElements) then
      AddToSourceElements(TJSSourceElements(AContext.JSElement),NewEl)
    else
      begin
      AddToStatementList(SLFirst,SLLast,NewEl,PosEl);
      ConvertDeclarations:=SLFirst;
      end;
  end;

  Procedure AddFunctionResultInit;
  var
    VarSt: TJSVariableStatement;
    PasFun: TPasFunction;
    FunType: TPasFunctionType;
    SrcEl: TPasElement;
    Scope: TPas2JSProcedureScope;
  begin
    PasFun:=El.Parent as TPasFunction;
    FunType:=PasFun.FuncType;
    ResultEl:=FunType.ResultEl;
    Scope:=PasFun.CustomData as TPas2JSProcedureScope;
    if Scope.ResultVarName<>'' then
      ResultVarName:=Scope.ResultVarName
    else
      ResultVarName:=ResolverResultVar;

    // add 'var result=initvalue'
    SrcEl:=ResultEl;
    VarSt:=CreateVarStatement(ResultVarName,
      CreateValInit(ResultEl.ResultType,nil,SrcEl,aContext),ResultEl);
    Add(VarSt,ResultEl);
    Result:=SLFirst;
  end;

  Procedure AddFunctionResultReturn;
  var
    RetSt: TJSReturnStatement;
  begin
    RetSt:=TJSReturnStatement(CreateElement(TJSReturnStatement,ResultEl));
    RetSt.Expr:=CreatePrimitiveDotExpr(ResultVarName,ResultEl);
    Add(RetSt,ResultEl);
  end;

  procedure AddResourceString(ResStr: TPasResString);
  // $mod.$resourcestrings = {
  //  name1 : { org: "value" },
  //  name2 : { org: "value" },
  //  ...
  //  }
  var
    Value: TResEvalValue;
    ObjLit: TJSObjectLiteral;
    Lit: TJSObjectLiteralElement;
    RootContext: TRootContext;
  begin
    // first convert expression, it might fail
    Value:=AContext.Resolver.Eval(ResStr.Expr,[refConst]);
    //writeln('AddResourceString ',GetObjName(ResStr),' Value=',Value.AsDebugString);
    // create table
    if (ResStrVarEl=nil) and (El.ClassType=TImplementationSection) then
      begin
      RootContext:=TRootContext(AContext.GetContextOfType(TRootContext));
      ResStrVarEl:=RootContext.ResourceStrings;
      end;
    if ResStrVarEl=nil then
      begin
      ResStrVarEl:=TJSVarDeclaration(CreateElement(TJSVarDeclaration,El));
      ResStrVarEl.Name:=FBuiltInNames[pbivnModule]+'.'+FBuiltInNames[pbivnResourceStrings];
      ResStrVarElAdd:=true;
      ObjLit:=TJSObjectLiteral(CreateElement(TJSObjectLiteral,El));
      ResStrVarEl.Init:=ObjLit;
      RootContext:=TRootContext(AContext.GetContextOfType(TRootContext));
      RootContext.ResourceStrings:=ResStrVarEl;
      end;
    // add element:  name : { ... }
    Lit:=TJSObjectLiteral(ResStrVarEl.Init).Elements.AddElement;
    Lit.Name:=TJSString(TransformVariableName(ResStr,AContext));
    ObjLit:=TJSObjectLiteral(CreateElement(TJSObjectLiteral,ResStr));
    Lit.Expr:=ObjLit;
    // add sub element: org: value
    Lit:=ObjLit.Elements.AddElement;
    Lit.Name:=TJSString(FBuiltInNames[pbivnResourceStringOrg]);
    Lit.Expr:=ConvertConstValue(Value,AContext,ResStr);
    ReleaseEvalValue(Value);
  end;

begin
  Result:=nil;
  {
    TPasDeclarations = class(TPasElement)
    TPasSection = class(TPasDeclarations)
    TInterfaceSection = class(TPasSection)
    TImplementationSection = class(TPasSection)
    TProgramSection = class(TImplementationSection)
    TLibrarySection = class(TImplementationSection)
    TProcedureBody = class(TPasDeclarations)
  }

  IsProcBody:=(El is TProcedureBody) and (TProcedureBody(El).Body<>nil);
  IsFunction:=IsProcBody and (El.Parent is TPasFunction);
  IsAssembler:=IsProcBody and (TProcedureBody(El).Body is TPasImplAsmStatement);
  HasResult:=IsFunction and not IsAssembler;
  SLFirst:=nil;
  SLLast:=nil;
  ResultEl:=nil;
  ResultVarName:='';
  ResStrVarEl:=nil;
  ResStrVarElAdd:=false;
  try

    if HasResult then
      AddFunctionResultInit;

    For I:=0 to El.Declarations.Count-1 do
      begin
      P:=TPasElement(El.Declarations[i]);
      {$IFDEF VerbosePas2JS}
      //writeln('TPasToJSConverter.ConvertDeclarations El[',i,']=',GetObjName(P));
      {$ENDIF}
      if not IsElementUsed(P) then continue;

      E:=Nil;
      C:=P.ClassType;
      if C=TPasConst then
        E:=ConvertConst(TPasConst(P),aContext) // can be nil
      else if C=TPasVariable then
        E:=CreateVarDecl(TPasVariable(P),aContext) // can be nil
      else if C.InheritsFrom(TPasType) then
        E:=CreateTypeDecl(TPasType(P),aContext) // can be nil
      else if C.InheritsFrom(TPasProcedure) then
        begin
        PasProc:=TPasProcedure(P);
        if PasProc.IsForward then continue; // JavaScript does not need the forward
        ProcScope:=TPasProcedureScope(PasProc.CustomData);
        if (ProcScope.DeclarationProc<>nil)
            and (not ProcScope.DeclarationProc.IsForward) then
          continue; // this proc was already converted in interface or class
        if ProcScope.DeclarationProc<>nil then
          PasProc:=ProcScope.DeclarationProc;
        E:=ConvertProcedure(PasProc,aContext);
        end
      else if C=TPasResString then
        begin
        if not (El is TPasSection) then
          RaiseNotSupported(P,AContext,20171004185348);
        AddResourceString(TPasResString(P));
        continue;
        end
      else
        RaiseNotSupported(P as TPasElement,AContext,20161024191434);
      Add(E,P);
      end;

    if IsProcBody then
      begin
      ProcBody:=TProcedureBody(El).Body;
      if (ProcBody.Elements.Count>0) or IsAssembler then
        begin
        E:=ConvertElement(ProcBody,aContext);
        Add(E,ProcBody);
        end;
      end;

    if HasResult then
      AddFunctionResultReturn;

    if ResStrVarEl<>nil then
      begin
      if ResStrVarElAdd then
        Add(ResStrVarEl,El);
      ResStrVarEl:=nil;
      end;
  finally
    ResStrVarEl.Free;
  end;
end;

function TPasToJSConverter.ConvertClassType(El: TPasClassType;
  AContext: TConvertContext): TJSElement;
(*
  type
    TMyClass = class(Ancestor)
      i: longint;
    end;

    rtl.createClass(this,"TMyClass",Ancestor,function(){
      this.i = 0;
    });
*)
type
  TMemberFunc = (mfInit, mfFinalize);
const
  MemberFuncName: array[TMemberFunc] of string = (
    '$init',
    '$final'
    );
var
  IsTObject, AncestorIsExternal: boolean;

  function IsMemberNeeded(aMember: TPasElement): boolean;
  begin
    if IsElementUsed(aMember) then exit(true);
    if IsTObject then
      begin
      if aMember is TPasProcedure then
        begin
        if (CompareText(aMember.Name,'AfterConstruction')=0)
            or (CompareText(aMember.Name,'BeforeDestruction')=0) then
          exit(true);
        end;
      end;
    Result:=false;
  end;

  procedure AddCallAncestorMemberFunction(ClassContext: TConvertContext;
    Ancestor: TPasType; Src: TJSSourceElements; Kind: TMemberFunc);
  var
    Call: TJSCallExpression;
    AncestorPath: String;
  begin
    if (Ancestor=nil) or AncestorIsExternal then
      exit;
    Call:=CreateCallExpression(El);
    AncestorPath:=CreateReferencePath(Ancestor,ClassContext,rpkPathAndName);
    Call.Expr:=CreatePrimitiveDotExpr(AncestorPath+'.'+MemberFuncName[Kind]+'.call',El);
    Call.AddArg(CreatePrimitiveDotExpr('this',El));
    AddToSourceElements(Src,Call);
  end;

  procedure AddInstanceMemberFunction(Src: TJSSourceElements;
    ClassContext: TConvertContext; Ancestor: TPasType; Kind: TMemberFunc);
  // add instance initialization function:
  //   this.$init = function(){
  //     ancestor.$init();
  //     ... init variables ...
  //   }
  // or add instance finalization function:
  //   this.$final = function(){
  //     ... clear references ...
  //     ancestor.$final();
  //   }
  var
    FuncVD: TJSVarDeclaration;
    New_Src: TJSSourceElements;
    New_FuncContext: TFunctionContext;
    I: Integer;
    P: TPasElement;
    NewEl: TJSElement;
    Func: TJSFunctionDeclarationStatement;
    VarType: TPasType;
    AssignSt: TJSSimpleAssignStatement;
  begin
    // add instance members
    New_Src:=TJSSourceElements(CreateElement(TJSSourceElements, El));
    New_FuncContext:=TFunctionContext.Create(El,New_Src,ClassContext);
    try
      New_FuncContext.ThisPas:=El;
      New_FuncContext.IsGlobal:=true;

      // add class members
      For I:=0 to El.Members.Count-1 do
        begin
        P:=TPasElement(El.Members[i]);
        if not IsMemberNeeded(P) then continue;
        NewEl:=nil;
        if (P.ClassType=TPasVariable)
            and (ClassVarModifiersType*TPasVariable(P).VarModifiers=[]) then
          begin
          if Kind=mfInit then
            // mfInit: init var
            NewEl:=CreateVarDecl(TPasVariable(P),New_FuncContext) // can be nil
          else
            begin
            // mfFinalize: clear reference
            if vmExternal in TPasVariable(P).VarModifiers then continue;
            VarType:=ClassContext.Resolver.ResolveAliasType(TPasVariable(P).VarType);
            if (VarType.ClassType=TPasRecordType)
                or (VarType.ClassType=TPasClassType)
                or (VarType.ClassType=TPasClassOfType)
                or (VarType.ClassType=TPasSetType)
                or (VarType.ClassType=TPasProcedureType)
                or (VarType.ClassType=TPasFunctionType)
                or (VarType.ClassType=TPasArrayType) then
              begin
              AssignSt:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,El));
              NewEl:=AssignSt;
              AssignSt.LHS:=CreateSubDeclNameExpr(P,P.Name,New_FuncContext);
              AssignSt.Expr:=CreateLiteralUndefined(El);
              end;
            end;
          end;
        if NewEl=nil then continue;
        if (Kind=mfInit) and (New_Src.Statements.Count=0) then
          // add call ancestor.$init.call(this)
          AddCallAncestorMemberFunction(ClassContext,Ancestor,New_Src,Kind);
        AddToSourceElements(New_Src,NewEl);
        end;
      if (Kind=mfFinalize) and (New_Src.Statements.Count>0) then
        // call ancestor.$final.call(this)
        AddCallAncestorMemberFunction(ClassContext,Ancestor,New_Src,Kind);
      if (Ancestor<>nil) and (not AncestorIsExternal)
          and (New_Src.Statements.Count=0) then
        exit; // descendent does not need $init/$final

      FuncVD:=TJSVarDeclaration(CreateElement(TJSVarDeclaration,El));
      AddToSourceElements(Src,FuncVD);
      FuncVD.Name:='this.'+MemberFuncName[Kind];
      Func:=CreateFunctionSt(El);
      FuncVD.Init:=Func;
      Func.AFunction.Body.A:=New_Src;
      New_Src:=nil;
    finally
      New_Src.Free;
      New_FuncContext.Free;
    end;
  end;

  procedure AddRTTI(Src: TJSSourceElements; FuncContext: TFunctionContext);
  var
    HasRTTIMembers: Boolean;
    i: Integer;
    P: TPasElement;
    NewEl: TJSElement;
    VarSt: TJSVariableStatement;
  begin
    // add $r to local vars, to avoid name clashes and nicer debugging
    FuncContext.AddLocalVar(FBuiltInNames[pbivnRTTILocal],nil);

    HasRTTIMembers:=false;
    For i:=0 to El.Members.Count-1 do
      begin
      P:=TPasElement(El.Members[i]);
      //writeln('TPasToJSConverter.ConvertClassType RTTI El[',i,']=',GetObjName(P));
      if P.Visibility<>visPublished then continue;
      if not IsMemberNeeded(P) then continue;
      NewEl:=nil;
      if P.ClassType=TPasVariable then
        NewEl:=CreateRTTIClassField(TPasVariable(P),FuncContext)
      else if P.InheritsFrom(TPasProcedure) then
        NewEl:=CreateRTTIClassMethod(TPasProcedure(P),FuncContext)
      else if P.ClassType=TPasProperty then
        NewEl:=CreateRTTIClassProperty(TPasProperty(P),FuncContext)
      else if P.InheritsFrom(TPasType) then
        continue
      else
        DoError(20170409202315,nSymbolCannotBePublished,sSymbolCannotBePublished,[],P);
      if NewEl=nil then
        continue; // e.g. abstract or external proc
      // add RTTI element
      if not HasRTTIMembers then
        begin
        // add "var $r = this.$rtti"
        VarSt:=CreateVarStatement(FBuiltInNames[pbivnRTTILocal],
          CreateMemberExpression(['this',FBuiltInNames[pbivnRTTI]]),El);
        AddToSourceElements(Src,VarSt);

        HasRTTIMembers:=true;
        end;
      AddToSourceElements(Src,NewEl);
      end;
  end;

var
  Call: TJSCallExpression;
  FunDecl: TJSFunctionDeclarationStatement;
  Src: TJSSourceElements;
  ArgEx: TJSLiteral;
  FuncContext: TFunctionContext;
  i: Integer;
  NewEl: TJSElement;
  P: TPasElement;
  Scope: TPas2JSClassScope;
  Ancestor: TPasType;
  AncestorPath, OwnerName, DestructorName: String;
  C: TClass;
  AssignSt: TJSSimpleAssignStatement;
begin
  Result:=nil;
  if El.ObjKind=okInterface then
    exit;
  if El.ObjKind<>okClass then
    RaiseNotSupported(El,AContext,20170927183645);
  if El.IsForward then
    begin
    Result:=ConvertClassForwardType(El,AContext);
    exit;
    end;

  if El.IsExternal then exit;

  if El.CustomData is TPas2JSClassScope then
    Scope:=TPas2JSClassScope(El.CustomData)
  else
    Scope:=nil;

  IsTObject:=CompareText(El.Name,'TObject')=0;

  if (Scope<>nil) and (Scope.AncestorScope<>nil) then
    Ancestor:=Scope.AncestorScope.Element as TPasType
  else
    Ancestor:=El.AncestorType;

  // create call 'rtl.createClass('
  FuncContext:=nil;
  Call:=CreateCallExpression(El);
  try
    AncestorIsExternal:=(Ancestor is TPasClassType) and TPasClassType(Ancestor).IsExternal;
    if AncestorIsExternal then
      Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnCreateClassExt]])
    else
      Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnCreateClass]]);

    // add parameter: owner. For top level class, the module is the owner.
    if (El.Parent<>nil) and (El.Parent.ClassType=TImplementationSection) then
      OwnerName:=AContext.GetLocalName(El.Parent)
    else
      OwnerName:=AContext.GetLocalName(El.GetModule);
    if OwnerName='' then
      OwnerName:='this';
    Call.AddArg(CreatePrimitiveDotExpr(OwnerName,El));

    // add parameter: string constant '"classname"'
    ArgEx := CreateLiteralString(El,TransformVariableName(El,AContext));
    Call.AddArg(ArgEx);

    // add parameter: ancestor
    if Ancestor=nil then
      AncestorPath:='null'
    else if AncestorIsExternal then
      AncestorPath:=TPasClassType(Ancestor).ExternalName
    else
      AncestorPath:=CreateReferencePath(Ancestor,AContext,rpkPathAndName);
    Call.AddArg(CreatePrimitiveDotExpr(AncestorPath,El));

    if AncestorIsExternal then
     begin
     // add the name of the NewInstance function
     if Scope.NewInstanceFunction<>nil then
       Call.AddArg(CreateLiteralString(
         Scope.NewInstanceFunction,Scope.NewInstanceFunction.Name))
     else
       Call.AddArg(CreateLiteralString(El,''));
     end;

    // add parameter: class initialize function 'function(){...}'
    FunDecl:=CreateFunctionSt(El,true,true);
    Call.AddArg(FunDecl);
    Src:=TJSSourceElements(FunDecl.AFunction.Body.A);

    // add members
    FuncContext:=TFunctionContext.Create(El,Src,AContext);
    FuncContext.IsGlobal:=true;
    FuncContext.ThisPas:=El;
    // add class members: types and class vars
    For i:=0 to El.Members.Count-1 do
      begin
      P:=TPasElement(El.Members[i]);
      //writeln('TPasToJSConverter.ConvertClassType class vars El[',i,']=',GetObjName(P));
      if not IsMemberNeeded(P) then continue;
      C:=P.ClassType;
      NewEl:=nil;
      if C=TPasVariable then
        begin
        if ClassVarModifiersType*TPasVariable(P).VarModifiers<>[] then
          begin
          NewEl:=CreateVarDecl(TPasVariable(P),FuncContext); // can be nil
          if NewEl=nil then continue;
          end
        else
          continue;
        end
      else if C=TPasConst then
        NewEl:=ConvertConst(TPasConst(P),aContext)
      else if C=TPasProperty then
        begin
        NewEl:=ConvertProperty(TPasProperty(P),AContext);
        if NewEl=nil then continue;
        end
      else if C.InheritsFrom(TPasType) then
        NewEl:=CreateTypeDecl(TPasType(P),aContext)
      else if C.InheritsFrom(TPasProcedure) then
        continue
      else
        RaiseNotSupported(P,FuncContext,20161221233338);
      if NewEl=nil then
        RaiseNotSupported(P,FuncContext,20170204223922);
      AddToSourceElements(Src,NewEl);
      end;

    // instance initialization function
    AddInstanceMemberFunction(Src,FuncContext,Ancestor,mfInit);
    // instance finalization function
    AddInstanceMemberFunction(Src,FuncContext,Ancestor,mfFinalize);

    // add methods
    For i:=0 to El.Members.Count-1 do
      begin
      P:=TPasElement(El.Members[i]);
      //writeln('TPasToJSConverter.ConvertClassType methods El[',i,']=',GetObjName(P));
      if not IsMemberNeeded(P) then continue;
      if P is TPasProcedure then
        begin
        if IsTObject and (P.ClassType=TPasDestructor) then
          begin
          DestructorName:=TransformVariableName(P,AContext);
          if DestructorName<>'Destroy' then
            begin
            // add 'rtl.tObjectDestroy="destroy";'
            AssignSt:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,P));
            AssignSt.LHS:=CreateMemberExpression([GetBuildInNames(pbivnRTL),GetBuildInNames(pbivnTObjectDestroy)]);
            AssignSt.Expr:=CreateLiteralString(P,DestructorName);
            AddToSourceElements(Src,AssignSt);
            end;
          end;
        NewEl:=ConvertProcedure(TPasProcedure(P),FuncContext);
        end
      else
        continue;
      if NewEl=nil then
        continue; // e.g. abstract or external proc
      AddToSourceElements(Src,NewEl);
      end;

    // add RTTI init function
    if AContext.Resolver<>nil then
      AddRTTI(Src,FuncContext);

    Result:=Call;
  finally
    FuncContext.Free;
    if Result<>Call then
      Call.Free;
  end;
end;

function TPasToJSConverter.ConvertClassForwardType(El: TPasClassType;
  AContext: TConvertContext): TJSElement;
// module.$rtti.$Class("classname");
var
  Ref: TResolvedReference;
  aClass: TPasClassType;
  ObjLit: TJSObjectLiteral;
begin
  Result:=nil;
  if (AContext.Resolver=nil) or not (El.CustomData is TResolvedReference) then exit;
  Ref:=TResolvedReference(El.CustomData);
  aClass:=Ref.Declaration as TPasClassType;
  if not HasTypeInfo(aClass,AContext) then exit;
  if IsClassRTTICreatedBefore(aClass,El,AContext) then exit;
  // module.$rtti.$Class("classname");
  Result:=CreateRTTINewType(aClass,FBuiltInNames[pbifnRTTINewClass],true,AContext,ObjLit);
  if ObjLit<>nil then
    RaiseInconsistency(20170412093427,El);
end;

function TPasToJSConverter.ConvertClassExternalType(El: TPasClassType;
  AContext: TConvertContext): TJSElement;

  function IsMemberNeeded(aMember: TPasElement): boolean;
  begin
    Result:=IsElementUsed(aMember);
  end;

var
  i: Integer;
  P: TPasElement;
  C: TClass;
  Proc: TPasProcedure;
begin
  Result:=nil;
  if El.IsForward then exit;

  // add class members: types and class vars
  For i:=0 to El.Members.Count-1 do
    begin
    P:=TPasElement(El.Members[i]);
    //writeln('TPasToJSConverter.ConvertClassExternalType class El[',i,']=',GetObjName(P));
    if not IsMemberNeeded(P) then continue;
    C:=P.ClassType;
    if (C=TPasVariable) or (C=TPasConst) then
      begin
      if not (vmExternal in TPasVariable(P).VarModifiers) then
        DoError(20170321150737,nMissingExternalName,sMissingExternalName,[],P);
      end
    else if C=TPasProperty then
      // is replaced with Getter/Setter -> nothing to do here
    else if C.InheritsFrom(TPasProcedure) then
      begin
      Proc:=TPasProcedure(P);
      if Proc.IsExternal then
        // external, nothing to do here
      else
        DoError(20170321152209,nMissingExternalName,sMissingExternalName,[],P);
      end
    else
      RaiseNotSupported(P,AContext,20170321151727);
    end;
end;

function TPasToJSConverter.ConvertClassOfType(El: TPasClassOfType;
  AContext: TConvertContext): TJSElement;
// create
// module.$rtti.$ClassRef("typename",{
//    instancetype: module.$rtti["classname"])
//  }
// if class is defined later add a forward define for the class
var
  ObjLit: TJSObjectLiteral;
  Prop: TJSObjectLiteralElement;
  Call: TJSCallExpression;
  ok: Boolean;
  List: TJSStatementList;
  DestType: TPasType;
begin
  Result:=nil;
  if not HasTypeInfo(El,AContext) then exit;

  ok:=false;
  Call:=CreateRTTINewType(El,FBuiltInNames[pbifnRTTINewClassRef],false,AContext,ObjLit);
  Result:=Call;
  try
    Prop:=ObjLit.Elements.AddElement;
    Prop.Name:=TJSString(FBuiltInNames[pbivnRTTIClassRef_InstanceType]);
    DestType:=AContext.Resolver.ResolveAliasType(El.DestType);
    Prop.Expr:=CreateTypeInfoRef(DestType,AContext,El);

    if not IsClassRTTICreatedBefore(DestType as TPasClassType,El,AContext) then
      begin
      // class rtti must be forward registered
      if not (AContext is TFunctionContext) then
        RaiseNotSupported(El,AContext,20170412102916);
      // prepend   module.$rtti.$Class("classname");
      Call:=CreateRTTINewType(DestType,FBuiltInNames[pbifnRTTINewClass],true,AContext,ObjLit);
      if ObjLit<>nil then
        RaiseInconsistency(20170412102654,El);
      List:=TJSStatementList(CreateElement(TJSStatementList,El));
      List.A:=Call;
      List.B:=Result;
      Result:=List;
      end;
    ok:=true;
  finally
    if not ok then
      FreeAndNil(Result);
  end;
end;

function TPasToJSConverter.ConvertEnumType(El: TPasEnumType;
  AContext: TConvertContext): TJSElement;
// TMyEnum = (red, green)
// convert to
//   this.TMyEnum = {
//     "0":"red",
//     "red":0,
//     "0":"green",
//     "green":0,
//   };
//   module.$rtti.$TIEnum("TMyEnum",{
//     enumtype: this.TMyEnum,
//     minvalue: 0,
//     maxvalue: 1
//   });
var
  ObjectContect: TObjectContext;
  i: Integer;
  EnumValue: TPasEnumValue;
  ParentObj, Obj, TIObj: TJSObjectLiteral;
  ObjLit, TIProp: TJSObjectLiteralElement;
  AssignSt: TJSSimpleAssignStatement;
  JSName: TJSString;
  Call: TJSCallExpression;
  List: TJSStatementList;
  ok: Boolean;
  OrdType: TOrdType;
begin
  Result:=nil;
  for i:=0 to El.Values.Count-1 do
    begin
    EnumValue:=TPasEnumValue(El.Values[i]);
    if EnumValue.Value<>nil then
      RaiseNotSupported(EnumValue.Value,AContext,20170208145221,'enum constant');
    end;

  ok:=false;
  ObjectContect:=nil;
  try
    Obj:=TJSObjectLiteral(CreateElement(TJSObjectLiteral,El));
    if AContext is TObjectContext then
      begin
      // add 'TypeName: function(){}'
      ParentObj:=TObjectContext(AContext).JSElement as TJSObjectLiteral;
      ObjLit:=ParentObj.Elements.AddElement;
      ObjLit.Name:=TJSString(TransformVariableName(El,AContext));
      ObjLit.Expr:=Obj;
      Result:=Obj;
      end
    else
      begin
      // add 'this.TypeName = function(){}'
      AssignSt:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,El));
      AssignSt.LHS:=CreateSubDeclNameExpr(El,El.Name,AContext);
      AssignSt.Expr:=Obj;
      Result:=AssignSt;
      end;

    ObjectContect:=TObjectContext.Create(El,Obj,AContext);
    for i:=0 to El.Values.Count-1 do
      begin
      EnumValue:=TPasEnumValue(El.Values[i]);
      JSName:=TJSString(TransformVariableName(EnumValue,AContext));
      // add "0":"value"
      ObjLit:=Obj.Elements.AddElement;
      ObjLit.Name:=TJSString(IntToStr(i));
      ObjLit.Expr:=CreateLiteralJSString(El,JSName);
      // add value:0
      ObjLit:=Obj.Elements.AddElement;
      ObjLit.Name:=JSName;
      ObjLit.Expr:=CreateLiteralNumber(El,i);
      end;

    if HasTypeInfo(El,AContext) then
      begin
      // create typeinfo
      if not (AContext is TFunctionContext) then
        RaiseNotSupported(El,AContext,20170411210045,'typeinfo');
      // create statement list
      List:=TJSStatementList(CreateElement(TJSStatementList,El));
      List.A:=Result;
      Result:=List;
      OrdType:=GetOrdType(0,El.Values.Count-1,El);
      // module.$rtti.$TIEnum("TMyEnum",{...});
      Call:=CreateRTTINewType(El,FBuiltInNames[pbifnRTTINewEnum],false,AContext,TIObj);
      List.B:=Call;
      // add  minvalue: number
      TIProp:=TIObj.Elements.AddElement;
      TIProp.Name:=TJSString(FBuiltInNames[pbivnRTTIInt_MinValue]);
      TIProp.Expr:=CreateLiteralNumber(El,0);
      // add  maxvalue: number
      TIProp:=TIObj.Elements.AddElement;
      TIProp.Name:=TJSString(FBuiltInNames[pbivnRTTIInt_MaxValue]);
      TIProp.Expr:=CreateLiteralNumber(El,El.Values.Count-1);
      // add  ordtype: number
      TIProp:=TIObj.Elements.AddElement;
      TIProp.Name:=TJSString(FBuiltInNames[pbivnRTTIInt_OrdType]);
      TIProp.Expr:=CreateLiteralNumber(El,ord(OrdType));
      // add  enumtype: this.TypeName
      TIProp:=TIObj.Elements.AddElement;
      TIProp.Name:=TJSString(FBuiltInNames[pbivnRTTIEnum_EnumType]);
      TIProp.Expr:=CreateSubDeclNameExpr(El,El.Name,AContext);
      end;

    ok:=true;
  finally
    ObjectContect.Free;
    if not ok then
      FreeAndNil(Result);
  end;
end;

function TPasToJSConverter.ConvertSetType(El: TPasSetType;
  AContext: TConvertContext): TJSElement;
// create
//   module.$rtti.$Set("name",{
//       comptype: module.$rtti["enumtype"]
//     })
var
  Obj: TJSObjectLiteral;
  Call: TJSCallExpression;
  Prop: TJSObjectLiteralElement;
begin
  Result:=nil;
  if El.IsPacked then
    DoError(20170222231613,nPasElementNotSupported,sPasElementNotSupported,
      ['packed'],El);
  if not HasTypeInfo(El,AContext) then exit;

  // module.$rtti.$Set("name",{...})
  Call:=CreateRTTINewType(El,FBuiltInNames[pbifnRTTINewSet],false,AContext,Obj);
  try
    // "comptype: ref"
    Prop:=Obj.Elements.AddElement;
    Prop.Name:=TJSString(FBuiltInNames[pbivnRTTISet_CompType]);
    Prop.Expr:=CreateTypeInfoRef(El.EnumType,AContext,El);
    Result:=Call;
  finally
    if Result=nil then
      Call.Free;
  end;
end;

function TPasToJSConverter.ConvertRangeType(El: TPasRangeType;
  AContext: TConvertContext): TJSElement;
// create
//   module.$rtti.$Int("name",{
//       minvalue: <number>,
//       maxvalue: <number>,
//       ordtype: <number>
//     })
var
  TIObj: TJSObjectLiteral;
  Call: TJSCallExpression;
  MinVal, MaxVal: TResEvalValue;
  MinInt, MaxInt: MaxPrecInt;
  OrdType: TOrdType;
  TIProp: TJSObjectLiteralElement;
  fn: TPas2JSBuiltInName;
begin
  Result:=nil;
  if not HasTypeInfo(El,AContext) then exit;

  // module.$rtti.$Int("name",{...})
  MinVal:=nil;
  MaxVal:=nil;
  Call:=nil;
  try
    MinVal:=AContext.Resolver.EvalRangeLimit(El.RangeExpr,[refConst],true,El);
    MaxVal:=AContext.Resolver.EvalRangeLimit(El.RangeExpr,[refConst],false,El);
    if MinVal.Kind=revkInt then
      begin
      fn:=pbifnRTTINewInt;
      MinInt:=TResEvalInt(MinVal).Int;
      MaxInt:=TResEvalInt(MaxVal).Int;
      end
    else if MinVal.Kind=revkEnum then
      begin
      fn:=pbifnRTTINewEnum;
      MinInt:=TResEvalEnum(MinVal).Index;
      MaxInt:=TResEvalEnum(MaxVal).Index;
      end
    else
      begin
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.ConvertRangeType type: ',MinVal.AsDebugString,'..',MaxVal.AsDebugString);
      {$ENDIF}
      RaiseNotSupported(El,AContext,20170925201628);
      end;
    OrdType:=GetOrdType(MinInt,MaxInt,El);
    Call:=CreateRTTINewType(El,FBuiltInNames[fn],false,AContext,TIObj);
    // add  minvalue: number
    TIProp:=TIObj.Elements.AddElement;
    TIProp.Name:=TJSString(FBuiltInNames[pbivnRTTIInt_MinValue]);
    TIProp.Expr:=CreateLiteralNumber(El,MinInt);
    // add  maxvalue: number
    TIProp:=TIObj.Elements.AddElement;
    TIProp.Name:=TJSString(FBuiltInNames[pbivnRTTIInt_MaxValue]);
    TIProp.Expr:=CreateLiteralNumber(El,MaxInt);
    // add  ordtype: number
    TIProp:=TIObj.Elements.AddElement;
    TIProp.Name:=TJSString(FBuiltInNames[pbivnRTTIInt_OrdType]);
    TIProp.Expr:=CreateLiteralNumber(El,ord(OrdType));
    if MinVal.Kind=revkEnum then
      begin
      // add  enumtype: this.TypeName
      TIProp:=TIObj.Elements.AddElement;
      TIProp.Name:=TJSString(FBuiltInNames[pbivnRTTIEnum_EnumType]);
      TIProp.Expr:=CreateSubDeclNameExpr(El,TResEvalEnum(MinVal).ElType.Name,AContext);
      end;
    Result:=Call;
  finally
    ReleaseEvalValue(MinVal);
    ReleaseEvalValue(MaxVal);
    if Result=nil then
      Call.Free;
  end;
end;

function TPasToJSConverter.ConvertPointerType(El: TPasPointerType;
  AContext: TConvertContext): TJSElement;
// create
//   module.$rtti.$Set("name",{
//       reftype: module.$rtti["reftype"]
//     })
var
  Obj: TJSObjectLiteral;
  Call: TJSCallExpression;
  Prop: TJSObjectLiteralElement;
begin
  Result:=nil;
  if not HasTypeInfo(El,AContext) then exit;

  // module.$rtti.$Pointer("name",{...})
  Call:=CreateRTTINewType(El,FBuiltInNames[pbifnRTTINewPointer],false,AContext,Obj);
  try
    // "reftype: ref"
    Prop:=Obj.Elements.AddElement;
    Prop.Name:=TJSString(FBuiltInNames[pbivnRTTISet_CompType]);
    Prop.Expr:=CreateTypeInfoRef(El.DestType,AContext,El);
    Result:=Call;
  finally
    if Result=nil then
      Call.Free;
  end;
end;

function TPasToJSConverter.ConvertProcedureType(El: TPasProcedureType;
  AContext: TConvertContext): TJSElement;
// create
//   module.$rtti.$ProcVar("name",{
//       procsig: rtl.newTIProcSignature([[arg1name,arg1type,arg1flags],[arg2name...],...],resulttype,flags)
//     })
//   module.$rtti.$MethodVar("name",{
//       procsig: rtl.newTIProcSignature([[arg1name,arg1type,arg1flags],[arg2name...],...],resulttype,flags),
//       methodkind: 1
//     })
var
  Call, InnerCall: TJSCallExpression;
  FunName: String;
  ResultEl: TPasResultElement;
  ResultTypeInfo: TJSElement;
  Flags: Integer;
  MethodKind: TMethodKind;
  Obj: TJSObjectLiteral;
  Prop: TJSObjectLiteralElement;
begin
  Result:=nil;
  if El.IsNested then
    DoError(20170222231636,nPasElementNotSupported,sPasElementNotSupported,
      ['is nested'],El);
  if El.CallingConvention<>ccDefault then
    DoError(20170222231532,nPasElementNotSupported,sPasElementNotSupported,
        ['calling convention '+cCallingConventions[El.CallingConvention]],El);
  if not HasTypeInfo(El,AContext) then exit;

  // module.$rtti.$ProcVar("name",function(){})
  if El.IsReferenceTo then
    FunName:=FBuiltInNames[pbifnRTTINewRefToProcVar]
  else if El.IsOfObject then
    FunName:=FBuiltInNames[pbifnRTTINewMethodVar]
  else
    FunName:=FBuiltInNames[pbifnRTTINewProcVar];
  Call:=CreateRTTINewType(El,FunName,false,AContext,Obj);
  try
    // add "procsig: rtl.newTIProcSignature()"
    Prop:=Obj.Elements.AddElement;
    Prop.Name:=TJSString(FBuiltInNames[pbivnRTTIProcVar_ProcSig]);
    InnerCall:=CreateCallExpression(El);
    Prop.Expr:=InnerCall;
    InnerCall.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnRTTINewProcSig]]);
    // add array of arguments
    InnerCall.AddArg(CreateRTTIArgList(El,El.Args,AContext));
    // add resulttype as typeinfo reference
    if El is TPasFunctionType then
      begin
      ResultEl:=TPasFunctionType(El).ResultEl;
      ResultTypeInfo:=CreateTypeInfoRef(ResultEl.ResultType,AContext,ResultEl);
      if ResultTypeInfo<>nil then
        InnerCall.AddArg(ResultTypeInfo);
      end;
    // add param flags
    Flags:=0;
    if ptmVarargs in El.Modifiers then
      inc(Flags,pfVarargs);
    if Flags>0 then
      InnerCall.AddArg(CreateLiteralNumber(El,Flags));

    if El.IsOfObject then
      begin
      // add "methodkind: number;"
      Prop:=Obj.Elements.AddElement;
      Prop.Name:=TJSString(FBuiltInNames[pbivnRTTIMethodKind]);
      if El.ClassType=TPasProcedureType then
        MethodKind:=mkProcedure
      else if El.ClassType=TPasFunctionType then
        MethodKind:=mkFunction
      else
        RaiseNotSupported(El,AContext,20170411180848);
      Prop.Expr:=CreateLiteralNumber(El,ord(MethodKind));
      end;

    Result:=Call;
  finally
    if Result=nil then
      Call.Free;
  end;
end;

function TPasToJSConverter.ConvertArrayType(El: TPasArrayType;
  AContext: TConvertContext): TJSElement;
// Static array of static array need clone function:
//  TStaticArray$clone = function(a){
//    var r = [];
//    for (var i=0; i<*High(a)*; i++) r.push(a[i].slice(0));
//    return r;
//  };
//
// Published array types need:
//  module.$rtti.$StaticArray("name",{
//    dims: [dimsize1,dimsize2,...],
//    eltype: module.$rtti["ElTypeName"]
//  };
//  module.$rtti.$DynArray("name",{
//    eltype: module.$rtti["ElTypeName"]
//  };
//
const
  CloneArrName = 'a';
  CloneResultName = 'r';
  CloneRunName = 'i';
var
  CallName: String;
  Obj: TJSObjectLiteral;
  Prop: TJSObjectLiteralElement;
  ArrLit: TJSArrayLiteral;
  Arr: TPasArrayType;
  Index: Integer;
  ElType: TPasType;
  RangeEl: TPasExpr;
  Call: TJSCallExpression;
  RgLen, RangeEnd: MaxPrecInt;
  CloneFunc: TJSVarDeclaration;
  List: TJSStatementList;
  Func: TJSFunctionDeclarationStatement;
  Src: TJSSourceElements;
  VarSt: TJSVariableStatement;
  ForLoop: TJSForStatement;
  ExprLT: TJSRelationalExpressionLT;
  PlusPlus: TJSUnaryPostPlusPlusExpression;
  BracketEx: TJSBracketMemberExpression;
  CloneEl: TJSElement;
  ReturnSt: TJSReturnStatement;
begin
  Result:=nil;
  if El.PackMode<>pmNone then
    DoError(20170222231648,nPasElementNotSupported,sPasElementNotSupported,
       ['packed'],El);
  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.ConvertArrayType ',GetObjName(El));
  {$ENDIF}

  if AContext.Resolver.HasStaticArrayCloneFunc(El) then
    begin
    // For example: type TArr = array[1..2] of array[1..2] of longint;
    //  TStaticArray$clone = function(a){
    //    var r = [];
    //    for (var i=0; i<*High(a)*; i++) r.push(a[i].slice(0));
    //    return r;
    //  };
    BracketEx:=nil;
    CloneFunc:=TJSVarDeclaration(CreateElement(TJSVarDeclaration,El));
    try
      Index:=0;
      RangeEl:=El.Ranges[Index];
      // function(a){...
      CloneFunc.Name:=El.Name+FBuiltInNames[pbifnArray_Static_Clone];
      Func:=CreateFunctionSt(El,true,true);
      CloneFunc.Init:=Func;
      Func.AFunction.Params.Add(CloneArrName);
      Src:=Func.AFunction.Body.A as TJSSourceElements;
      // var r = [];
      VarSt:=CreateVarStatement(CloneResultName,TJSArrayLiteral(CreateElement(TJSArrayLiteral,El)),El);
      AddToSourceElements(Src,VarSt);
      // for (
      ForLoop:=TJSForStatement(CreateElement(TJSForStatement,El));
      AddToSourceElements(Src,ForLoop);
      // var i=0;
      ForLoop.Init:=CreateVarStatement(CloneRunName,CreateLiteralNumber(El,0),El);
      // i<high(a)
      ExprLT:=TJSRelationalExpressionLT(CreateElement(TJSRelationalExpressionLT,El));
      ForLoop.Cond:=ExprLT;
      ExprLT.A:=CreatePrimitiveDotExpr(CloneRunName,El);
      RangeEnd:=AContext.Resolver.GetRangeLength(RangeEl);
      ExprLT.B:=CreateLiteralNumber(RangeEl,RangeEnd);
      // i++
      PlusPlus:=TJSUnaryPostPlusPlusExpression(CreateElement(TJSUnaryPostPlusPlusExpression,El));
      ForLoop.Incr:=PlusPlus;
      PlusPlus.A:=CreatePrimitiveDotExpr(CloneRunName,El);
      // r.push(...
      Call:=CreateCallExpression(El);
      ForLoop.Body:=Call;
      Call.Expr:=CreatePrimitiveDotExpr(CloneResultName+'.push',El);
      // a[i]
      BracketEx:=TJSBracketMemberExpression(CreateElement(TJSBracketMemberExpression,El));
      BracketEx.MExpr:=CreatePrimitiveDotExpr(CloneArrName,El);
      BracketEx.Name:=CreatePrimitiveDotExpr(CloneRunName,El);
      // clone a[i]
      ElType:=AContext.Resolver.ResolveAliasType(El.ElType);
      CloneEl:=nil;
      if ElType is TPasArrayType then
        begin
        if length(TPasArrayType(ElType).Ranges)=0 then
          RaiseNotSupported(El,AContext,20180218223414,GetObjName(ElType));
        CloneEl:=CreateCloneStaticArray(El,TPasArrayType(ElType),BracketEx,AContext);
        end
      else if ElType is TPasRecordType then
        CloneEl:=CreateCloneRecord(El,TPasRecordType(ElType),BracketEx,AContext)
      else if ElType is TPasSetType then
        CloneEl:=CreateReferencedSet(El,BracketEx)
      else
        RaiseNotSupported(El,AContext,20180218223618,GetObjName(ElType));
      Call.AddArg(CloneEl);
      BracketEx:=nil;
      // return r;
      ReturnSt:=TJSReturnStatement(CreateElement(TJSReturnStatement,El));
      AddToSourceElements(Src,ReturnSt);
      ReturnSt.Expr:=CreatePrimitiveDotExpr(CloneResultName,El);

      Result:=CloneFunc;
      CloneFunc:=nil;
    finally
      BracketEx.Free;
      CloneFunc.Free;
    end;
    end;

  if HasTypeInfo(El,AContext) then
    begin
    // module.$rtti.$DynArray("name",{...})
    if length(El.Ranges)>0 then
      CallName:=FBuiltInNames[pbifnRTTINewStaticArray]
    else
      CallName:=FBuiltInNames[pbifnRTTINewDynArray];
    Call:=CreateRTTINewType(El,CallName,false,AContext,Obj);
    try
      ElType:=AContext.Resolver.ResolveAliasType(El.ElType);
      if length(El.Ranges)>0 then
        begin
        // static array
        // dims: [dimsize1,dimsize2,...]
        Prop:=Obj.Elements.AddElement;
        Prop.Name:=TJSString(FBuiltInNames[pbivnRTTIArray_Dims]);
        ArrLit:=TJSArrayLiteral(CreateElement(TJSArrayLiteral,El));
        Prop.Expr:=ArrLit;
        Arr:=El;
        Index:=0;
        repeat
          RangeEl:=Arr.Ranges[Index];
          RgLen:=AContext.Resolver.GetRangeLength(RangeEl);
          ArrLit.AddElement(CreateLiteralNumber(RangeEl,RgLen));
          inc(Index);
          if Index=length(Arr.Ranges) then
            begin
            if ElType.ClassType<>TPasArrayType then
              break;
            Arr:=TPasArrayType(ElType);
            if length(Arr.Ranges)=0 then
              RaiseNotSupported(Arr,AContext,20170411222315,'static array of anonymous array');
            ElType:=AContext.Resolver.ResolveAliasType(Arr.ElType);
            Index:=0;
            end;
        until false;
        end;
      // eltype: ref
      Prop:=Obj.Elements.AddElement;
      Prop.Name:=TJSString(FBuiltInNames[pbivnRTTIArray_ElType]);
      Prop.Expr:=CreateTypeInfoRef(ElType,AContext,El);
      if Result=nil then
        Result:=Call
      else
        begin
        List:=TJSStatementList(CreateElement(TJSStatementList,El));
        List.A:=Result;
        List.B:=Call;
        Result:=List;
        end;
      Call:=nil;
    finally
      Call.Free;
    end;
    end;
end;

function TPasToJSConverter.GetOrdType(MinValue, MaxValue: MaxPrecInt;
  ErrorEl: TPasElement): TOrdType;
var
  V: MaxPrecInt;
begin
  if MinValue<0 then
    begin
    if MaxValue<-(MinValue+1) then
      V:=-(MinValue+1)
    else
      V:=MaxValue;
    if V<$8f then
      Result:=otSByte
    else if V<$8fff then
      Result:=otSWord
    else if V<$8fffffff then
      Result:=otSLong
    else if V<=MaxSafeIntDouble then
      Result:=otSIntDouble
    else
      DoError(20170925200802,nRangeCheckError,sRangeCheckError,[],ErrorEl);
    end
  else
    begin
    if MaxValue<$ff then
      Result:=otUByte
    else if MaxValue<$ffff then
      Result:=otUWord
    else if MaxValue<$ffffffff then
      Result:=otULong
    else if MaxValue<=MaxSafeIntDouble then
      Result:=otUIntDouble
    else
      DoError(20170925201002,nRangeCheckError,sRangeCheckError,[],ErrorEl);
    end;
end;

procedure TPasToJSConverter.ForLoop_OnProcBodyElement(El: TPasElement;
  arg: pointer);
// Called by ConvertForStatement on each element of the current proc body
// Check each element that lies behind the loop if it is reads the LoopVar
var
  Data: PForLoopFindData absolute arg;
begin
  if El.HasParent(Data^.ForLoop) then
    Data^.FoundLoop:=true
  else if Data^.FoundLoop and (not Data^.LoopVarWrite) and (not Data^.LoopVarRead) then
    begin
    // El comes after loop and LoopVar was not yet accessed
    if (El.CustomData is TResolvedReference)
        and (TResolvedReference(El.CustomData).Declaration=Data^.LoopVar) then
      begin
        // El refers the LoopVar
        // ToDo: check write only access
        Data^.LoopVarRead:=true;
      end;
    end;
end;

procedure TPasToJSConverter.SetUseEnumNumbers(const AValue: boolean);
begin
  if AValue then
    Include(FOptions,coEnumNumbers)
  else
    Exclude(FOptions,coEnumNumbers);
end;

procedure TPasToJSConverter.SetUseLowerCase(const AValue: boolean);
begin
  if AValue then
    Include(FOptions,coLowerCase)
  else
    Exclude(FOptions,coLowerCase);
end;

procedure TPasToJSConverter.SetUseSwitchStatement(const AValue: boolean);
begin
  if AValue then
    Include(FOptions,coSwitchStatement)
  else
    Exclude(FOptions,coSwitchStatement);
end;

constructor TPasToJSConverter.Create;
var
  n: TPas2JSBuiltInName;
begin
  FOptions:=[coLowerCase];
  for n in TPas2JSBuiltInName do
    FBuiltInNames[n]:=Pas2JSBuiltInNames[n];
end;

destructor TPasToJSConverter.Destroy;
begin
  inherited Destroy;
end;

function TPasToJSConverter.ConvertProcedure(El: TPasProcedure;
  AContext: TConvertContext): TJSElement;
var
  BodyJS: TJSFunctionBody;
  FirstSt, LastSt: TJSStatementList;

  procedure AddBodyStatement(Add: TJSElement; Src: TPasElement);
  begin
    AddToStatementList(FirstSt,LastSt,Add,Src);
    BodyJS.A:=FirstSt;
  end;

Var
  FS : TJSFunctionDeclarationStatement;
  FD : TJSFuncDef;
  n, i, Line, Col:Integer;
  AssignSt: TJSSimpleAssignStatement;
  FuncContext, ConstContext: TFunctionContext;
  ProcScope, ImplProcScope: TPas2JSProcedureScope;
  Arg: TPasArgument;
  SelfSt: TJSVariableStatement;
  ImplProc: TPasProcedure;
  BodyPas: TProcedureBody;
  PosEl: TPasElement;
  Call: TJSCallExpression;
  ClassPath: String;
  ArgResolved: TPasResolverResult;
  MinVal, MaxVal: MaxPrecInt;
  Lit: TJSLiteral;
  ConstSrcElems: TJSSourceElements;
begin
  Result:=nil;

  if El.IsAbstract then exit;
  if El.IsExternal then exit;

  ProcScope:=TPas2JSProcedureScope(El.CustomData);
  if ProcScope.DeclarationProc<>nil then
    exit;

  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.ConvertProcedure "',El.Name,'" ',El.Parent.ClassName);
  {$ENDIF}

  ImplProc:=El;
  if ProcScope.ImplProc<>nil then
    ImplProc:=ProcScope.ImplProc;
  ImplProcScope:=TPas2JSProcedureScope(ImplProc.CustomData);

  if ImplProcScope.BodyJS<>'' then
    begin
    // using precompiled code
    TPasResolver.UnmangleSourceLineNumber(El.SourceLinenumber,Line,Col);
    if ImplProcScope.GlobalJS<>nil then
      begin
      ConstContext:=AContext.GetGlobalFunc;
      if not (ConstContext.JSElement is TJSSourceElements) then
        begin
        {$IFDEF VerbosePas2JS}
        writeln('TPasToJSConverter.ConvertProcedure ConstContext=',GetObjName(ConstContext),' JSElement=',GetObjName(ConstContext.JSElement));
        {$ENDIF}
        RaiseNotSupported(El,AContext,20180228231008);
        end;
      ConstSrcElems:=TJSSourceElements(ConstContext.JSElement);
      for i:=0 to ImplProcScope.GlobalJS.Count-1 do
        begin
        // precompiled global var or type
        Lit:=TJSLiteral.Create(Line,Col,El.SourceFilename);
        Lit.Value.CustomValue:=UTF8Decode(ImplProcScope.GlobalJS[i]);
        AddToSourceElements(ConstSrcElems,Lit);
        end;
      end;
    // precompiled body
    Lit:=TJSLiteral.Create(Line,Col,El.SourceFilename);
    Lit.Value.CustomValue:=UTF8Decode(ImplProcScope.BodyJS);
    Result:=Lit;
    exit;
    end;

  AssignSt:=nil;
  if AContext.IsGlobal then
    begin
    AssignSt:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,ImplProc));
    Result:=AssignSt;
    AssignSt.LHS:=CreateSubDeclNameExpr(El,El.Name,AContext,ImplProc);
    end;

  FS:=CreateFunctionSt(ImplProc,ImplProc.Body<>nil);
  FD:=FS.AFunction;
  if AssignSt<>nil then
    AssignSt.Expr:=FS
  else
    begin
    // local/nested function
    Result:=FS;
    FD.Name:=TJSString(TransformVariableName(El,AContext));
    end;

  for n := 0 to El.ProcType.Args.Count - 1 do
    begin
    Arg:=TPasArgument(El.ProcType.Args[n]);
    FD.Params.Add(TransformVariableName(Arg,AContext));
    end;

  BodyPas:=ImplProc.Body;
  if BodyPas<>nil then
    begin
    PosEl:=BodyPas;
    if PosEl=nil then
      PosEl:=ImplProc;
    BodyJS:=FD.Body;
    FuncContext:=TFunctionContext.Create(ImplProc,FD.Body,AContext);
    try
      FuncContext.ScannerBoolSwitches:=ImplProcScope.BoolSwitches;
      FirstSt:=nil;
      LastSt:=nil;

      if (bsRangeChecks in ImplProcScope.BoolSwitches)
          and (AContext.Resolver<>nil) then
        for i:=0 to El.ProcType.Args.Count-1 do
          begin
          Arg:=TPasArgument(El.ProcType.Args[i]);
          if Arg.ArgType=nil then continue;
          AContext.Resolver.ComputeElement(Arg,ArgResolved,[rcType]);
          if ArgResolved.BaseType in btAllJSInteger then
            begin
            if AContext.Resolver.ResolveAliasType(ArgResolved.TypeEl) is TPasUnresolvedSymbolRef then
              begin
              if not AContext.Resolver.GetIntegerRange(ArgResolved.BaseType,MinVal,MaxVal) then
                RaiseNotSupported(Arg,AContext,20180119192608);
              // use Arg as PosEl, so that user knows which Arg is out of range
              Call:=CreateCallExpression(Arg);
              Call.Expr:=CreatePrimitiveDotExpr(FBuiltInNames[pbivnRTL]+'.'+FBuiltInNames[pbifnRangeCheckInt],El);
              AddBodyStatement(Call,Arg);
              Call.AddArg(CreateArgumentAccess(Arg,AContext,Arg));
              Call.AddArg(CreateLiteralNumber(Arg,MinVal));
              Call.AddArg(CreateLiteralNumber(Arg,MaxVal));
              end;
            end;
          end;

      if ProcScope.ClassScope<>nil then
        begin
        // method or class method
        FuncContext.ThisPas:=ProcScope.ClassScope.Element;
        if bsObjectChecks in FuncContext.ScannerBoolSwitches then
          begin
          // rtl.checkMethodCall(this,<class>)
          Call:=CreateCallExpression(PosEl);
          AddBodyStatement(Call,PosEl);
          Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],
                                          FBuiltInNames[pbifnCheckMethodCall]]);
          Call.AddArg(CreatePrimitiveDotExpr('this',PosEl));
          ClassPath:=CreateReferencePath(ProcScope.ClassScope.Element,AContext,rpkPathAndName);
          Call.AddArg(CreatePrimitiveDotExpr(ClassPath,PosEl));
          end;

        if ImplProc.Body.Functions.Count>0 then
          begin
          // has nested procs -> add "var self = this;"
          FuncContext.AddLocalVar(FBuiltInNames[pbivnSelf],FuncContext.ThisPas);
          SelfSt:=CreateVarStatement(FBuiltInNames[pbivnSelf],
                              CreatePrimitiveDotExpr('this',ImplProc),ImplProc);
          AddBodyStatement(SelfSt,PosEl);
          if ImplProcScope.SelfArg<>nil then
            begin
            // redirect Pascal-Self to JS-Self
            FuncContext.AddLocalVar(FBuiltInNames[pbivnSelf],ImplProcScope.SelfArg);
            end;
          end
        else
          begin
          if ImplProcScope.SelfArg<>nil then
            begin
            // no nested procs ->  redirect Pascal-Self to JS-this
            FuncContext.AddLocalVar('this',ImplProcScope.SelfArg);
            end;
          end;
        end;
      {$IFDEF VerbosePas2JS}
      //FuncContext.WriteStack;
      {$ENDIF}
      if BodyPas<>nil then
        AddBodyStatement(ConvertDeclarations(BodyPas,FuncContext),BodyPas);
    finally
      FuncContext.Free;
    end;
    end;

  if (coStoreImplJS in Options) and (AContext.Resolver<>nil) then
    begin
    if AContext.Resolver.GetTopLvlProc(El)=El then
      ImplProcScope.BodyJS:=StorePrecompiledJS(Result);
    end;
end;

function TPasToJSConverter.ConvertBeginEndStatement(El: TPasImplBeginBlock;
  AContext: TConvertContext; NilIfEmpty: boolean): TJSElement;

begin
  Result:=ConvertImplBlockElements(El,AContext,NilIfEmpty);
end;

function TPasToJSConverter.ConvertImplBlockElements(El: TPasImplBlock;
  AContext: TConvertContext; NilIfEmpty: boolean): TJSElement;
var
  First, Last: TJSStatementList;
  I : Integer;
  PasImpl: TPasImplElement;
  JSImpl : TJSElement;
begin
  if Not (Assigned(El.Elements) and (El.Elements.Count>0)) then
    begin
    if NilIfEmpty then
      Result:=nil
    else
      Result:=TJSEmptyBlockStatement(CreateElement(TJSEmptyBlockStatement,El));
    end
  else
    begin
    First:=nil;
    Result:=First;
    Last:=First;
    //writeln('TPasToJSConverter.ConvertImplBlockElements START El.Elements.Count=',El.Elements.Count);
    For I:=0 to El.Elements.Count-1 do
      begin
      PasImpl:=TPasImplElement(El.Elements[i]);
      JSImpl:=ConvertElement(PasImpl,AContext);
      if JSImpl=nil then
        continue; // e.g. "inherited;" when there is no ancestor proc
      //writeln('TPasToJSConverter.ConvertImplBlockElements ',i,' ',JSImpl.ClassName);
      AddToStatementList(First,Last,JSImpl,PasImpl);
      Result:=First;
      end;
    end;
end;

function TPasToJSConverter.ConvertInitializationSection(
  El: TInitializationSection; AContext: TConvertContext): TJSElement;
var
  FDS: TJSFunctionDeclarationStatement;
  FunName: String;
  IsMain: Boolean;
  AssignSt: TJSSimpleAssignStatement;
  FuncContext: TFunctionContext;
  Body: TJSFunctionBody;
  Scope: TPas2JSInitialFinalizationScope;
  Line, Col: integer;
  Lit: TJSLiteral;
begin
  // create: '$mod.$init=function(){}'
  Result:=nil;
  Scope:=TPas2JSInitialFinalizationScope(El.CustomData);

  if Scope.JS<>'' then
    begin
    // precompiled JS
    TPasResolver.UnmangleSourceLineNumber(El.Parent.SourceLinenumber,Line,Col);
    Lit:=TJSLiteral.Create(Line,Col,El.Parent.SourceFilename);
    Lit.Value.CustomValue:=UTF8Decode(Scope.JS);
    Result:=Lit;
    exit;
    end;

  IsMain:=(El.Parent<>nil) and (El.Parent is TPasProgram);
  if IsMain then
    FunName:=FBuiltInNames[pbifnProgramMain]
  else
    FunName:=FBuiltInNames[pbifnUnitInit];

  FuncContext:=nil;
  AssignSt:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,El));
  try
    AssignSt.LHS:=CreateMemberExpression([FBuiltInNames[pbivnModule],FunName]);
    FDS:=CreateFunctionSt(El,El.Elements.Count>0);
    AssignSt.Expr:=FDS;
    if El.Elements.Count>0 then
      begin
      Body:=FDS.AFunction.Body;
      FuncContext:=TFunctionContext.Create(El,Body,AContext);
      // Note: although the rtl sets 'this' as the module, the function can
      //   simply refer to $mod, so no need to set ThisPas here
      Body.A:=ConvertImplBlockElements(El,FuncContext,false);
      end;
    Result:=AssignSt;
  finally
    FuncContext.Free;
    if Result=nil then
      AssignSt.Free;
  end;

  if (coStoreImplJS in Options) and (AContext.Resolver<>nil) then
    Scope.JS:=StorePrecompiledJS(Result);
end;

function TPasToJSConverter.ConvertFinalizationSection(El: TFinalizationSection;
  AContext: TConvertContext): TJSElement;
begin
  Result:=nil;
  RaiseNotSupported(El,AContext,20161024192519);
end;

function TPasToJSConverter.ConvertTryStatement(El: TPasImplTry;
  AContext: TConvertContext): TJSElement;
Var
  T : TJSTryStatement;
  ExceptBlock: TPasImplTryHandler;
  i: Integer;
  ExceptOn: TPasImplExceptOn;
  IfSt, Last: TJSIfStatement;

begin
  Result:=nil;
  T:=nil;
  try
    if El.FinallyExcept is TPasImplTryFinally then
      begin
      T:=TJSTryFinallyStatement(CreateElement(TJSTryFinallyStatement,El));
      T.Block:=ConvertImplBlockElements(El,AContext,true);
      T.BFinally:=ConvertImplBlockElements(El.FinallyExcept,AContext,true);
      end
    else
      begin
      T:=TJSTryCatchStatement(CreateElement(TJSTryCatchStatement,El));
      T.Block:=ConvertImplBlockElements(El,AContext,true);
      // always set the catch except object, needed by nodejs
      T.Ident:=TJSString(FBuiltInNames[pbivnExceptObject]);
      ExceptBlock:=El.FinallyExcept;
      if (ExceptBlock.Elements.Count>0)
          and (TPasImplElement(ExceptBlock.Elements[0]) is TPasImplExceptOn) then
        begin
        Last:=nil;
        for i:=0 to ExceptBlock.Elements.Count-1 do
          begin
          ExceptOn:=TObject(ExceptBlock.Elements[i]) as TPasImplExceptOn;
          IfSt:=ConvertExceptOn(ExceptOn,AContext) as TJSIfStatement;
          if Last=nil then
            T.BCatch:=IfSt
          else
            Last.BFalse:=IfSt;
          Last:=IfSt;
          end;
        if El.ElseBranch<>nil then
          Last.BFalse:=ConvertImplBlockElements(El.ElseBranch,AContext,true)
        else
          begin
          // default else: throw exceptobject
          Last.BFalse:=TJSThrowStatement(CreateElement(TJSThrowStatement,El));
          TJSThrowStatement(Last.BFalse).A:=
            CreatePrimitiveDotExpr(FBuiltInNames[pbivnExceptObject],El);
          end;
        end
      else
        begin
        if El.ElseBranch<>nil then
          RaiseNotSupported(El.ElseBranch,AContext,20170205003014);
        T.BCatch:=ConvertImplBlockElements(ExceptBlock,AContext,true);
        end;
      end;
    Result:=T;
  finally
    if Result=nil then
      T.Free;
  end;
end;

function TPasToJSConverter.ConvertCaseOfStatement(El: TPasImplCaseOf;
  AContext: TConvertContext): TJSElement;
var
  SubEl: TPasImplElement;
  St: TPasImplCaseStatement;
  ok: Boolean;
  i, j: Integer;
  JSExpr: TJSElement;
  StList: TJSStatementList;
  Expr: TPasExpr;
  IfSt, LastIfSt: TJSIfStatement;
  TmpVarName: String;
  VarDecl: TJSVarDeclaration;
  VarSt: TJSVariableStatement;
  JSOrExpr: TJSLogicalOrExpression;
  JSAndExpr: TJSLogicalAndExpression;
  JSLEExpr: TJSRelationalExpressionLE;
  JSGEExpr: TJSRelationalExpressionGE;
  JSEQExpr: TJSEqualityExpressionSEQ;
begin
  Result:=nil;
  if UseSwitchStatement then
    begin
    // convert to switch statement
    // switch does not support ranges -> check
    ok:=true;
    for i:=0 to El.Elements.Count-1 do
      begin
      SubEl:=TPasImplElement(El.Elements[i]);
      if not (SubEl is TPasImplCaseStatement) then
        continue;
      St:=TPasImplCaseStatement(SubEl);
      for j:=0 to St.Expressions.Count-1 do
        begin
        Expr:=TPasExpr(St.Expressions[j]);
        if (Expr is TBinaryExpr) and (TBinaryExpr(Expr).Kind=pekRange) then
          begin
          ok:=false;
          break;
          end;
        end;
      if not ok then break;
      end;
    if ok then
      begin
      Result:=CreateSwitchStatement(El,AContext);
      exit;
      end;
    end;

  // convert to if statements
  StList:=TJSStatementList(CreateElement(TJSStatementList,El));
  ok:=false;
  try
    // create var $tmp=CaseExpr;
    TmpVarName:=AContext.CreateLocalIdentifier('$tmp');
    VarSt:=TJSVariableStatement(CreateElement(TJSVariableStatement,El.CaseExpr));
    StList.A:=VarSt;
    VarDecl:=TJSVarDeclaration(CreateElement(TJSVarDeclaration,El.CaseExpr));
    VarSt.A:=VarDecl;
    VarDecl.Name:=TmpVarName;
    VarDecl.Init:=ConvertExpression(El.CaseExpr,AContext);

    LastIfSt:=nil;
    for i:=0 to El.Elements.Count-1 do
      begin
      SubEl:=TPasImplElement(El.Elements[i]);
      if SubEl is TPasImplCaseStatement then
        begin
        St:=TPasImplCaseStatement(SubEl);
        // create for example "if (tmp==expr) || ((tmp>=expr) && (tmp<=expr)){}"
        IfSt:=TJSIfStatement(CreateElement(TJSIfStatement,SubEl));
        if LastIfSt=nil then
          StList.B:=IfSt
        else
          LastIfSt.BFalse:=IfSt;
        LastIfSt:=IfSt;

        for j:=0 to St.Expressions.Count-1 do
          begin
          Expr:=TPasExpr(St.Expressions[j]);
          if (Expr is TBinaryExpr) and (TBinaryExpr(Expr).Kind=pekRange) then
            begin
            // range -> create "(tmp>=left) && (tmp<=right)"
            // create "() && ()"
            JSAndExpr:=TJSLogicalAndExpression(CreateElement(TJSLogicalAndExpression,Expr));
            JSExpr:=JSAndExpr;
            // create "tmp>=left"
            JSGEExpr:=TJSRelationalExpressionGE(CreateElement(TJSRelationalExpressionGE,Expr));
            JSAndExpr.A:=JSGEExpr;
            JSGEExpr.A:=CreateIdentifierExpr(TmpVarName,El.CaseExpr,AContext);
            JSGEExpr.B:=ConvertExpression(TBinaryExpr(Expr).left,AContext);
            // create "tmp<=right"
            JSLEExpr:=TJSRelationalExpressionLE(CreateElement(TJSRelationalExpressionLE,Expr));
            JSAndExpr.B:=JSLEExpr;
            JSLEExpr.A:=CreateIdentifierExpr(TmpVarName,El.CaseExpr,AContext);
            JSLEExpr.B:=ConvertExpression(TBinaryExpr(Expr).right,AContext);
            end
          else
            begin
            // value -> create (tmp==Expr)
            JSEQExpr:=TJSEqualityExpressionSEQ(CreateElement(TJSEqualityExpressionSEQ,Expr));
            JSExpr:=JSEQExpr;
            JSEQExpr.A:=CreateIdentifierExpr(TmpVarName,El.CaseExpr,AContext);
            JSEQExpr.B:=ConvertExpression(Expr,AContext);
            end;
          if IfSt.Cond=nil then
            // first expression
            IfSt.Cond:=JSExpr
          else
            begin
            // multi expression -> append with OR
            JSOrExpr:=TJSLogicalOrExpression(CreateElement(TJSLogicalOrExpression,St));
            JSOrExpr.A:=IfSt.Cond;
            JSOrExpr.B:=JSExpr;
            IfSt.Cond:=JSOrExpr;
            end;
          end;
        // convert statement
        if St.Body<>nil then
          IfSt.BTrue:=ConvertElement(St.Body,AContext)
        else
          IfSt.BTrue:=TJSEmptyStatement(CreateElement(TJSEmptyStatement,St));
        end
      else if SubEl is TPasImplCaseElse then
        begin
        // Pascal 'else' or 'otherwise' -> create JS "else{}"
        if LastIfSt=nil then
          RaiseNotSupported(SubEl,AContext,20161128120802,'case-of needs at least one case');
        LastIfSt.BFalse:=ConvertImplBlockElements(El.ElseBranch,AContext,true);
        end
      else
        RaiseNotSupported(SubEl,AContext,20161128113055);
      end;

    ok:=true;
  finally
    if not ok then
      StList.Free;
  end;
  Result:=StList;
end;

function TPasToJSConverter.ConvertAsmStatement(El: TPasImplAsmStatement;
  AContext: TConvertContext): TJSElement;
var
  s: String;
  L: TJSLiteral;
  AsmLines: TStrings;
  Line, Col, StartLine: integer;
begin
  if AContext=nil then ;
  AsmLines:=El.Tokens;
  s:=Trim(AsmLines.Text);
  if (s<>'') and (s[length(s)]=';') then
    Delete(s,length(s),1);
  if s='' then
    Result:=TJSEmptyStatement(CreateElement(TJSEmptyStatement,El))
  else begin
    StartLine:=0;
    while (StartLine<AsmLines.Count) and (Trim(AsmLines[StartLine])='') do
      inc(StartLine);
    TPasResolver.UnmangleSourceLineNumber(El.SourceLinenumber,Line,Col);
    if StartLine>0 then
      Col:=1;
    L:=TJSLiteral.Create(Line+StartLine,Col,El.SourceFilename);
    L.Value.CustomValue:=TJSString(s);
    Result:=L;
  end;
end;

function TPasToJSConverter.ConvertConstValue(Value: TResEvalValue;
  AContext: TConvertContext; El: TPasElement): TJSElement;
var
  Ranges: TResEvalSet.TItems;
  Range: TResEvalSet.TItem;
  Call: TJSCallExpression;
  i: Integer;
begin
  Result:=nil;
  if Value=nil then
    RaiseNotSupported(El,AContext,20170910211948);
  case Value.Kind of
  revkBool:
    Result:=CreateLiteralBoolean(El,TResEvalBool(Value).B);
  revkEnum:
    Result:=CreateReferencePathExpr(TResEvalEnum(Value).GetEnumValue,AContext);
  revkInt:
    Result:=CreateLiteralNumber(El,TResEvalInt(Value).Int);
  revkUInt:
    Result:=CreateLiteralNumber(El,TResEvalUInt(Value).UInt);
  revkFloat:
    Result:=CreateLiteralNumber(El,TResEvalFloat(Value).FloatValue);
  revkString:
    Result:=CreateLiteralString(El,TResEvalString(Value).S);
  revkUnicodeString:
    Result:=CreateLiteralJSString(El,TResEvalUTF16(Value).S);
  revkSetOfInt:
    if Value.IdentEl is TPasExpr then
      Result:=ConvertElement(Value.IdentEl,AContext)
    else
      begin
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.ConvertConstValue Value=',Value.AsDebugString,' IdentEl=',GetObjName(Value.IdentEl));
      {$ENDIF}
      // rtl.createSet()
      Call:=CreateCallExpression(El);
      try
        Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnSet_Create]]);
        Ranges:=TResEvalSet(Value).Ranges;
        for i:=0 to length(Ranges)-1 do
          begin
          Range:=Ranges[i];
          {$IFDEF VerbosePas2JS}
          writeln('TPasToJSConverter.ConvertConstValue SetLiteral ',i,' ',Range.RangeStart,'..',Range.RangeEnd);
          {$ENDIF}
          if Range.RangeStart=Range.RangeEnd then
            begin
            // add one integer
            Call.AddArg(CreateLiteralNumber(El,Range.RangeStart));
            end
          else
            begin
            // range -> add three parameters: null,left,right
            Call.AddArg(CreateLiteralNull(El));
            Call.AddArg(CreateLiteralNumber(El,Range.RangeStart));
            Call.AddArg(CreateLiteralNumber(El,Range.RangeEnd));
            end;
          end;
        Result:=Call;
      finally
        if Result=nil then
          Call.Free;
      end;
      end
  else
    {$IFDEF VerbosePas2JS}
    writeln('TPasToJSConverter.ConvertConstValue Value=',Value.AsDebugString);
    {$ENDIF}
    RaiseNotSupported(El,AContext,20170910211951);
  end;
end;

function TPasToJSConverter.CreateImplementationSection(El: TPasModule;
  AContext: TConvertContext
  ): TJSFunctionDeclarationStatement;
var
  Src: TJSSourceElements;
  ImplContext: TSectionContext;
  ImplDecl: TJSElement;
  ImplVarSt: TJSVariableStatement;
  FunDecl: TJSFunctionDeclarationStatement;
  ModVarName, ImplVarName: String;
begin
  Result:=nil;
  // create function(){}
  FunDecl:=CreateFunctionSt(El,true,true);
  Src:=TJSSourceElements(FunDecl.AFunction.Body.A);

  // create section context (a function)
  ImplContext:=TSectionContext.Create(El,Src,AContext);
  try
    if coUseStrict in Options then
      AddToSourceElements(Src,CreateLiteralString(El,'use strict'));

    // add "var $mod = this;"
    ImplContext.ThisPas:=El;
    ModVarName:=FBuiltInNames[pbivnModule];
    AddToSourceElements(Src,CreateVarStatement(ModVarName,
      CreatePrimitiveDotExpr('this',El),El));
    ImplContext.AddLocalVar(ModVarName,El);

    // add var $impl = $mod.$impl
    ImplVarName:=FBuiltInNames[pbivnImplementation];
    ImplVarSt:=CreateVarStatement(ImplVarName,
      CreateMemberExpression([ModVarName,ImplVarName]),El.ImplementationSection);
    AddToSourceElements(Src,ImplVarSt);
    ImplContext.AddLocalVar(ImplVarName,El.ImplementationSection);

    // create implementation declarations
    ImplDecl:=ConvertDeclarations(El.ImplementationSection,ImplContext);
    if ImplDecl<>nil then
      RaiseInconsistency(20170910175032,El); // elements should have been added directly
    if Src.Statements[Src.Statements.Count-1].Node=ImplVarSt then
      exit; // no implementation
    // add impl declarations
    AddToSourceElements(Src,ImplDecl);
    Result:=FunDecl;
  finally
    ImplContext.Free;
    if Result=nil then
      FunDecl.Free;
  end;
end;

procedure TPasToJSConverter.CreateInitSection(El: TPasModule;
  Src: TJSSourceElements; AContext: TConvertContext);
begin
  // add initialization section
  if Assigned(El.InitializationSection) then
    AddToSourceElements(Src,ConvertInitializationSection(El.InitializationSection,AContext));
  // finalization: not supported
  if Assigned(El.FinalizationSection) then
    raise Exception.Create('TPasToJSConverter.ConvertInitializationSection: finalization section is not supported');
end;

function TPasToJSConverter.CreateDotExpression(aParent: TPasElement; Left,
  Right: TJSElement): TJSElement;
var
  Dot: TJSDotMemberExpression;
  RightParent: TJSElement;
  ok: Boolean;
begin
  Result:=nil;
  if Left=nil then
    RaiseInconsistency(20170201140827,aParent);
  if Right=nil then
    RaiseInconsistency(20170211192018,aParent);
  ok:=false;
  try
    // create a TJSDotMemberExpression of Left and the left-most identifier of Right
    // Left becomes the new left-most element of Right.
    Result:=Right;
    RightParent:=nil;
    repeat
      if (Right.ClassType=TJSCallExpression) then
        begin
        RightParent:=Right;
        Right:=TJSCallExpression(Right).Expr;
        if Right=nil then
          begin
          // left-most is nil -> insert Left
          TJSCallExpression(RightParent).Expr:=Left;
          ok:=true;
          exit;
          end;
        end
      else if (Right.ClassType=TJSBracketMemberExpression) then
        begin
        RightParent:=Right;
        Right:=TJSBracketMemberExpression(Right).MExpr;
        if Right=nil then
          begin
          // left-most is nil -> insert Left
          TJSBracketMemberExpression(RightParent).MExpr:=Left;
          ok:=true;
          exit;
          end;
        end
      else if (Right.ClassType=TJSDotMemberExpression) then
        begin
        RightParent:=Right;
        Right:=TJSDotMemberExpression(Right).MExpr;
        if Right=nil then
          begin
          // left-most is nil -> insert Left
          TJSDotMemberExpression(RightParent).MExpr:=Left;
          ok:=true;
          exit;
          end;
        end
      else if (Right.ClassType=TJSPrimaryExpressionIdent) then
        begin
        // left-most identifier found
        // -> replace it
        Dot := TJSDotMemberExpression(CreateElement(TJSDotMemberExpression, aParent));
        if Result=Right then
          Result:=Dot
        else if RightParent is TJSBracketMemberExpression then
          TJSBracketMemberExpression(RightParent).MExpr:=Dot
        else if RightParent is TJSCallExpression then
          TJSCallExpression(RightParent).Expr:=Dot
        else if RightParent is TJSDotMemberExpression then
          TJSDotMemberExpression(RightParent).MExpr:=Dot
        else
          begin
          Dot.Free;
          {$IFDEF VerbosePas2JS}
          writeln('TPasToJSConverter.CreateDotExpression Right=',GetObjName(Right),' RightParent=',GetObjName(RightParent),' Result=',GetObjName(Result));
          {$ENDIF}
          RaiseInconsistency(20170129141307,aParent);
          end;
        Dot.MExpr := Left;
        Dot.Name := TJSPrimaryExpressionIdent(Right).Name;
        FreeAndNil(Right);
        break;
        end
      else
        begin
        {$IFDEF VerbosePas2JS}
        writeln('CreateDotExpression Right=',Right.ClassName);
        {$ENDIF}
        DoError(20161024191240,nMemberExprMustBeIdentifier,sMemberExprMustBeIdentifier,[],aParent);
        end;
    until false;

    ok:=true;
  finally
    if not ok then
      begin
      Left.Free;
      FreeAndNil(Result);
      end;
  end;
end;

function TPasToJSConverter.CreateReferencedSet(El: TPasElement; SetExpr: TJSElement
  ): TJSElement;
var
  Call: TJSCallExpression;
begin
  Call:=CreateCallExpression(El);
  Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnSet_Reference]]);
  Call.AddArg(SetExpr);
  Result:=Call;
end;

function TPasToJSConverter.CreateCloneRecord(El: TPasElement;
  RecTypeEl: TPasRecordType; RecordExpr: TJSElement; AContext: TConvertContext
  ): TJSElement;
// create  "new RecordType(RecordExpr)
var
  NewExpr: TJSNewMemberExpression;
begin
  NewExpr:=TJSNewMemberExpression(CreateElement(TJSNewMemberExpression,El));
  NewExpr.MExpr:=CreateReferencePathExpr(RecTypeEl,AContext);
  NewExpr.Args:=TJSArguments(CreateElement(TJSArguments,El));
  NewExpr.AddArg(RecordExpr);
  Result:=NewExpr;
end;

function TPasToJSConverter.CreateCloneStaticArray(El: TPasElement;
  ArrTypeEl: TPasArrayType; ArrayExpr: TJSElement; AContext: TConvertContext
  ): TJSElement;
var
  Call: TJSCallExpression;
  Path: String;
  FuncContext: TFunctionContext;
begin
  if AContext.Resolver.HasStaticArrayCloneFunc(ArrTypeEl) then
    begin
    // TArrayType$clone(ArrayExpr);
    if ArrTypeEl.Name='' then
      RaiseNotSupported(El,AContext,20180218230407,'copy anonymous multi dim static array');
    if length(ArrTypeEl.Ranges)>1 then
      RaiseNotSupported(El,AContext,20180218231700,'copy multi dim static array');
    FuncContext:=AContext.GetFunctionContext;
    Path:=CreateReferencePath(ArrTypeEl,FuncContext,rpkPathAndName)
          +FBuiltInNames[pbifnArray_Static_Clone];
    Call:=CreateCallExpression(El);
    Call.Expr:=CreatePrimitiveDotExpr(Path,El);
    Call.AddArg(ArrayExpr);
    Result:=Call;
    end
  else
    begin
    // ArrayExpr.slice(0)
    Call:=CreateCallExpression(El);
    Call.Expr:=CreateDotExpression(El,ArrayExpr,CreatePrimitiveDotExpr('slice',El));
    Call.AddArg(CreateLiteralNumber(El,0));
    Result:=Call;
    end;
end;

function TPasToJSConverter.CreateCallback(El: TPasElement;
  ResolvedEl: TPasResolverResult; AContext: TConvertContext): TJSElement;
// El is a reference to a proc
// for a proc or nested proc simply use the function
// for a method create  "rtl.createCallback(Target,func)"
var
  Call: TJSCallExpression;
  Target: TJSElement;
  DotExpr: TJSDotMemberExpression;
  Prim: TJSPrimaryExpressionIdent;
  aName: String;
  DotPos: SizeInt;
  FunName: String;
  ProcScope: TPasProcedureScope;
begin
  Result:=nil;
  if not (ResolvedEl.IdentEl is TPasProcedure) then
    RaiseInconsistency(20170215140756,El);

  Target:=ConvertElement(El,AContext);

  ProcScope:=TPasProcedureScope(ResolvedEl.IdentEl.CustomData);
  if ProcScope.ClassScope=nil then
    begin
    // not a method -> simply use the function
    Result:=Target;
    exit;
    end;

  // a method -> create "rtl.createCallback(Target,func)"
  Call:=nil;
  try
    Call:=CreateCallExpression(El);
    // "rtl.createCallback"
    Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnProcType_Create]]);
    // add parameters
    {$IFDEF VerbosePas2JS}
    writeln('TPasToJSConverter.CreateCallback ',GetObjName(Target));
    {$ENDIF}
    FunName:='';
    // the last element of Target is the proc, chomp that off
    if Target.ClassType=TJSDotMemberExpression then
      begin
      // chomp dot member  ->  rtl.createCallback(scope,"FunName")
      DotExpr:=TJSDotMemberExpression(Target);
      FunName:=String(DotExpr.Name);
      DotPos:=PosLast('.',FunName);
      if DotPos>0 then
        begin
        // e.g.  path dot $class.funname
        // keep DotExpr, chomp funname
        DotExpr.Name:=TJSString(LeftStr(FunName,DotPos-1));
        FunName:=copy(FunName,DotPos+1);
        if not IsValidJSIdentifier(DotExpr.Name) then
          begin
          {$IFDEF VerbosePas2JS}
          writeln('TPasToJSConverter.CreateCallback ',GetObjName(Target),' DotExpr.Name="',DotExpr.Name,'"');
          {$ENDIF}
          DoError(20170215161802,nInvalidFunctionReference,sInvalidFunctionReference,[],El);
          end;
        end
      else
        begin
        // e.g.  path dot funname
        // delete DotExpr
        Target:=DotExpr.MExpr;
        DotExpr.MExpr:=nil;
        FreeAndNil(DotExpr);
        end;
      if not IsValidJSIdentifier(TJSString(FunName)) then
        begin
        {$IFDEF VerbosePas2JS}
        writeln('TPasToJSConverter.CreateCallback ',GetObjName(Target),' FunName="',FunName,'"');
        {$ENDIF}
        DoError(20170215161802,nInvalidFunctionReference,sInvalidFunctionReference,[],El);
        end;
      Call.AddArg(Target);
      // add function name as parameter
      Call.AddArg(CreateLiteralString(El,FunName));
      end
    else if Target.ClassType=TJSPrimaryExpressionIdent then
      begin
      Prim:=TJSPrimaryExpressionIdent(Target);
      aName:=String(Prim.Name);
      DotPos:=PosLast('.',aName);
      if DotPos<1 then
        DoError(20170418135806,nInvalidFunctionReference,sInvalidFunctionReference,[],El);
      // chomp dotted identifier   ->  rtl.createCallback(scope,"FunName")
      FunName:=copy(aName,DotPos+1);
      Prim.Name:=TJSString(LeftStr(aName,DotPos-1));
      Call.AddArg(Prim);
      // add function name as parameter
      Call.AddArg(CreateLiteralString(El,FunName));
      end
    else
      begin
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.CreateCallback invalid Scope=',GetObjName(Target));
      {$ENDIF}
      DoError(20170418135820,nInvalidFunctionReference,sInvalidFunctionReference,[],El);
      end;

    Result:=Call;
  finally
    if Result=nil then
      begin
      Target.Free;
      Call.Free;
      end;
  end;
end;

function TPasToJSConverter.CreateAssignStatement(LeftEl: TPasElement;
  AssignContext: TAssignContext): TJSElement;
var
  LHS: TJSElement;
  AssignSt: TJSSimpleAssignStatement;
begin
  Result:=nil;
  LHS:=ConvertElement(LeftEl,AssignContext);
  if AssignContext.Call<>nil then
    begin
    // has a setter -> right side was already added as parameter
    if AssignContext.RightSide<>nil then
      begin
      LHS.Free;
      RaiseInconsistency(20170207215447,LeftEl);
      end;
    Result:=LHS;
    end
  else
    begin
    AssignSt:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,AssignContext.PasElement));
    AssignSt.LHS:=LHS;
    AssignSt.Expr:=AssignContext.RightSide;
    AssignContext.RightSide:=nil;
    Result:=AssignSt;
    end;
end;

function TPasToJSConverter.CreateTypeInfoRef(El: TPasType;
  AContext: TConvertContext; ErrorEl: TPasElement): TJSElement;
var
  aName, aModName: String;
  CurEl: TPasElement;
  aModule: TPasModule;
  Bracket: TJSBracketMemberExpression;
begin
  aName:=GetTypeInfoName(El,AContext,ErrorEl);
  if aName=FBuiltInNames[pbivnRTTILocal] then
    Result:=CreatePrimitiveDotExpr(aName,El)
  else if LeftStr(aName,length(FBuiltInNames[pbivnRTL])+1)=FBuiltInNames[pbivnRTL]+'.' then
    Result:=CreatePrimitiveDotExpr(aName,El)
  else
    begin
    CurEl:=El;
    while CurEl<>nil do
      begin
      if CurEl is TPasSection then
        begin
        aModule:=CurEl.Parent as TPasModule;
        aModName:=AContext.GetLocalName(aModule);
        if aModName='' then
          aModName:=TransformModuleName(aModule,true,AContext);
        Bracket:=TJSBracketMemberExpression(CreateElement(TJSBracketMemberExpression,El));
        Bracket.MExpr:=CreateMemberExpression([aModName,FBuiltInNames[pbivnRTTI]]);
        Bracket.Name:=CreateLiteralString(El,aName);
        Result:=Bracket;
        exit;
        end;
      CurEl:=CurEl.Parent;
      end;
    // not supported
    aName:=El.Name;
    if aName='' then aName:=El.ClassName;
    DoError(20170905152041,nTypeXCannotBePublished,sTypeXCannotBePublished,
      [aName],ErrorEl);
    end;
end;

function TPasToJSConverter.CreateRTTIArgList(Parent: TPasElement;
  Args: TFPList; AContext: TConvertContext): TJSElement;
var
  Params: TJSArrayLiteral;
  i: Integer;
begin
  Result:=nil;
  if Args.Count=0 then
    Result:=CreateLiteralNull(Parent)
  else
    begin
    try
      Params:=TJSArrayLiteral(CreateElement(TJSArrayLiteral,Parent));
      for i:=0 to Args.Count-1 do
        AddRTTIArgument(TPasArgument(Args[i]),Params,AContext);
      Result:=Params;
    finally
      if Result=nil then
        Params.Free;
    end;
  end;
end;

procedure TPasToJSConverter.AddRTTIArgument(Arg: TPasArgument;
  TargetParams: TJSArrayLiteral; AContext: TConvertContext);
var
  Param: TJSArrayLiteral;
  ArgName: String;
  Flags: Integer;
  ArrType: TPasArrayType;
begin
  // for each param add  "["argname",argtype,flags]"  Note: flags only if >0
  Param:=TJSArrayLiteral(CreateElement(TJSArrayLiteral,Arg));
  TargetParams.Elements.AddElement.Expr:=Param;
  // add "argname"
  ArgName:=TransformVariableName(Arg,Arg.Name,AContext);
  Param.Elements.AddElement.Expr:=CreateLiteralString(Arg,ArgName);
  Flags:=0;
  // add "argtype"
  if Arg.ArgType=nil then
    // untyped
    Param.Elements.AddElement.Expr:=CreateLiteralNull(Arg)
  else if (Arg.ArgType.Name='') and (Arg.ArgType.ClassType=TPasArrayType) then
    begin
    // open array param
    inc(Flags,pfArray);
    ArrType:=TPasArrayType(Arg.ArgType);
    Param.Elements.AddElement.Expr:=CreateTypeInfoRef(ArrType.ElType,AContext,Arg);
    end
  else
    Param.Elements.AddElement.Expr:=CreateTypeInfoRef(Arg.ArgType,AContext,Arg);
  // add flags
  case Arg.Access of
    argDefault: ;
    argConst: inc(Flags,pfConst);
    argVar: inc(Flags,pfVar);
    argOut: inc(Flags,pfOut);
  else
    RaiseNotSupported(Arg,AContext,20170409192127,AccessNames[Arg.Access]);
  end;
  if Flags>0 then
    Param.Elements.AddElement.Expr:=CreateLiteralNumber(Arg,Flags);
end;

function TPasToJSConverter.CreateRTTINewType(El: TPasType;
  const CallFuncName: string; IsForward: boolean; AContext: TConvertContext;
  out ObjLit: TJSObjectLiteral): TJSCallExpression;
// module.$rtti.$Something("name",{})
var
  RttiPath, TypeName: String;
  Call: TJSCallExpression;
  aModule: TPasModule;
begin
  Result:=nil;
  ObjLit:=nil;
  // get module path
  aModule:=El.GetModule;
  if aModule=nil then
    RaiseInconsistency(20170418115552,El);
  RttiPath:=AContext.GetLocalName(aModule);
  if RttiPath='' then
    RttiPath:=TransformModuleName(aContext.GetRootModule,true,AContext);

  Call:=CreateCallExpression(El);
  try
    // module.$rtti.$Something
    Call.Expr:=CreateMemberExpression([RttiPath,FBuiltInNames[pbivnRTTI],CallFuncName]);
    // add param "typename"
    TypeName:=GetTypeInfoName(El,AContext,El);
    Call.AddArg(CreateLiteralString(El,TypeName));
    if not IsForward then
      begin
      // add {}
      ObjLit:=TJSObjectLiteral(CreateElement(TJSObjectLiteral,El));
      Call.AddArg(ObjLit);
      end;
    Result:=Call;
  finally
    if Result=nil then
      Call.Free;
  end;
end;

function TPasToJSConverter.CreateRTTIClassField(V: TPasVariable;
  AContext: TConvertContext): TJSElement;
// create $r.addField("varname",typeinfo);
var
  Call: TJSCallExpression;
var
  JSTypeInfo: TJSElement;
  aName: String;
begin
  Result:=nil;
  JSTypeInfo:=CreateTypeInfoRef(V.VarType,AContext,V);
  // Note: create JSTypeInfo first, it may raise an exception
  Call:=CreateCallExpression(V);
  // $r.addField
  Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTTILocal],FBuiltInNames[pbifnRTTIAddField]]);
  // param "varname"
  aName:=TransformVariableName(V,AContext);
  Call.AddArg(CreateLiteralString(V,aName));
  // param typeinfo
  Call.AddArg(JSTypeInfo);
  Result:=Call;
end;

function TPasToJSConverter.CreateRTTIClassMethod(Proc: TPasProcedure;
  AContext: TConvertContext): TJSElement;
// create $r.addMethod("funcname",methodkind,params,resulttype,options)
var
  OptionsEl: TJSObjectLiteral;
  ResultTypeInfo: TJSElement;
  Call: TJSCallExpression;

  procedure AddOption(const aName: String; JS: TJSElement);
  var
    ObjLit: TJSObjectLiteralElement;
  begin
    if OptionsEl=nil then
      begin
      OptionsEl:=TJSObjectLiteral(CreateElement(TJSObjectLiteral,Proc));
      if ResultTypeInfo=nil then
        Call.AddArg(CreateLiteralNull(Proc));
      Call.AddArg(OptionsEl);
      end;
    ObjLit:=OptionsEl.Elements.AddElement;
    ObjLit.Name:=TJSString(aName);
    ObjLit.Expr:=JS;
  end;

var
  FunName: String;
  C: TClass;
  MethodKind, Flags: Integer;
  ResultEl: TPasResultElement;
  ProcScope, OverriddenProcScope: TPasProcedureScope;
  OverriddenClass: TPasClassType;
begin
  Result:=nil;
  if Proc.IsOverride then
    begin
    ProcScope:=Proc.CustomData as TPasProcedureScope;
    if ProcScope.OverriddenProc.Visibility=visPublished then
      begin
      // overridden proc is published as well
      OverriddenProcScope:=ProcScope.OverriddenProc.CustomData as TPasProcedureScope;
      OverriddenClass:=OverriddenProcScope.ClassScope.Element as TPasClassType;
      if HasTypeInfo(OverriddenClass,AContext) then
        exit; // overridden proc was already published in ancestor
      end;
    end;
  OptionsEl:=nil;
  ResultTypeInfo:=nil;
  try
    // $r.addMethod
    Call:=CreateCallExpression(Proc);
    Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTTILocal],FBuiltInNames[pbifnRTTIAddMethod]]);

    // param "funname"
    FunName:=TransformVariableName(Proc,AContext);
    Call.AddArg(CreateLiteralString(Proc,FunName));

    // param methodkind as number
    C:=Proc.ClassType;
    if C=TPasProcedure then
      MethodKind:=ord(mkProcedure)
    else if C=TPasFunction then
      MethodKind:=ord(mkFunction)
    else if C=TPasConstructor then
      MethodKind:=ord(mkConstructor)
    else if C=TPasDestructor then
      MethodKind:=ord(mkDestructor)
    else if C=TPasClassProcedure then
      MethodKind:=ord(mkClassProcedure)
    else if C=TPasClassFunction then
      MethodKind:=ord(mkClassFunction)
    else
      RaiseNotSupported(Proc,AContext,20170409190242);
    Call.AddArg(CreateLiteralNumber(Proc,MethodKind));

    // param params as []
    Call.AddArg(CreateRTTIArgList(Proc,Proc.ProcType.Args,AContext));

    // param resulttype as typeinfo reference
    if C.InheritsFrom(TPasFunction) then
      begin
      ResultEl:=TPasFunction(Proc).FuncType.ResultEl;
      ResultTypeInfo:=CreateTypeInfoRef(ResultEl.ResultType,AContext,ResultEl);
      if ResultTypeInfo<>nil then
        Call.AddArg(ResultTypeInfo);
      end;

    // param options if needed as {}
    Flags:=0;
    if Proc.IsStatic then
      inc(Flags,pfStatic);
    if ptmVarargs in Proc.ProcType.Modifiers then
      inc(Flags,pfVarargs);
    if Proc.IsExternal then
      inc(Flags,pfExternal);
    if Flags>0 then
      AddOption(FBuiltInNames[pbivnRTTIProcFlags],CreateLiteralNumber(Proc,Flags));

    Result:=Call;
  finally
    if Result=nil then
      Call.Free;
  end;
end;

function TPasToJSConverter.CreateRTTIClassProperty(Prop: TPasProperty;
  AContext: TConvertContext): TJSElement;
// create  $r.addProperty("propname",flags,result,"getter","setter",{options})
var
  Call: TJSCallExpression;
  OptionsEl: TJSObjectLiteral;

  function GetAccessorName(Decl: TPasElement): String;
  begin
    Result:=TransformVariableName(Decl,AContext);
  end;

  procedure AddOption(const aName: String; JS: TJSElement);
  var
    ObjLit: TJSObjectLiteralElement;
  begin
    if OptionsEl=nil then
      begin
      OptionsEl:=TJSObjectLiteral(CreateElement(TJSObjectLiteral,Prop));
      Call.AddArg(OptionsEl);
      end;
    ObjLit:=OptionsEl.Elements.AddElement;
    ObjLit.Name:=TJSString(aName);
    ObjLit.Expr:=JS;
  end;

var
  PropName: String;
  Flags: Integer;
  GetterPas, SetterPas, DeclEl: TPasElement;
  ResultTypeInfo, DefValue: TJSElement;
  VarType: TPasType;
  StoredExpr, IndexExpr: TPasExpr;
  StoredResolved, VarTypeResolved: TPasResolverResult;
  StoredValue, PasValue, IndexValue: TResEvalValue;
begin
  Result:=nil;
  OptionsEl:=nil;
  try
    // $r.addProperty
    Call:=CreateCallExpression(Prop);
    Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTTILocal],FBuiltInNames[pbifnRTTIAddProperty]]);

    // param "propname"
    PropName:=TransformVariableName(Prop,Prop.Name,AContext);
    Call.AddArg(CreateLiteralString(Prop,PropName));

    // add flags
    Flags:=0;
    GetterPas:=AContext.Resolver.GetPasPropertyGetter(Prop);
    if GetterPas is TPasProcedure then
      inc(Flags,pfGetFunction);
    SetterPas:=AContext.Resolver.GetPasPropertySetter(Prop);
    if SetterPas is TPasProcedure then
      inc(Flags,pfSetProcedure);
    StoredExpr:=AContext.Resolver.GetPasPropertyStoredExpr(Prop);
    IndexExpr:=AContext.Resolver.GetPasPropertyIndex(Prop);
    if IndexExpr<>nil then
      inc(Flags,pfHasIndex);
    if StoredExpr<>nil then
      begin
      AContext.Resolver.ComputeElement(StoredExpr,StoredResolved,[rcNoImplicitProc]);
      if StoredResolved.IdentEl is TPasProcedure then
        // stored <function>
        inc(Flags,pfStoredFunction)
      else
        begin
        if (StoredResolved.BaseType=btBoolean) and (StoredResolved.ExprEl<>nil) then
          begin
          // could be a const boolean
          // -> try evaluating const boolean
          StoredValue:=AContext.Resolver.Eval(StoredExpr,[]);
          if StoredValue<>nil then
            try
              // stored <const bool>
              if StoredValue.Kind<>revkBool then
                RaiseInconsistency(20170924082845,Prop);
              StoredExpr:=nil;
              if TResEvalBool(StoredValue).B then
                inc(Flags,pfStoredTrue)
              else
                inc(Flags,pfStoredFalse);
            finally
              ReleaseEvalValue(StoredValue);
            end;
          end;
        if StoredExpr<>nil then
          // stored <field>
          inc(Flags,pfStoredField);
        end;
      end;
    Call.AddArg(CreateLiteralNumber(Prop,Flags));

    // add type
    VarType:=AContext.Resolver.GetPasPropertyType(Prop);
    AContext.Resolver.ComputeElement(VarType,VarTypeResolved,[rcType]);
    ResultTypeInfo:=CreateTypeInfoRef(VarType,AContext,Prop);
    if ResultTypeInfo<>nil then
      Call.AddArg(ResultTypeInfo)
    else
      Call.AddArg(CreateLiteralNull(Prop));

    // add "getter"
    if GetterPas=nil then
      Call.AddArg(CreateLiteralString(Prop,''))
    else
      Call.AddArg(CreateLiteralString(Prop,GetAccessorName(GetterPas)));

    // add "setter"
    if SetterPas=nil then
      Call.AddArg(CreateLiteralString(Prop,''))
    else
      Call.AddArg(CreateLiteralString(Prop,GetAccessorName(SetterPas)));

    // add option "index"
    IndexExpr:=AContext.Resolver.GetPasPropertyIndex(Prop);
    if IndexExpr<>nil then
      begin
      IndexValue:=AContext.Resolver.Eval(IndexExpr,[refConst]);
      try
        AddOption(FBuiltInNames[pbivnRTTIPropIndex],
          ConvertConstValue(IndexValue,AContext,Prop));
      finally
        ReleaseEvalValue(IndexValue);
      end;
      end;

    // add option "stored"
    if StoredExpr<>nil then
      begin
      DeclEl:=(StoredExpr.CustomData as TResolvedReference).Declaration;
      AddOption(FBuiltInNames[pbivnRTTIPropStored],
        CreateLiteralString(Prop,GetAccessorName(DeclEl)));
      end;

    // add option "defaultvalue"
    if Prop.DefaultExpr<>nil then
      begin
      PasValue:=AContext.Resolver.Eval(Prop.DefaultExpr,[refConst],false);
      try
        DefValue:=nil;
        if VarTypeResolved.BaseType=btSet then
          DefValue:=CreateValInit(VarType,Prop.DefaultExpr,Prop.DefaultExpr,AContext);
        if DefValue=nil then
          DefValue:=ConvertConstValue(PasValue,AContext,Prop);
        AddOption(FBuiltInNames[pbivnRTTIPropDefault],DefValue);
      finally
        ReleaseEvalValue(PasValue);
      end;
      end;

    Result:=Call;
  finally
    if Result=nil then
      Call.Free;
  end;
end;

procedure TPasToJSConverter.CreateRTTIAnonymous(El: TPasType;
  AContext: TConvertContext; var First, Last: TJSStatementList);
// if El has any anonymous types, create the RTTI
var
  C: TClass;
  JS: TJSElement;
begin
  if El.Name<>'' then
    RaiseNotSupported(El,AContext,20170905162324,'inconsistency');

  C:=El.ClassType;
  if C=TPasArrayType then
    begin
    JS:=ConvertArrayType(TPasArrayType(El),AContext);
    AddToStatementList(First,Last,JS,El);
    end;
end;

function TPasToJSConverter.CreateGetEnumeratorLoop(El: TPasImplForLoop;
  AContext: TConvertContext): TJSElement;
//  for Item in List do
// convert to
//  var $in=List.GetEnumerator();
//  try{
//    while ($in.MoveNext()){
//      Item=$in.getCurrent;
//      // code
//    }
//  } finally {
//    $in=rtl.freeLoc($in);
//  };
var
  PosEl: TPasElement;
  CurInVarName: String;

  function CreateInName: TJSElement;
  var
    Ident: TJSPrimaryExpressionIdent;
  begin
    Ident:=TJSPrimaryExpressionIdent(CreateElement(TJSPrimaryExpressionIdent,PosEl));
    Ident.Name:=TJSString(CurInVarName); // do not lowercase
    Result:=Ident;
  end;

var
  ForScope: TPasForLoopScope;
  Statements: TJSStatementList;
  VarSt: TJSVariableStatement;
  FuncContext: TConvertContext;
  List, GetCurrent, J: TJSElement;
  Call: TJSCallExpression;
  TrySt: TJSTryFinallyStatement;
  WhileSt: TJSWhileStatement;
  AssignSt: TJSSimpleAssignStatement;
  GetEnumeratorFunc, MoveNextFunc: TPasFunction;
  CurrentProp: TPasProperty;
  DotContext: TDotContext;
begin
  ForScope:=TPasForLoopScope(El.CustomData);

  // find function GetEnumerator
  GetEnumeratorFunc:=ForScope.GetEnumerator;
  if (GetEnumeratorFunc=nil) then
    RaiseNotSupported(El,AContext,20171225104212);
  if GetEnumeratorFunc.ClassType<>TPasFunction then
    RaiseNotSupported(El,AContext,20171225104237);
  // find function MoveNext
  MoveNextFunc:=ForScope.MoveNext;
  if (MoveNextFunc=nil) then
    RaiseNotSupported(El,AContext,20171225104249);
  if MoveNextFunc.ClassType<>TPasFunction then
    RaiseNotSupported(El,AContext,20171225104256);
  // find property Current
  CurrentProp:=ForScope.Current;
  if (CurrentProp=nil) then
    RaiseNotSupported(El,AContext,20171225104306);
  if CurrentProp.ClassType<>TPasProperty then
    RaiseNotSupported(El,AContext,20171225104316);

  // get function context
  FuncContext:=AContext;
  while (FuncContext.Parent<>nil) and (not (FuncContext is TFunctionContext)) do
    FuncContext:=FuncContext.Parent;

  PosEl:=El;
  Statements:=TJSStatementList(CreateElement(TJSStatementList,PosEl));
  DotContext:=nil;
  try
    // var...
    VarSt:=TJSVariableStatement(CreateElement(TJSVariableStatement,PosEl));
    Statements.A:=VarSt;
    // List
    List:=ConvertElement(El.StartExpr,AContext); // beware: might fail
    PosEl:=El.StartExpr;
    // List.GetEnumerator()
    Call:=TJSCallExpression(CreateElement(TJSCallExpression,PosEl));
    Call.Expr:=CreateDotExpression(PosEl,List,CreateIdentifierExpr(GetEnumeratorFunc,AContext));
    // var $in=
    CurInVarName:=FuncContext.CreateLocalIdentifier(FBuiltInNames[pbivnLoopIn]);
    VarSt.A:=CreateVarDecl(CurInVarName,Call,PosEl);

    PosEl:=El.VariableName;
    // try()
    TrySt:=TJSTryFinallyStatement(CreateElement(TJSTryFinallyStatement,PosEl));
    Statements.B:=TrySt;

    // while ()
    WhileSt:=TJSWhileStatement(CreateElement(TJSWhileStatement,PosEl));
    TrySt.Block:=WhileSt;
    // $in.MoveNext()
    Call:=TJSCallExpression(CreateElement(TJSCallExpression,PosEl));
    WhileSt.Cond:=Call;
    Call.Expr:=CreateDotExpression(PosEl,CreateInName,CreateIdentifierExpr(MoveNextFunc,AContext));

    // Item=$in.getCurrent;
    AssignSt:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,PosEl));
    WhileSt.Body:=AssignSt;
    AssignSt.LHS:=ConvertElement(El.VariableName,AContext); // beware: might fail

    DotContext:=TDotContext.Create(El.StartExpr,nil,AContext);
    GetCurrent:=CreatePropertyGet(CurrentProp,nil,DotContext,PosEl); // beware: might fail
    FreeAndNil(DotContext);
    AssignSt.Expr:=CreateDotExpression(PosEl,CreateInName,GetCurrent);

    // add body
    if El.Body<>nil then
      begin
      J:=ConvertElement(El.Body,AContext); // beware: might fail
      if J<>nil then
        begin
        List:=TJSStatementList(CreateElement(TJSStatementList,PosEl));
        TJSStatementList(List).A:=WhileSt.Body;
        TJSStatementList(List).B:=J;
        WhileSt.Body:=List;
        end;
      end;

    // finally{ $in=rtl.freeLoc($in) }
    PosEl:=El.StartExpr;
    TrySt.BFinally:=CreateCallRTLFreeLoc(CreateInName,CreateInName,PosEl);

    Result:=Statements;
  finally
    DotContext.Free;
    if Result=nil then
      Statements.Free;
  end;
end;

function TPasToJSConverter.CreateCallRTLFreeLoc(Setter, Getter: TJSElement;
  Src: TPasElement): TJSElement;
// create "Setter=rtl.freeLoc(Getter)"
var
  Call: TJSCallExpression;
  AssignSt: TJSSimpleAssignStatement;
begin
  Call:=CreateCallExpression(Src);
  Call.Expr:=CreateMemberExpression([GetBuildInNames(pbivnRTL),GetBuildInNames(pbifnFreeLocalVar)]);
  Call.Args.AddElement(Getter);
  AssignSt:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,Src));
  AssignSt.LHS:=Setter;
  AssignSt.Expr:=Call;
  Result:=AssignSt;
end;

function TPasToJSConverter.CreatePropertyGet(Prop: TPasProperty;
  Ref: TResolvedReference; AContext: TConvertContext; PosEl: TPasElement
  ): TJSElement;
var
  Decl: TPasElement;
  IndexExpr: TPasExpr;
  Call: TJSCallExpression;
  Value: TResEvalValue;
  Name: String;
begin
  Decl:=AContext.Resolver.GetPasPropertyGetter(Prop);
  if Decl is TPasFunction then
    begin
    // call function
    Value:=nil;
    Call:=CreateCallExpression(PosEl);
    try
      Call.Expr:=CreateReferencePathExpr(Decl,AContext,false,Ref);
      IndexExpr:=AContext.Resolver.GetPasPropertyIndex(Prop);
      if IndexExpr<>nil then
        begin
        Value:=AContext.Resolver.Eval(IndexExpr,[refConst]);
        Call.AddArg(ConvertConstValue(Value,AContext.GetFunctionContext,PosEl));
        end;
      Result:=Call;
    finally
      ReleaseEvalValue(Value);
      if Result=nil then
        Call.Free;
    end;
    end
  else
    begin
    // read field
    Name:=CreateReferencePath(Decl,AContext,rpkPathAndName,false,Ref);
    Result:=CreatePrimitiveDotExpr(Name,PosEl);
    end;
end;

function TPasToJSConverter.StorePrecompiledJS(El: TJSElement): string;
var
  aWriter: TBufferWriter;
  aJSWriter: TJSWriter;
begin
  aJSWriter:=nil;
  aWriter:=TBufferWriter.Create(1000);
  try
    aJSWriter:=TJSWriter.Create(aWriter);
    aJSWriter.IndentSize:=2;
    aJSWriter.WriteJS(El);
    Result:=aWriter.AsAnsistring;
  finally
    aJSWriter.Free;
    aWriter.Free;
  end;
end;

function TPasToJSConverter.ConvertImplBlock(El: TPasImplBlock;
  AContext: TConvertContext): TJSElement;

begin
  //writeln('TPasToJSConverter.ConvertImplBlock ');
  Result:=Nil;
  if (El is TPasImplStatement) then
    Result:=ConvertStatement(TPasImplStatement(El),AContext)
  else if (El.ClassType=TPasImplIfElse) then
    Result:=ConvertIfStatement(TPasImplIfElse(El),AContext)
  else if (El.ClassType=TPasImplRepeatUntil) then
    Result:=ConvertRepeatStatement(TPasImplRepeatUntil(El),AContext)
  else if (El.ClassType=TPasImplBeginBlock) then
    Result:=ConvertBeginEndStatement(TPasImplBeginBlock(El),AContext,true)
  else if (El.ClassType=TInitializationSection) then
    Result:=ConvertInitializationSection(TInitializationSection(El),AContext)
  else if (El.ClassType=TFinalizationSection) then
    Result:=ConvertFinalizationSection(TFinalizationSection(El),AContext)
  else if (El.ClassType=TPasImplTry) then
    Result:=ConvertTryStatement(TPasImplTry(El),AContext)
  else if (El.ClassType=TPasImplCaseOf) then
    Result:=ConvertCaseOfStatement(TPasImplCaseOf(El),AContext)
  else
    RaiseNotSupported(El,AContext,20161024192156);
(*
  TPasImplBlock = class(TPasImplElement)
  TPasImplCaseOf = class(TPasImplBlock)
  TPasImplStatement = class(TPasImplBlock)
  TPasImplCaseElse = class(TPasImplBlock)
  TPasImplTry = class(TPasImplBlock)
  TPasImplTryHandler = class(TPasImplBlock)
  TPasImplTryFinally = class(TPasImplTryHandler)
  TPasImplTryExcept = class(TPasImplTryHandler)
  TPasImplTryExceptElse = class(TPasImplTryHandler)

*)
end;

function TPasToJSConverter.ConvertPackage(El: TPasPackage;
  AContext: TConvertContext): TJSElement;

begin
  RaiseNotSupported(El,AContext,20161024192555);
  Result:=Nil;
  // ToDo TPasPackage = class(TPasElement)
end;

function TPasToJSConverter.ConvertResString(El: TPasResString;
  AContext: TConvertContext): TJSElement;

begin
  RaiseNotSupported(El,AContext,20161024192604);
  Result:=Nil;
  // ToDo: TPasResString
end;

function TPasToJSConverter.ConvertVariable(El: TPasVariable;
  AContext: TConvertContext): TJSElement;

Var
  V : TJSVarDeclaration;
  vm: TVariableModifier;
begin
  for vm in TVariableModifier do
    if (vm in El.VarModifiers) and (not (vm in [vmClass,vmExternal])) then
      RaiseNotSupported(El,AContext,20170208141622,'modifier '+VariableModifierNames[vm]);
  if El.LibraryName<>nil then
    RaiseNotSupported(El,AContext,20170208141844,'library name');
  if El.AbsoluteExpr<>nil then
    RaiseNotSupported(El,AContext,20170208141926,'absolute');

  V:=TJSVarDeclaration(CreateElement(TJSVarDeclaration,El));
  V.Name:=TransformVariableName(El,AContext);
  V.Init:=CreateVarInit(El,AContext);
  Result:=V;
end;

function TPasToJSConverter.ConvertProperty(El: TPasProperty;
  AContext: TConvertContext): TJSElement;

begin
  Result:=Nil;
  if El.ImplementsFunc<>nil then
    RaiseNotSupported(El.ImplementsFunc,AContext,20170215102923,'property implements function');
  if El.DispIDExpr<>nil then
    RaiseNotSupported(El.DispIDExpr,AContext,20170215103029,'property dispid expression');
  // does not need any declaration. Access is redirected to getter/setter.
  // RTTI is created in CreateRTTIClassProperty
end;

function TPasToJSConverter.ConvertExportSymbol(El: TPasExportSymbol;
  AContext: TConvertContext): TJSElement;

begin
  RaiseNotSupported(El,AContext,20161024192650);
  Result:=Nil;
  // ToDo: TPasExportSymbol
end;

function TPasToJSConverter.ConvertLabels(El: TPasLabels;
  AContext: TConvertContext): TJSElement;

begin
  RaiseNotSupported(El,AContext,20161024192701);
  Result:=Nil;
  // ToDo: TPasLabels = class(TPasImplElement)
end;

function TPasToJSConverter.ConvertRaiseStatement(El: TPasImplRaise;
  AContext: TConvertContext): TJSElement;

Var
  E : TJSElement;
  T : TJSThrowStatement;

begin
  if El.ExceptObject<>Nil then
    E:=ConvertElement(El.ExceptObject,AContext)
  else
    E:=CreatePrimitiveDotExpr(FBuiltInNames[pbivnExceptObject],El);
  T:=TJSThrowStatement(CreateElement(TJSThrowStatement,El));
  T.A:=E;
  Result:=T;
end;

function TPasToJSConverter.ConvertAssignStatement(El: TPasImplAssign;
  AContext: TConvertContext): TJSElement;

Var
  LHS: TJSElement;
  T: TJSAssignStatement;
  AssignContext: TAssignContext;
  Flags: TPasResolverComputeFlags;
  LeftIsProcType: Boolean;
  Call: TJSCallExpression;
  MinVal, MaxVal: MaxPrecInt;
  RightTypeEl: TPasType;

begin
  Result:=nil;
  LHS:=nil;
  AssignContext:=TAssignContext.Create(El,nil,AContext);
  try
    if AContext.Resolver<>nil then
      begin
      AContext.Resolver.ComputeElement(El.left,AssignContext.LeftResolved,[rcNoImplicitProc]);
      Flags:=[];
      LeftIsProcType:=AContext.Resolver.IsProcedureType(AssignContext.LeftResolved,true);
      if LeftIsProcType then
        begin
        if msDelphi in AContext.CurrentModeSwitches then
          Include(Flags,rcNoImplicitProc)
        else
          Include(Flags,rcNoImplicitProcType);
        end;
      AContext.Resolver.ComputeElement(El.right,AssignContext.RightResolved,Flags);
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.ConvertAssignStatement Left={',GetResolverResultDbg(AssignContext.LeftResolved),'} Right={',GetResolverResultDbg(AssignContext.RightResolved),'}');
      {$ENDIF}
      if LeftIsProcType and (msDelphi in AContext.CurrentModeSwitches)
          and (AssignContext.RightResolved.BaseType=btProc) then
        begin
          // Delphi allows assigning a proc without @: proctype:=proc
          AssignContext.RightSide:=CreateCallback(El.right,AssignContext.RightResolved,AContext);
        end
      else if AssignContext.RightResolved.BaseType=btNil then
        begin
        if AContext.Resolver.IsArrayType(AssignContext.LeftResolved) then
          begin
          // array:=nil -> array:=[]
          AssignContext.RightSide:=TJSArrayLiteral(CreateElement(TJSArrayLiteral,El.right));
          end;
        end;
      end;
    if AssignContext.RightSide=nil then
      AssignContext.RightSide:=ConvertElement(El.right,AContext);
    if (AssignContext.RightResolved.BaseType=btSet)
        and (AssignContext.RightResolved.IdentEl<>nil) then
      begin
      // right side is a set variable -> create reference
      {$IFDEF VerbosePas2JS}
      //writeln('TPasToJSConverter.ConvertAssignStatement SET variable Right={',GetResolverResultDbg(AssignContext.RightResolved),'} AssignContext.RightResolved.IdentEl=',GetObjName(AssignContext.RightResolved.IdentEl));
      {$ENDIF}
      // create  rtl.refSet(right)
      AssignContext.RightSide:=CreateReferencedSet(El.right,AssignContext.RightSide);
      end
    else if AssignContext.RightResolved.BaseType=btContext then
      begin
      RightTypeEl:=AContext.Resolver.ResolveAliasType(AssignContext.RightResolved.TypeEl);
      if RightTypeEl.ClassType=TPasArrayType then
        begin
        if length(TPasArrayType(RightTypeEl).Ranges)>0 then
          begin
          // right side is a static array -> clone
          {$IFDEF VerbosePas2JS}
          writeln('TPasToJSConverter.ConvertAssignStatement STATIC ARRAY variable Right={',GetResolverResultDbg(AssignContext.RightResolved),'} AssignContext.RightResolved.IdentEl=',GetObjName(AssignContext.RightResolved.IdentEl));
          {$ENDIF}
          AssignContext.RightSide:=CreateCloneStaticArray(El.right,
                    TPasArrayType(RightTypeEl),AssignContext.RightSide,AContext);
          end;
        end
      else if RightTypeEl.ClassType=TPasRecordType then
        begin
        // right side is a record -> clone
        {$IFDEF VerbosePas2JS}
        writeln('TPasToJSConverter.ConvertAssignStatement RECORD variable Right={',GetResolverResultDbg(AssignContext.RightResolved),'} AssignContext.RightResolved.IdentEl=',GetObjName(AssignContext.RightResolved.IdentEl));
        {$ENDIF}
        AssignContext.RightSide:=CreateCloneRecord(El.right,
                  TPasRecordType(RightTypeEl),AssignContext.RightSide,AContext);
        end;
      end;
    LHS:=ConvertElement(El.left,AssignContext);
    if AssignContext.Call<>nil then
      begin
      // left side is a Setter -> RightSide was already inserted as parameter
      if AssignContext.RightSide<>nil then
        RaiseInconsistency(20170207215544,El.left);
      Result:=LHS;
      end
    else
      begin
      // left side is a variable -> create normal assign statement
      case El.Kind of
        akDefault: T:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,El));
        akAdd: T:=TJSAddEqAssignStatement(CreateElement(TJSAddEqAssignStatement,El));
        akMinus: T:=TJSSubEqAssignStatement(CreateElement(TJSSubEqAssignStatement,El));
        akMul: T:=TJSMulEqAssignStatement(CreateElement(TJSMulEqAssignStatement,El));
        akDivision: T:=TJSDivEqAssignStatement(CreateElement(TJSDivEqAssignStatement,El));
        else RaiseNotSupported(El,AContext,20161107221807);
      end;
      T.Expr:=AssignContext.RightSide;
      AssignContext.RightSide:=nil;
      T.LHS:=LHS;
      Result:=T;

      if (bsRangeChecks in AContext.ScannerBoolSwitches)
          and not (T.Expr is TJSLiteral) then
        begin
        if AssignContext.LeftResolved.BaseType in btAllJSInteger then
          begin
          if AContext.Resolver.ResolveAliasType(AssignContext.LeftResolved.TypeEl) is TPasUnresolvedSymbolRef then
            begin
            if not AContext.Resolver.GetIntegerRange(AssignContext.LeftResolved.BaseType,MinVal,MaxVal) then
              RaiseNotSupported(El.left,AContext,20180119154120);
            Call:=CreateCallExpression(El);
            Call.Expr:=CreatePrimitiveDotExpr(FBuiltInNames[pbivnRTL]+'.'+FBuiltInNames[pbifnRangeCheckInt],El);
            if El.Kind=akDefault then
              begin
              // LHS:=rtl.rc(RHS,min,max)    check before assign
              Call.AddArg(T.Expr);
              T.Expr:=Call;
              end
            else
              begin
              // rtl.rc(LHS+=RHS,min,max)    check after assign
              Call.AddArg(Result);
              Result:=Call;
              end;
            Call.AddArg(CreateLiteralNumber(El.right,MinVal));
            Call.AddArg(CreateLiteralNumber(El.right,MaxVal));
            end;
          end;
        end;
      end;
  finally
    if Result=nil then
      LHS.Free;
    AssignContext.RightSide.Free;
    AssignContext.Free;
  end;
end;

function TPasToJSConverter.ConvertIfStatement(El: TPasImplIfElse;
  AContext: TConvertContext): TJSElement;

Var
  C,BThen,BElse : TJSElement;
  T : TJSIfStatement;
  ok: Boolean;

begin
  if AContext=nil then ;
  C:=Nil;
  BThen:=Nil;
  BElse:=Nil;
  ok:=false;
  try
    C:=ConvertElement(El.ConditionExpr,AContext);
    if Assigned(El.IfBranch) then
      BThen:=ConvertElement(El.IfBranch,AContext);
    if Assigned(El.ElseBranch) then
      BElse:=ConvertElement(El.ElseBranch,AContext);
    ok:=true;
  finally
    if not ok then
      begin
      FreeAndNil(C);
      FreeAndNil(BThen);
      FreeAndNil(BElse);
      end;
  end;
  T:=TJSIfStatement(CreateElement(TJSIfStatement,El));
  T.Cond:=C;
  T.BTrue:=BThen;
  T.BFalse:=BElse;
  Result:=T;
end;

function TPasToJSConverter.ConvertWhileStatement(El: TPasImplWhileDo;
  AContext: TConvertContext): TJSElement;

Var
  C : TJSElement;
  B : TJSElement;
  W : TJSWhileStatement;
  ok: Boolean;
begin
  Result:=Nil;
  C:=Nil;
  B:=Nil;
  ok:=false;
  try
    C:=ConvertElement(EL.ConditionExpr,AContext);
    if Assigned(EL.Body) then
      B:=ConvertElement(EL.Body,AContext)
    else
      B:=TJSEmptyBlockStatement(CreateElement(TJSEmptyBlockStatement,El));
    ok:=true;
  finally
    if not ok then
      begin
      FreeAndNil(B);
      FreeAndNil(C);
      end;
  end;
  W:=TJSWhileStatement(CreateElement(TJSWhileStatement,El));
  W.Cond:=C;
  W.Body:=B;
  Result:=W;
end;

function TPasToJSConverter.ConvertRepeatStatement(El: TPasImplRepeatUntil;
  AContext: TConvertContext): TJSElement;
Var
  C : TJSElement;
  N : TJSUnaryNotExpression;
  W : TJSDoWhileStatement;
  B : TJSElement;
  ok: Boolean;

begin
  Result:=Nil;
  C:=Nil;
  B:=Nil;
  ok:=false;
  try
    C:=ConvertElement(EL.ConditionExpr,AContext);
    N:=TJSUnaryNotExpression(CreateElement(TJSUnaryNotExpression,EL.ConditionExpr));
    N.A:=C;
    B:=ConvertImplBlockElements(El,AContext,false);
    ok:=true;
  finally
    if not ok then
      begin
      FreeAndNil(B);
      FreeAndNil(C);
      end;
  end;
  W:=TJSDoWhileStatement(CreateElement(TJSDoWhileStatement,El));
  W.Cond:=N;
  W.Body:=B;
  Result:=W;
end;

function TPasToJSConverter.ConvertForStatement(El: TPasImplForLoop;
  AContext: TConvertContext): TJSElement;
// Creates the following code:
//  for (var $loop1 = <startexpr>, $loopend = <endexpr>; $loop<=$loopend; $loop++){
//    VariableName = $loop;
//    ...Body...
//  }
//
// For compatibility:
//  LoopVar can be a varname or programname.varname
//  The StartExpr must be executed exactly once at beginning.
//  The EndExpr must be executed exactly once at beginning.
//  If the loop is not executed the Variable is not set, aka keeps its old value.
//  After the loop the variable has the last value.
type
  TInKind = (
    ikNone,
    ikEnum,
    ikBool,
    ikChar,
    ikString,
    ikArray,
    ikSetInt,
    ikSetBool,
    ikSetChar
  );

  function ConvExpr(Expr: TPasExpr): TJSElement; overload;
  var
    ResolvedEl: TPasResolverResult;
    JSUnaryPlus: TJSUnaryPlusExpression;
  begin
    Result:=ConvertElement(Expr,AContext);
    if Result is TJSLiteral then
      case TJSLiteral(Result).Value.ValueType of
      jstBoolean:
        // convert bool literal to int
        TJSLiteral(Result).Value.AsNumber:=ord(TJSLiteral(Result).Value.AsBoolean);
      jstNumber:
        exit;
      jstString:
        begin
        // convert char literal to int
        ConvertCharLiteralToInt(TJSLiteral(Result),Expr,AContext);
        exit;
        end;
      else
        Result.Free;
        RaiseNotSupported(Expr,AContext,20171112021222);
      end
    else if AContext.Resolver<>nil then
      begin
      AContext.Resolver.ComputeElement(Expr,ResolvedEl,[]);
      if (ResolvedEl.BaseType in btAllChars)
          or ((ResolvedEl.BaseType=btRange) and (ResolvedEl.SubType in btAllChars)) then
        begin
        // convert char variable to int: append  .charCodeAt()
        Result:=CreateCallCharCodeAt(Result,0,Expr);
        end
      else if (ResolvedEl.BaseType in btAllBooleans)
          or ((ResolvedEl.BaseType=btRange) and (ResolvedEl.SubType in btAllBooleans)) then
        begin
        // convert bool variable to int: +expr
        JSUnaryPlus:=TJSUnaryPlusExpression(CreateElement(TJSUnaryPlusExpression,Expr));
        JSUnaryPlus.A:=Result;
        Result:=JSUnaryPlus;
        end;
      end;
  end;

  function GetOrd(Value: TResEvalValue; ErrorEl: TPasElement): MaxPrecInt; overload;
  var
    OrdValue: TResEvalValue;
  begin
    if Value=nil then
      exit(0);
    OrdValue:=AContext.Resolver.ExprEvaluator.OrdValue(Value,ErrorEl);
    case OrdValue.Kind of
    revkInt: Result:=TResEvalInt(OrdValue).Int;
    else
      RaiseNotSupported(ErrorEl,AContext,20171112133917);
    end;
    if Value<>OrdValue then
      ReleaseEvalValue(OrdValue);
  end;

  function GetEnumValue(EnumType: TPasEnumType; Int: MaxPrecInt): TResEvalValue; overload;
  begin
    if (coEnumNumbers in Options) or (Int<0) or (Int>=EnumType.Values.Count) then
      Result:=TResEvalInt.CreateValue(Int)
    else
      Result:=TResEvalEnum.CreateValue(Int,TObject(EnumType.Values[Int]) as TPasEnumValue);
  end;

var
  FuncContext: TConvertContext;
  ResolvedVar, ResolvedIn: TPasResolverResult;
  StartValue, EndValue, InValue: TResEvalValue;
  StartInt, EndInt: MaxPrecInt;
  HasLoopVar, HasEndVar, HasInVar: Boolean;
  InKind: TInKind;
  ForScope: TPasForLoopScope;

  function InitWithResolver: boolean;
  var
    EnumType: TPasEnumType;
    TypeEl: TPasType;
  begin
    Result:=true;
    AContext.Resolver.ComputeElement(El.VariableName,ResolvedVar,[rcNoImplicitProc]);
    if not (ResolvedVar.IdentEl is TPasVariable) then
      DoError(20170213214404,nXExpectedButYFound,sXExpectedButYFound,['var',
        AContext.Resolver.GetResolverResultDescription(ResolvedVar)],El.VariableName);

    case El.LoopType of
    ltNormal,ltDown:
      begin
      StartValue:=AContext.Resolver.Eval(El.StartExpr,[],false);
      StartInt:=GetOrd(StartValue,El.StartExpr);
      EndValue:=AContext.Resolver.Eval(El.EndExpr,[],false);
      EndInt:=GetOrd(EndValue,El.EndExpr);
      end;
    ltIn:
      begin
      if ForScope.GetEnumerator<>nil then
        begin
        ConvertForStatement:=CreateGetEnumeratorLoop(El,AContext);
        exit(false);
        end;

      AContext.Resolver.ComputeElement(El.StartExpr,ResolvedIn,[]);
      HasInVar:=true;
      InValue:=AContext.Resolver.Eval(El.StartExpr,[],false);
      if InValue=nil then
        begin
        if ResolvedIn.IdentEl is TPasType then
          begin
          TypeEl:=AContext.Resolver.ResolveAliasType(TPasType(ResolvedIn.IdentEl));
          if TypeEl is TPasArrayType then
            begin
            if length(TPasArrayType(TypeEl).Ranges)=1 then
              InValue:=AContext.Resolver.Eval(TPasArrayType(TypeEl).Ranges[0],[refConst]);
            end
          else if TypeEl is TPasSetType then
            InValue:=AContext.Resolver.EvalTypeRange(TPasSetType(TypeEl).EnumType,[refConst]);
          end;
        end;
      if InValue<>nil then
        begin
        // for in <constant> do
        case InValue.Kind of
        revkString,revkUnicodeString:
          begin
          // example:
          //  for c in 'foo' do ;
          // -> for (var $l1 = 0, $li2 = 'foo'; $l1<=2; $l1++) c = $li2.charAt($l1);
          InKind:=ikString;
          StartInt:=0;
          if InValue.Kind=revkString then
            EndInt:=length(UTF8Decode(TResEvalString(InValue).S))-1
          else
            EndInt:=length(TResEvalUTF16(InValue).S)-1;
          ReleaseEvalValue(InValue);
          end;
        revkRangeInt,revkSetOfInt:
          begin
          if InValue.Kind=revkSetOfInt then
            begin
            if length(TResEvalSet(InValue).Ranges)=0 then
              exit(false);
            if length(TResEvalSet(InValue).Ranges)>1 then
              begin
              // set, non continuous range
              case TResEvalSet(InValue).ElKind of
              revskEnum,revskInt: InKind:=ikSetInt;
              revskChar: InKind:=ikSetChar;
              revskBool: InKind:=ikSetBool;
              end;
              HasInVar:=false;
              HasLoopVar:=InKind<>ikSetInt;
              HasEndVar:=false;
              exit;
              end;
            end;
          StartInt:=TResEvalRangeInt(InValue).RangeStart;
          EndInt:=TResEvalRangeInt(InValue).RangeEnd;
          HasInVar:=false;
          HasEndVar:=false;
          case TResEvalRangeInt(InValue).ElKind of
          revskEnum:
            if coEnumNumbers in Options then
              InKind:=ikNone
            else
              begin
              InKind:=ikEnum;
              EnumType:=TPasEnumType(TResEvalRangeInt(InValue).ElType);
              StartValue:=GetEnumValue(EnumType,StartInt);
              EndValue:=GetEnumValue(EnumType,EndInt);
              end;
          revskInt:
            InKind:=ikNone;
          revskChar:
            InKind:=ikChar;
          revskBool:
            InKind:=ikBool;
          else
            {$IFDEF VerbosePas2JS}
            writeln('TPasToJSConverter.ConvertForStatement ',GetObjName(El.StartExpr),' InValue=',InValue.AsDebugString);
            {$ENDIF}
            RaiseNotSupported(El.StartExpr,AContext,20171113023419);
          end;
          end
        else
          {$IFDEF VerbosePas2JS}
          writeln('TPasToJSConverter.ConvertForStatement ',GetObjName(El.StartExpr),' InValue=',InValue.AsDebugString);
          {$ENDIF}
          RaiseNotSupported(El.StartExpr,AContext,20171112161527);
        end;
        end
      else if rrfReadable in ResolvedIn.Flags then
        begin
        // for v in <variable> do
        if ResolvedIn.BaseType in btAllStrings then
          begin
          InKind:=ikString;
          StartInt:=0;
          end
        else if ResolvedIn.BaseType=btContext then
          begin
          TypeEl:=AContext.Resolver.ResolveAliasType(ResolvedIn.TypeEl);
          if TypeEl is TPasArrayType then
            begin
            if length(TPasArrayType(TypeEl).Ranges)<=1 then
              begin
              InKind:=ikArray;
              StartInt:=0;
              end
            else
              begin
              {$IFDEF VerbosePas2JS}
              writeln('TPasToJSConverter.ConvertForStatement.InitWithResolver ResolvedIn=',GetResolverResultDbg(ResolvedIn),' length(Ranges)=',length(TPasArrayType(TypeEl).Ranges));
              {$ENDIF}
              RaiseNotSupported(El.StartExpr,AContext,20171220010147);
              end;
            end
          else
            begin
            {$IFDEF VerbosePas2JS}
            writeln('TPasToJSConverter.ConvertForStatement.InitWithResolver El.StartExpr=',GetObjName(El.StartExpr),' ResolvedIn=',GetResolverResultDbg(ResolvedIn));
            {$ENDIF}
            RaiseNotSupported(El.StartExpr,AContext,20171113012226);
            end;
          end
        else if ResolvedIn.BaseType=btSet then
          begin
          if ResolvedIn.SubType in btAllBooleans then
            InKind:=ikSetBool
          else if ResolvedIn.SubType in btAllChars then
            InKind:=ikSetChar
          else
            InKind:=ikSetInt;
          HasInVar:=false;
          HasLoopVar:=InKind<>ikSetInt;
          HasEndVar:=false;
          exit;
          end
        else
          begin
          {$IFDEF VerbosePas2JS}
          writeln('TPasToJSConverter.ConvertForStatement.InitWithResolver ResolvedIn=',GetResolverResultDbg(ResolvedIn));
          {$ENDIF}
          RaiseNotSupported(El.StartExpr,AContext,20171220221747);
          end;
        end
      else
        begin
        {$IFDEF VerbosePas2JS}
        writeln('TPasToJSConverter.ConvertForStatement.InitWithResolver ResolvedIn=',GetResolverResultDbg(ResolvedIn));
        {$ENDIF}
        RaiseNotSupported(El.StartExpr,AContext,20171112195629);
        end;
      end;
    end;

    if EndValue<>nil then
      begin
      HasEndVar:=false;
      if (StartValue<>nil) then
        begin
        if StartInt<=EndInt then
          begin
          // loop is always executed
          if StartValue.Kind in [revkInt,revkUInt,revkEnum] then
            HasLoopVar:=false; // variable can be used as runner
          end
        else
          begin
          // loop is never executed
          if coEliminateDeadCode in Options then exit;
          end;
        end;
      end;
  end;

  function CreateStrictNotEqual0(Left: TJSElement; PosEl: TPasElement): TJSElement;
  var
    SNE: TJSEqualityExpressionSNE;
  begin
    SNE:=TJSEqualityExpressionSNE(CreateElement(TJSEqualityExpressionSNE,PosEl));
    SNE.A:=Left;
    SNE.B:=CreateLiteralNumber(PosEl,0);
    Result:=SNE;
  end;

Var
  ForSt : TJSBodyStatement;
  List: TJSStatementList;
  SimpleAss : TJSSimpleAssignStatement;
  Incr: TJSUNaryExpression;
  BinExp : TJSBinaryExpression;
  VarStat: TJSVariableStatement;
  CurLoopVarName, CurEndVarName, CurInVarName: String;
  PosEl: TPasElement;
  Statements, V: TJSElement;
  Call: TJSCallExpression;
  Br: TJSBracketMemberExpression;
begin
  Result:=Nil;
  if AContext.Access<>caRead then
    RaiseInconsistency(20170213213740,El);
  ForScope:=El.CustomData as TPasForLoopScope; // can be nil!
  case El.LoopType of
  ltNormal,ltDown: ;
  ltIn:
    if AContext.Resolver=nil then
      RaiseNotSupported(El,AContext,20171112160707);
  else
    {$IFDEF VerbosePas2JS}
    writeln('TPasToJSConverter.ConvertForStatement LoopType=',El.LoopType);
    {$ENDIF}
    RaiseNotSupported(El,AContext,20171110141937);
  end;

  // get function context
  FuncContext:=AContext;
  while (FuncContext.Parent<>nil) and (not (FuncContext is TFunctionContext)) do
    FuncContext:=FuncContext.Parent;

  StartValue:=nil;
  StartInt:=0;
  EndValue:=nil;
  EndInt:=0;
  InValue:=nil;
  InKind:=ikNone;
  Statements:=nil;
  try
    HasLoopVar:=true;
    HasEndVar:=true;
    HasInVar:=false;
    if AContext.Resolver<>nil then
      begin
      if not InitWithResolver then exit;
      end;
    // create unique var names $l, $end, $in
    if HasInVar then
      CurInVarName:=FuncContext.CreateLocalIdentifier(FBuiltInNames[pbivnLoopIn])
    else
      CurInVarName:='';
    if HasLoopVar then
      CurLoopVarName:=FuncContext.CreateLocalIdentifier(FBuiltInNames[pbivnLoop])
    else
      CurLoopVarName:='';
    if HasEndVar then
      CurEndVarName:=FuncContext.CreateLocalIdentifier(FBuiltInNames[pbivnLoopEnd])
    else
      CurEndVarName:='';

    // add "for()"
    if InKind in [ikSetInt,ikSetBool,ikSetChar] then
      ForSt:=TJSForInStatement(CreateElement(TJSForInStatement,El))
    else
      ForSt:=TJSForStatement(CreateElement(TJSForStatement,El));
    Statements:=ForSt;
    PosEl:=El;

    // add in front of for():  variable=<startexpr>
    if (not HasLoopVar) and (HasEndVar or HasInVar) then
      begin
      // for example:
      //   i:=<startexpr>;
      //   for (var $end = <endexpr>; $i<$end; $i++)...
      List:=TJSStatementList(CreateElement(TJSStatementList,El));
      SimpleAss:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,El.VariableName));
      List.A:=SimpleAss;
      List.B:=Statements;
      Statements:=List;
      SimpleAss.LHS:=ConvertElement(El.VariableName,AContext);
      if StartValue<>nil then
        SimpleAss.Expr:=CreateLiteralNumber(El.StartExpr,StartInt)
      else
        SimpleAss.Expr:=ConvertElement(El.StartExpr,AContext);
      PosEl:=El.StartExpr;
      end;

    if ForSt.ClassType=TJSForInStatement then
      begin
      if HasLoopVar then
        begin
        // add for("var $l" in <startexpr>)
        VarStat:=TJSVariableStatement(CreateElement(TJSVariableStatement,PosEl));
        VarStat.A:=CreatePrimitiveDotExpr(CurLoopVarName,PosEl);
        TJSForInStatement(ForSt).LHS:=VarStat;
        end
      else
        // add for("<varname>" in <startexpr>)
        TJSForInStatement(ForSt).LHS:=ConvertElement(El.VariableName,AContext);
      // add for(<varname> in "<startexpr>")
      TJSForInStatement(ForSt).List:=ConvertElement(El.StartExpr,AContext);
      end
    else if HasLoopVar or HasEndVar or HasInVar then
      begin
      // add "for(var ..."
      VarStat:=TJSVariableStatement(CreateElement(TJSVariableStatement,El));
      TJSForStatement(ForSt).Init:=VarStat;
      if HasInVar then
        begin
        // add "$in=<InExpr>"
        PosEl:=El.StartExpr;
        if (InValue<>nil) and (InValue.Kind<>revkSetOfInt) then
          V:=ConvertConstValue(InValue,AContext,PosEl)
        else
          V:=ConvertElement(El.StartExpr,AContext);
        V:=CreateVarDecl(CurInVarName,V,PosEl);
        AddToVarStatement(VarStat,V,PosEl);
        end;
      if HasLoopVar then
        begin
        // add "$l=<StartExpr>"
        PosEl:=El.StartExpr;
        if StartValue<>nil then
          V:=CreateLiteralNumber(PosEl,StartInt)
        else if El.LoopType=ltIn then
          V:=CreateLiteralNumber(PosEl,StartInt)
        else
          V:=ConvExpr(El.StartExpr);
        V:=CreateVarDecl(CurLoopVarName,V,PosEl);
        AddToVarStatement(VarStat,V,PosEl);
        end;
      if HasEndVar then
        begin
        // add "$end=<EndExpr>"
        PosEl:=El.EndExpr;
        if PosEl=nil then
          PosEl:=El.StartExpr;
        if EndValue<>nil then
          V:=CreateLiteralNumber(PosEl,EndInt)
        else if El.LoopType=ltIn then
          case InKind of
          ikEnum,ikBool,ikChar:
            V:=CreateLiteralNumber(PosEl,EndInt);
          ikString:
            begin
            // add "$in.length-1"
            V:=TJSAdditiveExpressionMinus(CreateElement(TJSAdditiveExpressionMinus,PosEl));
            TJSAdditiveExpressionMinus(V).A:=CreatePrimitiveDotExpr(CurInVarName+'.length',PosEl);
            TJSAdditiveExpressionMinus(V).B:=CreateLiteralNumber(PosEl,1);
            end;
          ikArray:
            begin
            // add "rtl.length($in)-1"
            Call:=CreateCallExpression(PosEl);
            Call.Expr:=CreatePrimitiveDotExpr(FBuiltInNames[pbivnRTL]+'.'+FBuiltInNames[pbifnArray_Length],PosEl);
            Call.AddArg(CreatePrimitiveDotExpr(CurInVarName,PosEl));
            V:=TJSAdditiveExpressionMinus(CreateElement(TJSAdditiveExpressionMinus,PosEl));
            TJSAdditiveExpressionMinus(V).A:=Call;
            TJSAdditiveExpressionMinus(V).B:=CreateLiteralNumber(PosEl,1);
            end
          else
            RaiseNotSupported(El.StartExpr,AContext,20171113015445);
          end
        else
          V:=ConvExpr(El.EndExpr);
        V:=CreateVarDecl(CurEndVarName,V,PosEl);
        AddToVarStatement(VarStat,V,PosEl);
        end;
      end
    else
      begin
      // No new vars. For example:
      //   for (VariableName = <startexpr>; VariableName <= <EndExpr>; VariableName++)
      SimpleAss:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,El.VariableName));
      TJSForStatement(ForSt).Init:=SimpleAss;
      SimpleAss.LHS:=ConvertElement(El.VariableName,AContext);
      if StartValue<>nil then
        SimpleAss.Expr:=CreateLiteralNumber(El.StartExpr,StartInt)
      else
        SimpleAss.Expr:=ConvertElement(El.StartExpr,AContext);
      PosEl:=El.StartExpr;
      end;

    if ForSt.ClassType=TJSForStatement then
      begin
      // add "$l<=$end"
      if (El.EndExpr<>nil) then
        PosEl:=El.EndExpr;
      if El.Down then
        BinExp:=TJSRelationalExpressionGE(CreateElement(TJSRelationalExpressionGE,PosEl))
      else
        BinExp:=TJSRelationalExpressionLE(CreateElement(TJSRelationalExpressionLE,PosEl));
      TJSForStatement(ForSt).Cond:=BinExp;
      if HasLoopVar then
        BinExp.A:=CreatePrimitiveDotExpr(CurLoopVarName,PosEl)
      else
        BinExp.A:=ConvertElement(El.VariableName,AContext);
      if HasEndVar then
        BinExp.B:=CreatePrimitiveDotExpr(CurEndVarName,PosEl)
      else
        BinExp.B:=CreateLiteralNumber(PosEl,EndInt);

      // add "$l++"
      if El.Down then
        Incr:=TJSUnaryPostMinusMinusExpression(CreateElement(TJSUnaryPostMinusMinusExpression,PosEl))
      else
        Incr:=TJSUnaryPostPlusPlusExpression(CreateElement(TJSUnaryPostPlusPlusExpression,PosEl));
      TJSForStatement(ForSt).Incr:=Incr;
      if HasLoopVar then
        Incr.A:=CreatePrimitiveDotExpr(CurLoopVarName,PosEl)
      else
        Incr.A:=ConvertElement(El.VariableName,AContext);
      end;

    // add  "VariableName:=$l;"
    if HasLoopVar then
      begin
      PosEl:=El.Body;
      if PosEl=nil then
        PosEl:=El;
      PosEl:=El.VariableName;
      SimpleAss:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,PosEl));
      ForSt.Body:=SimpleAss;
      SimpleAss.LHS:=ConvertElement(El.VariableName,AContext);
      SimpleAss.Expr:=CreatePrimitiveDotExpr(CurLoopVarName,PosEl);
      if AContext.Resolver<>nil then
        begin
        if InKind<>ikNone then
          case InKind of
          ikEnum,ikSetInt: ;
          ikBool,ikSetBool:
            // $in!==0;
            SimpleAss.Expr:=CreateStrictNotEqual0(SimpleAss.Expr,PosEl);
          ikChar,ikSetChar:
            // String.fromCharCode($l)
            SimpleAss.Expr:=CreateCallFromCharCode(SimpleAss.Expr,PosEl);
          ikString:
            begin
            // $in.charAt($l)
            Call:=CreateCallExpression(PosEl);
            Call.Expr:=CreateDotExpression(PosEl,
              CreatePrimitiveDotExpr(CurInVarName,El.StartExpr),
              CreatePrimitiveDotExpr('charAt',PosEl));
            Call.AddArg(SimpleAss.Expr);
            SimpleAss.Expr:=Call;
            end;
          ikArray:
            begin
            // $in[$l]
            Br:=TJSBracketMemberExpression(CreateElement(TJSBracketMemberExpression,PosEl));
            Br.MExpr:=CreatePrimitiveDotExpr(CurInVarName,El.StartExpr);
            Br.Name:=SimpleAss.Expr;
            SimpleAss.Expr:=Br;
            end;
          else
            {$IFDEF VerbosePas2JS}
            writeln('TPasToJSConverter.ConvertForStatement InKind=',InKind);
            {$ENDIF}
            RaiseNotSupported(El.StartExpr,AContext,20171113002550);
          end
        else if (ResolvedVar.BaseType in btAllChars)
            or ((ResolvedVar.BaseType=btRange) and (ResolvedVar.SubType in btAllChars)) then
          begin
          // convert int to char
          SimpleAss.Expr:=CreateCallFromCharCode(SimpleAss.Expr,PosEl);
          end
        else if (ResolvedVar.BaseType in btAllBooleans)
            or ((ResolvedVar.BaseType=btRange) and (ResolvedVar.SubType in btAllBooleans)) then
          begin
          // convert int to bool  ->  $l!=0
          SimpleAss.Expr:=CreateStrictNotEqual0(SimpleAss.Expr,PosEl);
          end
        end;
      end;

    // add body
    if El.Body<>nil then
      begin
      V:=ConvertElement(El.Body,AContext);
      if ForSt.Body=nil then
        ForSt.Body:=V
      else
        begin
        List:=TJSStatementList(CreateElement(TJSStatementList,El.Body));
        List.A:=ForSt.Body;
        List.B:=V;
        ForSt.Body:=List;
        end;
      end;
    Result:=Statements;
  finally
    ReleaseEvalValue(StartValue);
    ReleaseEvalValue(EndValue);
    ReleaseEvalValue(InValue);
    if Result=nil then
      Statements.Free;
  end;
end;

function TPasToJSConverter.ConvertSimpleStatement(El: TPasImplSimple;
  AContext: TConvertContext): TJSElement;

Var
  E : TJSElement;
  C: TClass;

begin
  E:=ConvertElement(EL.Expr,AContext);
  if E=nil then
    exit(nil); // e.g. "inherited;" without ancestor proc
  C:=E.ClassType;
  if (C=TJSExpressionStatement)
      or (C=TJSStatementList) then
    Result:=E
  else
    begin
    Result:=TJSExpressionStatement(CreateElement(TJSExpressionStatement,El));
    TJSExpressionStatement(Result).A:=E;
    end;
end;

function TPasToJSConverter.ConvertWithStatement(El: TPasImplWithDo;
  AContext: TConvertContext): TJSElement;
Var
  B,E , Expr: TJSElement;
  W,W2 : TJSWithStatement;
  I : Integer;
  ok: Boolean;
  PasExpr: TPasElement;
  V: TJSVariableStatement;
  FuncContext: TFunctionContext;
  FirstSt, LastSt: TJSStatementList;
  WithScope: TPasWithScope;
  WithExprScope: TPas2JSWithExprScope;

begin
  Result:=nil;
  if AContext.Resolver<>nil then
    begin
    // with Resolver:
    // Insert for each expression a local var. Example:
    //   with aPoint do X:=3;
    // convert to
    //   var $with1 = aPoint;
    //   $with1.X = 3;
    FuncContext:=TFunctionContext(AContext.GetContextOfType(TFunctionContext));
    if FuncContext=nil then
      RaiseInconsistency(20170212003759,El);
    FirstSt:=nil;
    LastSt:=nil;
    try
      WithScope:=El.CustomData as TPasWithScope;
      for i:=0 to El.Expressions.Count-1 do
        begin
        PasExpr:=TPasElement(El.Expressions[i]);
        Expr:=ConvertElement(PasExpr,AContext);

        WithExprScope:=WithScope.ExpressionScopes[i] as TPas2JSWithExprScope;
        if (Expr is TJSPrimaryExpressionIdent)
            and IsValidJSIdentifier(TJSPrimaryExpressionIdent(Expr).Name) then
          begin
          // expression is already a local variable
          WithExprScope.WithVarName:=String(TJSPrimaryExpressionIdent(Expr).Name);
          Expr.Free;
          end
        else if Expr is TJSPrimaryExpressionThis then
          begin
          // expression is 'this'
          WithExprScope.WithVarName:='this';
          Expr.Free;
          end
        else
          begin
          // create unique local var name
          WithExprScope.WithVarName:=FuncContext.CreateLocalIdentifier(FBuiltInNames[pbivnWith]);
          // create local "var $with1 = expr;"
          V:=CreateVarStatement(WithExprScope.WithVarName,Expr,PasExpr);
          AddToStatementList(FirstSt,LastSt,V,PasExpr);
          end;
        end;
      if Assigned(El.Body) then
        begin
        B:=ConvertElement(El.Body,AContext);
        AddToStatementList(FirstSt,LastSt,B,El.Body);
        end;
      Result:=FirstSt;
    finally
      if Result=nil then
        FreeAndNil(FirstSt);
    end;
    end
  else
    begin
    // without Resolver use as fallback the JavaScript with(){}
    W:=Nil;
    if Assigned(El.Body) then
      B:=ConvertElement(El.Body,AContext)
    else
      B:=TJSEmptyBlockStatement(CreateElement(TJSEmptyBlockStatement,El));
    ok:=false;
    try
      For I:=0 to El.Expressions.Count-1 do
        begin
        E:=ConvertElement(TPasElement(El.Expressions[i]),AContext);
        W2:=TJSWithStatement(CreateElement(TJSWithStatement,TPasElement(El.Expressions[i])));
        if Not Assigned(Result) then // result is the first
          Result:=W2;
        if Assigned(W) then // Chain
          W.B:=W2;
        W:=W2; // W is the last
        W.A:=E;
        end;
      ok:=true;
    finally
      if not ok then
        begin
        FreeAndNil(E);
        FreeAndNil(Result);
        end;
    end;
    W.B:=B;
    end;
end;

function TPasToJSConverter.IsElementUsed(El: TPasElement): boolean;
begin
  if Assigned(OnIsElementUsed) then
    Result:=OnIsElementUsed(Self,El)
  else
    Result:=true;
end;

function TPasToJSConverter.IsSystemUnit(aModule: TPasModule): boolean;
begin
  Result:=CompareText(aModule.Name,'system')=0;
end;

function TPasToJSConverter.HasTypeInfo(El: TPasType; AContext: TConvertContext
  ): boolean;
begin
  Result:=false;
  if coNoTypeInfo in Options then exit;
  if AContext.Resolver=nil then exit;
  if not AContext.Resolver.HasTypeInfo(El) then exit;
  if Assigned(OnIsTypeInfoUsed) and not OnIsTypeInfoUsed(Self,El) then exit;
  Result:=true;
end;

function TPasToJSConverter.IsClassRTTICreatedBefore(aClass: TPasClassType;
  Before: TPasElement; AConText: TConvertContext): boolean;
var
  Decls: TPasDeclarations;
  i: Integer;
  Types: TFPList;
  T: TPasType;
  C: TClass;
begin
  Result:=false;
  if aClass.Parent=nil then exit;
  if not aClass.Parent.InheritsFrom(TPasDeclarations) then
    RaiseInconsistency(20170412101457,aClass);
  Decls:=TPasDeclarations(aClass.Parent);
  Types:=Decls.Types;
  for i:=0 to Types.Count-1 do
    begin
    T:=TPasType(Types[i]);
    if T=Before then exit;
    if T=aClass then exit(true);
    C:=T.ClassType;
    if C=TPasClassType then
      begin
      if TPasClassType(T).IsForward and (T.CustomData is TResolvedReference)
          and (TResolvedReference(T.CustomData).Declaration=aClass) then
        exit(true);
      end
    else if C=TPasClassOfType then
      begin
      if AConText.Resolver.ResolveAliasType(TPasClassOfType(T).DestType)=aClass then
        exit(true);
      end;
    end;
end;

function TPasToJSConverter.CreateUnary(Members: array of string; E: TJSElement): TJSUnary;
var
  unary: TJSUnary;
  asi: TJSSimpleAssignStatement;
begin
  unary := TJSUnary.Create(0, 0, '');
  asi := TJSSimpleAssignStatement.Create(0, 0, '');
  unary.A := asi;
  asi.Expr := E;
  asi.LHS := CreateMemberExpression(Members);
  Result := unary;
end;

function TPasToJSConverter.CreateMemberExpression(Members: array of string): TJSDotMemberExpression;
var
  pex: TJSPrimaryExpressionIdent;
  MExpr: TJSDotMemberExpression;
  LastMExpr: TJSDotMemberExpression;
  k: integer;
begin
  if Length(Members) < 2 then
    DoError(20161024192715,'internal error: member expression with less than two members');
  LastMExpr := nil;
  for k:=High(Members) downto Low(Members)+1 do
  begin
    MExpr := TJSDotMemberExpression.Create(0, 0, '');
    MExpr.Name := TJSString(Members[k]);
    if LastMExpr=nil then
      Result := MExpr
    else
      LastMExpr.MExpr := MExpr;
    LastMExpr := MExpr;
  end;
  pex := TJSPrimaryExpressionIdent.Create(0, 0, '');
  pex.Name := TJSString(Members[Low(Members)]);
  LastMExpr.MExpr := pex;
end;

function TPasToJSConverter.CreateCallExpression(El: TPasElement
  ): TJSCallExpression;
begin
  Result:=TJSCallExpression(CreateElement(TJSCallExpression,El));
  Result.Args:=TJSArguments(CreateElement(TJSArguments,El));
end;

function TPasToJSConverter.CreateCallCharCodeAt(Arg: TJSElement;
  aNumber: integer; El: TPasElement): TJSCallExpression;
begin
  Result:=CreateCallExpression(El);
  Result.Expr:=CreateDotExpression(El,Arg,CreatePrimitiveDotExpr('charCodeAt',El));
  if aNumber<>0 then
    Result.Args.AddElement(CreateLiteralNumber(El,aNumber));
end;

function TPasToJSConverter.CreateCallFromCharCode(Arg: TJSElement;
  El: TPasElement): TJSCallExpression;
begin
  Result:=CreateCallExpression(El);
  Result.Expr:=CreateMemberExpression(['String','fromCharCode']);
  Result.AddArg(Arg);
end;

function TPasToJSConverter.CreateUsesList(UsesSection: TPasSection;
  AContext: TConvertContext): TJSArrayLiteral;
var
  ArgArray: TJSArrayLiteral;
  i: Integer;
  anUnitName: String;
  ArgEx: TJSLiteral;
  UsesClause: TPasUsesClause;
  aModule: TPasModule;
begin
  UsesClause:=UsesSection.UsesClause;
  ArgArray:=TJSArrayLiteral.Create(0,0);
  for i:=0 to length(UsesClause)-1 do
    begin
    aModule:=UsesClause[i].Module as TPasModule;
    if (not IsElementUsed(aModule)) and not IsSystemUnit(aModule) then
      continue;
    anUnitName := TransformModuleName(aModule,false,AContext);
    ArgEx := CreateLiteralString(UsesSection,anUnitName);
    ArgArray.Elements.AddElement.Expr := ArgEx;
    end;
  Result:=ArgArray;
end;

procedure TPasToJSConverter.AddToStatementList(var First,
  Last: TJSStatementList; Add: TJSElement; Src: TPasElement);
var
  SL2: TJSStatementList;
begin
  if Add=nil then exit;
  if Add is TJSStatementList then
    begin
    // add list
    if TJSStatementList(Add).A=nil then
      begin
      // empty list -> skip
      if TJSStatementList(Add).B<>nil then
        raise Exception.Create('internal error: AddToStatementList add list A=nil, B<>nil, B='+TJSStatementList(Add).B.ClassName);
      FreeAndNil(Add);
      end
    else if Last=nil then
      begin
      // our list is not yet started -> simply take the extra list
      Last:=TJSStatementList(Add);
      First:=Last;
      end
    else
      begin
      // merge lists (append)
      if Last.B<>nil then
        begin
        // add a nil to the end of chain
        SL2:=TJSStatementList(CreateElement(TJSStatementList,Src));
        SL2.A:=Last.B;
        Last.B:=SL2;
        Last:=SL2;
        // Last.B is now nil
        end;
      Last.B:=Add;
      while Last.B is TJSStatementList do
        Last:=TJSStatementList(Last.B);
      end;
    end
  else
    begin
    if Last=nil then
      begin
      // start list
      Last:=TJSStatementList(CreateElement(TJSStatementList,Src));
      First:=Last;
      Last.A:=Add;
      end
    else if Last.B=nil then
      // second element
      Last.B:=Add
    else
      begin
      // add to chain
      while Last.B is TJSStatementList do
        Last:=TJSStatementList(Last.B);
      SL2:=TJSStatementList(CreateElement(TJSStatementList,Src));
      SL2.A:=Last.B;
      Last.B:=SL2;
      Last:=SL2;
      Last.B:=Add;
      end;
    end;
end;

procedure TPasToJSConverter.AddToVarStatement(VarStat: TJSVariableStatement;
  Add: TJSElement; Src: TPasElement);
var
  List: TJSVariableDeclarationList;
begin
  if VarStat.A=nil then
    VarStat.A:=Add
  else
    begin
    List:=TJSVariableDeclarationList(CreateElement(TJSVariableDeclarationList,Src));
    List.A:=VarStat.A;
    List.B:=Add;
    VarStat.A:=List;
    end;
end;

function TPasToJSConverter.CreateValInit(PasType: TPasType; Expr: TPasExpr;
  El: TPasElement; AContext: TConvertContext): TJSElement;
var
  T: TPasType;
  Lit: TJSLiteral;
  bt: TResolverBaseType;
  JSBaseType: TPas2jsBaseType;
  C: TClass;
  Value: TResEvalValue;
begin
  T:=PasType;
  if AContext.Resolver<>nil then
    T:=AContext.Resolver.ResolveAliasType(T);

  //writeln('START TPasToJSConverter.CreateValInit PasType=',GetObjName(PasType),' El=',GetObjName(El),' T=',GetObjName(T),' Expr=',GetObjName(Expr));
  if T=nil then
    begin
    // untyped var/const
    if Expr=nil then
      begin
      if AContext.Resolver=nil then
        exit(CreateLiteralUndefined(El));
      RaiseInconsistency(20170415185745,El);
      end;
    Result:=ConvertElement(Expr,AContext);
    if Result=nil then
      begin
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.CreateValInit PasType=',GetObjName(PasType),' El=',GetObjName(El),' T=',GetObjName(T),' Expr=',GetObjName(Expr));
      {$ENDIF}
      RaiseNotSupported(Expr,AContext,20170415185927);
      end;
    exit;
    end;

  C:=T.ClassType;
  if C=TPasArrayType then
    Result:=CreateArrayInit(TPasArrayType(T),Expr,El,AContext)
  else if C=TPasRecordType then
    Result:=CreateRecordInit(TPasRecordType(T),Expr,El,AContext)
  else if Assigned(Expr) then
    // if there is an expression then simply convert the it
    Result:=ConvertElement(Expr,AContext)
  else if C=TPasSetType then
    // a "set" without initial value
    Result:=TJSObjectLiteral(CreateElement(TJSObjectLiteral,El))
  else if (C=TPasRangeType) and (AContext.Resolver<>nil) then
    // a custom range without initial value -> use first value
    begin
    Value:=AContext.Resolver.Eval(TPasRangeType(T).RangeExpr.left,[refConst]);
    try
      Result:=ConvertConstValue(Value,AContext,El);
    finally
      ReleaseEvalValue(Value);
    end;
    end
  else
    begin
    // always init with a default value to create a typed variable (faster and more readable)
    Lit:=TJSLiteral(CreateElement(TJSLiteral,El));
    Result:=Lit;
    if (C=TPasPointerType)
        or (C=TPasClassType)
        or (C=TPasClassOfType)
        or (C=TPasProcedureType)
        or (C=TPasFunctionType) then
      Lit.Value.IsNull:=true
    else if C=TPasStringType then
      Lit.Value.AsString:=''
    else if C=TPasEnumType then
      Lit.Value.AsNumber:=0
    else if C=TPasUnresolvedSymbolRef then
      begin
      if T.CustomData is TResElDataBaseType then
        begin
        bt:=TResElDataBaseType(T.CustomData).BaseType;
        if bt in btAllJSInteger then
          Lit.Value.AsNumber:=0
        else if bt in btAllJSFloats then
          Lit.Value.CustomValue:='0.0'
        else if bt in btAllJSStringAndChars then
          Lit.Value.AsString:=''
        else if bt in btAllJSBooleans then
          Lit.Value.AsBoolean:=false
        else if bt in [btNil,btPointer,btProc] then
          Lit.Value.IsNull:=true
        else if (bt=btCustom) and (T.CustomData is TResElDataPas2JSBaseType) then
          begin
          JSBaseType:=TResElDataPas2JSBaseType(T.CustomData).JSBaseType;
          if JSBaseType=pbtJSValue then
            Lit.Value.IsUndefined:=true;
          end
        else
          begin
          {$IFDEF VerbosePas2JS}
          writeln('TPasToJSConverter.CreateVarInit unknown PasType T=',GetObjName(T),' basetype=',AContext.Resolver.BaseTypeNames[bt]);
          {$ENDIF}
          RaiseNotSupported(PasType,AContext,20170208162121);
          end;
        end
      else if AContext.Resolver<>nil then
        begin
        {$IFDEF VerbosePas2JS}
        writeln('TPasToJSConverter.CreateValInit PasType=',GetObjName(PasType),' El=',GetObjName(El),' T=',GetObjName(T),' Expr=',GetObjName(Expr));
        {$ENDIF}
        RaiseNotSupported(El,AContext,20170415190259);
        end
      else if (CompareText(T.Name,'longint')=0)
           or (CompareText(T.Name,'int64')=0)
           or (CompareText(T.Name,'real')=0)
           or (CompareText(T.Name,'double')=0)
           or (CompareText(T.Name,'single')=0) then
        Lit.Value.AsNumber:=0.0
      else if (CompareText(T.Name,'boolean')=0) then
        Lit.Value.AsBoolean:=false
      else if (CompareText(T.Name,'string')=0)
           or (CompareText(T.Name,'char')=0)
      then
        Lit.Value.AsString:=''
      else
        begin
        Lit.Value.IsUndefined:=true;
        {$IFDEF VerbosePas2JS}
        writeln('TPasToJSConverter.CreateVarInit unknown PasType class=',T.ClassName,' name=',T.Name);
        {$ENDIF}
        end;
      end
    else
      begin
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.CreateValInit unknown PasType ',GetObjName(T));
      {$ENDIF}
      RaiseNotSupported(PasType,AContext,20170208161506);
      end;
    end;
  if Result=nil then
    begin
    {$IFDEF VerbosePas2JS}
    writeln('TPasToJSConverter.CreateValInit PasType=',GetObjName(PasType),' El=',GetObjName(El),' T=',GetObjName(T),' Expr=',GetObjName(Expr));
    {$ENDIF}
    RaiseNotSupported(El,AContext,20170415190103);
    end;
end;

function TPasToJSConverter.CreateVarInit(El: TPasVariable;
  AContext: TConvertContext): TJSElement;
begin
  Result:=CreateValInit(El.VarType,El.Expr,El,AContext);
end;

function TPasToJSConverter.CreateVarStatement(const aName: String;
  Init: TJSElement; El: TPasElement): TJSVariableStatement;
// create "var aname = init"
begin
  Result:=TJSVariableStatement(CreateElement(TJSVariableStatement,El));
  Result.A:=CreateVarDecl(aName,Init,El);
end;

function TPasToJSConverter.CreateVarDecl(const aName: String; Init: TJSElement;
  El: TPasElement): TJSVarDeclaration;
begin
  Result:=TJSVarDeclaration(CreateElement(TJSVarDeclaration,El));
  Result.Name:=aName;
  Result.Init:=Init;
end;

function TPasToJSConverter.CreateLiteralNumber(El: TPasElement;
  const n: TJSNumber): TJSLiteral;
begin
  Result:=TJSLiteral(CreateElement(TJSLiteral,El));
  Result.Value.AsNumber:=n;
end;

function TPasToJSConverter.CreateLiteralString(El: TPasElement; const s: string
  ): TJSLiteral;
begin
  Result:=TJSLiteral(CreateElement(TJSLiteral,El));
  Result.Value.AsString:=TJSString(s);
end;

function TPasToJSConverter.CreateLiteralJSString(El: TPasElement;
  const s: TJSString): TJSLiteral;
begin
  Result:=TJSLiteral(CreateElement(TJSLiteral,El));
  Result.Value.AsString:=s;
end;

function TPasToJSConverter.CreateLiteralBoolean(El: TPasElement; b: boolean
  ): TJSLiteral;
begin
  Result:=TJSLiteral(CreateElement(TJSLiteral,El));
  Result.Value.AsBoolean:=b;
end;

function TPasToJSConverter.CreateLiteralNull(El: TPasElement): TJSLiteral;
begin
  Result:=TJSLiteral(CreateElement(TJSLiteral,El));
  Result.Value.IsNull:=true;
end;

function TPasToJSConverter.CreateLiteralUndefined(El: TPasElement): TJSLiteral;
begin
  Result:=TJSLiteral(CreateElement(TJSLiteral,El));
  Result.Value.IsUndefined:=true;
end;

function TPasToJSConverter.CreateSetLiteralElement(Expr: TPasExpr;
  AContext: TConvertContext): TJSElement;
var
  LitVal: TJSValue;
  NewEl: TJSElement;
  WS: TJSString;
  ExprResolved: TPasResolverResult;
  Call: TJSCallExpression;
  DotExpr: TJSDotMemberExpression;
begin
  Result:=ConvertElement(Expr,AContext);
  if Result=nil then
    RaiseNotSupported(Expr,AContext,20170415192209);
  if Result.ClassType=TJSLiteral then
    begin
    // argument is a literal  -> convert to number
    LitVal:=TJSLiteral(Result).Value;
    case LitVal.ValueType of
      jstBoolean:
        begin
        if LitVal.AsBoolean=LowJSBoolean then
          NewEl:=CreateLiteralNumber(Expr,0)
        else
          NewEl:=CreateLiteralNumber(Expr,1);
        Result.Free;
        exit(NewEl);
        end;
      jstNumber:
        exit;
      jstString:
        begin
        WS:=LitVal.AsString;
        Result.Free;
        if length(WS)<>1 then
          DoError(20170415193254,nXExpectedButYFound,sXExpectedButYFound,['char','string'],Expr);
        Result:=CreateLiteralNumber(Expr,ord(WS[1]));
        exit;
        end;
    else
      RaiseNotSupported(Expr,AContext,20170415205955);
    end;
    end
  else if Result.ClassType=TJSCallExpression then
    begin
    Call:=TJSCallExpression(Result);
    if (Call.Expr is TJSDotMemberExpression) then
      begin
      DotExpr:=TJSDotMemberExpression(Call.Expr);
      if DotExpr.Name='charCodeAt' then
        exit;
      if DotExpr.Name='charAt' then
        begin
        DotExpr.Name:='charCodeAt';
        exit;
        end;
      end;
    end;

  if AContext.Resolver<>nil then
    begin
    AContext.Resolver.ComputeElement(Expr,ExprResolved,[]);
    if (ExprResolved.BaseType in btAllJSStringAndChars)
        or ((ExprResolved.BaseType=btRange) and (ExprResolved.SubType in btAllJSChars)) then
      begin
      // aChar -> aChar.charCodeAt()
      Result:=CreateCallCharCodeAt(Result,0,Expr);
      end
    else if ExprResolved.BaseType in btAllJSInteger then
      begin
      // ok
      end
    else if ExprResolved.BaseType=btContext then
      begin
      if ExprResolved.TypeEl.ClassType=TPasEnumType then
        // ok
      else
        RaiseNotSupported(Expr,AContext,20170415191933);
      end
    else
      begin
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.CreateSetLiteralElement ',GetResolverResultDbg(ExprResolved));
      {$ENDIF}
      RaiseNotSupported(Expr,AContext,20170415191822);
      end;
    end;
end;

procedure TPasToJSConverter.ConvertCharLiteralToInt(Lit: TJSLiteral;
  ErrorEl: TPasElement; AContext: TConvertContext);
var
  JS: TJSString;
begin
  if Lit.Value.ValueType<>jstString then
    RaiseInconsistency(20171112020856,ErrorEl);
  if Lit.Value.CustomValue<>'' then
    JS:=Lit.Value.CustomValue
  else
    JS:=Lit.Value.AsString;
  if length(JS)<>1 then
    RaiseNotSupported(ErrorEl,AContext,20171112021003);
  Lit.Value.AsNumber:=ord(JS[1]);
end;

function TPasToJSConverter.ClonePrimaryExpression(El: TJSPrimaryExpression;
  Src: TPasElement): TJSPrimaryExpression;
begin
  Result:=TJSPrimaryExpression(CreateElement(TJSElementClass(El.ClassType),Src));
  if Result.ClassType=TJSPrimaryExpressionIdent then
    TJSPrimaryExpressionIdent(Result).Name:=TJSPrimaryExpressionIdent(El).Name;
end;

function TPasToJSConverter.CreateRecordInit(aRecord: TPasRecordType;
  Expr: TPasElement; El: TPasElement; AContext: TConvertContext): TJSElement;
// new recordtype()
var
  NewMemE: TJSNewMemberExpression;
begin
  if Expr<>nil then
    RaiseNotSupported(Expr,AContext,20161024192747);
  NewMemE:=TJSNewMemberExpression(CreateElement(TJSNewMemberExpression,El));
  Result:=NewMemE;
  NewMemE.MExpr:=CreateReferencePathExpr(aRecord,AContext);
end;

function TPasToJSConverter.CreateArrayInit(ArrayType: TPasArrayType;
  Expr: TPasExpr; El: TPasElement; AContext: TConvertContext): TJSElement;
var
  Call: TJSCallExpression;
  ArrLit: TJSArrayLiteral;
  i, DimSize: Integer;
  RangeResolved, ElTypeResolved, ExprResolved: TPasResolverResult;
  Range: TPasExpr;
  Lit: TJSLiteral;
  CurArrayType: TPasArrayType;
  DefaultValue: TJSElement;
  ArrayValues: TPasExprArray;
  US: TJSString;
  DimLits: TObjectList;
begin
  if Assigned(Expr) then
    begin
    // init array with constant(s)
    if AContext.Resolver=nil then
      DoError(20161024192739,nInitializedArraysNotSupported,sInitializedArraysNotSupported,[],ArrayType);
    ArrLit:=TJSArrayLiteral(CreateElement(TJSArrayLiteral,El));
    try
      AContext.Resolver.ComputeElement(Expr,ExprResolved,[rcConstant]);
      if (ExprResolved.BaseType=btSet)
          and (ExprResolved.ExprEl is TArrayValues) then
        begin
        ArrayValues:=TArrayValues(ExprResolved.ExprEl).Values;
        for i:=0 to length(ArrayValues)-1 do
          ArrLit.Elements.AddElement.Expr:=ConvertElement(ArrayValues[i],AContext);
        end
      else if ExprResolved.BaseType in btAllStringAndChars then
        begin
        US:=TJSString(UTF8Decode(AContext.Resolver.ComputeConstString(Expr,false,true)));
        for i:=1 to length(US) do
          ArrLit.Elements.AddElement.Expr:=CreateLiteralJSString(Expr,US[i]);
        end
      else
        RaiseNotSupported(Expr,AContext,20170223133034);
      Result:=ArrLit;
    finally
      if Result=nil then
        ArrLit.Free;
    end;
    end
  else if length(ArrayType.Ranges)=0 then
    begin
    // empty dynamic array: []
    Result:=TJSArrayLiteral(CreateElement(TJSArrayLiteral,El));
    end
  else
    begin
    // static array
    // create "rtl.arraySetLength(null,defaultvalue,dim1,dim2,...)"
    if AContext.Resolver=nil then
      RaiseNotSupported(El,AContext,20170223113050,'');
    Result:=nil;
    DimLits:=TObjectList.Create(true);
    try
      Call:=CreateCallExpression(El);
      Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnArray_SetLength]]);
      // add parameter null
      Call.AddArg(CreateLiteralNull(El));

      // create parameters dim1,dim2,...
      CurArrayType:=ArrayType;
      while true do
        begin
        for i:=0 to length(CurArrayType.Ranges)-1 do
          begin
          Range:=CurArrayType.Ranges[i];
          // compute size of this dimension
          DimSize:=AContext.Resolver.GetRangeLength(Range);
          if DimSize=0 then
            begin
            AContext.Resolver.ComputeElement(Range,RangeResolved,[rcConstant]);
            RaiseNotSupported(Range,AContext,20170223113318,GetResolverResultDbg(RangeResolved));
            end;
          Lit:=CreateLiteralNumber(El,DimSize);
          DimLits.Add(Lit);
          end;
        AContext.Resolver.ComputeElement(CurArrayType.ElType,ElTypeResolved,[rcType]);
        if (ElTypeResolved.TypeEl is TPasArrayType) then
          begin
          CurArrayType:=TPasArrayType(ElTypeResolved.TypeEl);
          if length(CurArrayType.Ranges)>0 then
            begin
            // nested static array
            continue;
            end;
          end;
        break;
        end;

      // add parameter defaultvalue
      DefaultValue:=CreateValInit(ElTypeResolved.TypeEl,nil,El,AContext);
      Call.AddArg(DefaultValue);

      // add parameters dim1,dim2,...
      for i:=0 to DimLits.Count-1 do
        Call.AddArg(TJSElement(DimLits[i]));
      DimLits.OwnsObjects:=false;
      DimLits.Clear;

      Result:=Call;
    finally
      DimLits.Free;
      if Result=nil then
        Call.Free;
    end;
    end;
end;

function TPasToJSConverter.CreateCmpArrayWithNil(El: TPasElement;
  JSArray: TJSElement; OpCode: TExprOpCode): TJSElement;
// convert "array = nil" to "rtl.length(array) > 0"
// convert "array <> nil" to "rtl.length(array) === 0"
var
  Call: TJSCallExpression;
  BinExpr: TJSBinaryExpression;
begin
  if not (OpCode in [eopEqual,eopNotEqual]) then
    RaiseInconsistency(20170401184819,El);
  Call:=CreateCallExpression(El);
  Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnArray_Length]]);
  Call.AddArg(JSArray);
  if OpCode=eopEqual then
    BinExpr:=TJSEqualityExpressionSEQ(CreateElement(TJSEqualityExpressionSEQ,El))
  else
    BinExpr:=TJSRelationalExpressionGT(CreateElement(TJSRelationalExpressionGT,El));
  BinExpr.A:=Call;
  BinExpr.B:=CreateLiteralNumber(El,0);
  Result:=BinExpr;
end;

function TPasToJSConverter.CreateReferencePath(El: TPasElement;
  AContext: TConvertContext; Kind: TRefPathKind; Full: boolean;
  Ref: TResolvedReference): string;
{ Notes:
 - local var, argument or result variable, even higher lvl does not need a reference path
   local vars are also argument, result var, result variable
 - with context uses the local $withnnn var
 - auto created local var
 otherwise use absolute path
}

  function GetReferenceEl: TPasElement;
  begin
    if Ref<>nil then
      Result:=Ref.Element
    else
      Result:=El;
  end;

  function IsLocalVar: boolean;
  begin
    Result:=false;
    if El.ClassType=TPasArgument then
      exit(true);
    if El.ClassType=TPasResultElement then
      exit(true);
    if AContext.Resolver=nil then
      exit(true);
    if El.Parent=nil then
      RaiseNotSupported(El,AContext,20170203121306,GetObjName(El));
    if El.Parent.ClassType=TPasImplExceptOn then
      exit(true);
    if not (El.Parent is TProcedureBody) then exit;
    Result:=true;
  end;

  procedure Prepend(var aPath: string; Prefix: string);
  begin
    if aPath<>'' then
      aPath:='.'+aPath;
    aPath:=Prefix+aPath;
  end;

  function IsClassFunction(Proc: TPasElement): boolean;
  var
    C: TClass;
  begin
    if Proc=nil then exit(false);
    C:=Proc.ClassType;
    Result:=(C=TPasClassFunction) or (C=TPasClassProcedure)
         or (C=TPasClassConstructor) or (C=TPasClassDestructor);
  end;

  procedure Append_GetClass(Member: TPasElement);
  begin
    if (Member.Parent as TPasClassType).IsExternal then
      exit;
    if Result<>'' then
      Result:=Result+'.'+FBuiltInNames[pbivnPtrClass]
    else
      Result:=FBuiltInNames[pbivnPtrClass];
  end;

  function GetAbsoluteAlias: string;
  var
    AbsolResolved: TPasResolverResult;
  begin
    AContext.Resolver.ComputeElement(TPasVariable(El).AbsoluteExpr,AbsolResolved,[rcNoImplicitProc]);
    Result:=CreateReferencePath(AbsolResolved.IdentEl,AContext,Kind,Full,Ref);
  end;

var
  FoundModule: TPasModule;
  ParentEl: TPasElement;
  Dot: TDotContext;
  WithData: TPas2JSWithExprScope;
  ProcScope: TPasProcedureScope;
  ShortName: String;
  SelfContext: TFunctionContext;
  ElClass: TClass;
begin
  Result:='';
  {$IFDEF VerbosePas2JS}
  //writeln('TPasToJSConverter.CreateReferencePath START El=',GetObjName(El),' Parent=',GetObjName(El.Parent),' Context=',GetObjName(AContext),' SelfContext=',GetObjName(AContext.GetSelfContext));
  //AContext.WriteStack;
  {$ENDIF}
  if (El is TPasType) and (AContext<>nil) then
    El:=AContext.Resolver.ResolveAliasType(TPasType(El));

  ElClass:=El.ClassType;
  if ElClass.InheritsFrom(TPasVariable) and (TPasVariable(El).AbsoluteExpr<>nil)
      and (AContext.Resolver<>nil) then
    exit(GetAbsoluteAlias);

  if AContext is TDotContext then
    begin
    Dot:=TDotContext(AContext);
    if Dot.Resolver<>nil then
      begin
      if ElClass.InheritsFrom(TPasVariable) then
        begin
        //writeln('TPasToJSConverter.CreateReferencePath Left=',GetResolverResultDbg(Dot.LeftResolved),' Right=class var ',GetObjName(El));
        if (ClassVarModifiersType*TPasVariable(El).VarModifiers<>[])
            and (Dot.Access=caAssign)
            and Dot.Resolver.ResolvedElIsClassInstance(Dot.LeftResolved) then
          begin
          // writing a class var
          Append_GetClass(El);
          end;
        end
      else if IsClassFunction(El) then
        begin
        if Dot.Resolver.ResolvedElIsClassInstance(Dot.LeftResolved) then
          // accessing a class method from an object, 'this' must be the class
          Append_GetClass(El);
        end;
      end;
    end
  else if (Ref<>nil) and (Ref.WithExprScope<>nil) then
    begin
    // using local WITH var
    WithData:=Ref.WithExprScope as TPas2JSWithExprScope;
    Prepend(Result,WithData.WithVarName);
    end
  else if IsLocalVar then
    begin
    // El is local var -> does not need path
    end
  else if ElClass.InheritsFrom(TPasProcedure) and (TPasProcedure(El).LibrarySymbolName<>nil)
      and not (El.Parent is TPasClassType) then
    begin
    // an external function -> use the literal
    if Kind=rpkPathAndName then
      Result:=ComputeConstString(TPasProcedure(El).LibrarySymbolName,AContext,true)
    else
      Result:='';
    exit;
    end
  else if ElClass.InheritsFrom(TPasVariable) and (TPasVariable(El).ExportName<>nil)
      and not (El.Parent is TPasClassType) then
    begin
    // an external var -> use the literal
    if Kind=rpkPathAndName then
      Result:=ComputeConstString(TPasVariable(El).ExportName,AContext,true)
    else
      Result:='';
    exit;
    end
  else if (ElClass=TPasClassType) and TPasClassType(El).IsExternal then
    begin
    // an external var -> use the literal
    Result:=TPasClassType(El).ExternalName;
    exit;
    end
  else
    begin
    // need full path
    if El.Parent=nil then
      RaiseNotSupported(El,AContext,20170201172141,GetObjName(El));
    if (El.CustomData is TPasProcedureScope) then
      begin
      // proc: always use the declaration, not the body
      ProcScope:=TPasProcedureScope(El.CustomData);
      if ProcScope.DeclarationProc<>nil then
        El:=ProcScope.DeclarationProc;
      end;

    ParentEl:=El.Parent;
    while ParentEl<>nil do
      begin
      if (ParentEl.CustomData is TPasProcedureScope) then
        begin
        // proc: always use the the declaration, not the body
        ProcScope:=TPasProcedureScope(ParentEl.CustomData);
        if ProcScope.DeclarationProc<>nil then
          ParentEl:=ProcScope.DeclarationProc;
        end;

      // check if there is a local var
      ShortName:=AContext.GetLocalName(ParentEl);

      if ParentEl.ClassType=TImplementationSection then
        begin
        // element is in an implementation section (not program/library section)
        if ShortName<>'' then
          Prepend(Result,ShortName)
        else
          begin
          // in other unit -> use pas.unitname.$impl
          FoundModule:=El.GetModule;
          if FoundModule=nil then
            RaiseInconsistency(20161024192755,El);
          Prepend(Result,TransformModuleName(FoundModule,true,AContext)
             +'.'+FBuiltInNames[pbivnImplementation]);
          end;
        break;
        end
      else if ParentEl is TPasModule then
        begin
        // element is in an unit interface or program/library section
        if ShortName<>'' then
          Prepend(Result,ShortName)
        else
          Prepend(Result,TransformModuleName(TPasModule(ParentEl),true,AContext));
        break;
        end
      else if (ParentEl.ClassType=TPasClassType)
          or (ParentEl.ClassType=TPasRecordType) then
        begin
        // parent is a class or record declaration
        if Full then
          Prepend(Result,ParentEl.Name)
        else
          begin
          // Pascal and JS have similar scoping rules (we are not in a dotscope),
          // so 'this' can be used.
          SelfContext:=AContext.GetSelfContext;
          if ShortName<>'' then
            Result:=ShortName
          else if AContext.GetFunctionContext.ThisPas<>nil then
            Result:='this'
          else if SelfContext<>nil then
            Result:=SelfContext.GetLocalName(SelfContext.ThisPas)
          else
            RaiseNotSupported(El,AContext,20180125004049);
          if (SelfContext<>nil) and not IsClassFunction(SelfContext.PasElement) then
            begin
            // inside a method -> Self is a class instance
            if El is TPasVariable then
              begin
              //writeln('TPasToJSConverter.CreateReferencePath class var ',GetObjName(El),' This=',GetObjName(This));
              if (ClassVarModifiersType*TPasVariable(El).VarModifiers<>[])
                  and (AContext.Access=caAssign) then
                begin
                  Append_GetClass(El); // writing a class var
                end;
              end
            else if IsClassFunction(El) then
              Append_GetClass(El); // accessing a class function
            end;
          break;
          end;
        end
      else if ParentEl.ClassType=TPasEnumType then
        Prepend(Result,ParentEl.Name);
      ParentEl:=ParentEl.Parent;
      end;
    end;
  if (Result<>'') and (Kind in [rpkPathWithDot,rpkPathAndName]) then
    Result:=Result+'.';
  if Kind=rpkPathAndName then
    Result:=Result+TransformVariableName(El,AContext);
end;

function TPasToJSConverter.CreateReferencePathExpr(El: TPasElement;
  AContext: TConvertContext; Full: boolean; Ref: TResolvedReference
  ): TJSElement;
var
  Name: String;
  Src: TPasElement;
begin
  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.CreateReferencePathExpr El="',GetObjName(El),'" El.Parent=',GetObjName(El.Parent),' ',GetObjName(AContext));
  {$ENDIF}
  Name:=CreateReferencePath(El,AContext,rpkPathAndName,Full,Ref);
  if Ref<>nil then
    Src:=Ref.Element
  else
    Src:=nil;
  Result:=CreatePrimitiveDotExpr(Name,Src);
end;

procedure TPasToJSConverter.CreateProcedureCall(var Call: TJSCallExpression;
  Args: TParamsExpr; TargetProc: TPasProcedureType; AContext: TConvertContext);
// create a call, adding call by reference and default values
begin
  if Call=nil then
    Call:=TJSCallExpression(CreateElement(TJSCallExpression,Args));
  if ((Args=nil) or (length(Args.Params)=0))
      and ((TargetProc=nil) or (TargetProc.Args.Count=0)) then
    exit;
  if Call.Args=nil then
    Call.Args:=TJSArguments(CreateElement(TJSArguments,Args));
  CreateProcedureCallArgs(Call.Args.Elements,Args,TargetProc,AContext);
end;

procedure TPasToJSConverter.CreateProcedureCallArgs(
  Elements: TJSArrayLiteralElements; Args: TParamsExpr;
  TargetProc: TPasProcedureType; AContext: TConvertContext);
// Add call arguments. Handle call by reference and default values
var
  ArgContext: TConvertContext;
  i: Integer;
  Arg: TJSElement;
  TargetArgs: TFPList;
  TargetArg: TPasArgument;
  OldAccess: TCtxAccess;
begin
  // get context
  ArgContext:=AContext;
  while ArgContext is TDotContext do
    ArgContext:=ArgContext.Parent;
  i:=0;
  OldAccess:=ArgContext.Access;
  if TargetProc<>nil then
    TargetArgs:=TargetProc.Args
  else
    TargetArgs:=nil;
  // add params
  if Args<>nil then
    while i<length(Args.Params) do
      begin
      if (TargetArgs<>nil) and (i<TargetArgs.Count) then
        TargetArg:=TPasArgument(TargetArgs[i])
      else
        TargetArg:=nil;
      Arg:=CreateProcCallArg(Args.Params[i],TargetArg,ArgContext);
      Elements.AddElement.Expr:=Arg;
      inc(i);
      end;
  // fill up default values
  if TargetProc<>nil then
    begin
    while i<TargetArgs.Count do
      begin
      TargetArg:=TPasArgument(TargetArgs[i]);
      if TargetArg.ValueExpr=nil then
        begin
        {$IFDEF VerbosePas2JS}
        writeln('TPasToJSConverter.CreateProcedureCallArgs missing default value: TargetProc=',TargetProc.Name,' i=',i);
        {$ENDIF}
        RaiseNotSupported(Args,AContext,20170201193601);
        end;
      AContext.Access:=caRead;
      Arg:=ConvertElement(TargetArg.ValueExpr,ArgContext);
      Elements.AddElement.Expr:=Arg;
      inc(i);
      end;
    end;
  ArgContext.Access:=OldAccess;
end;

function TPasToJSConverter.CreateProcCallArg(El: TPasExpr;
  TargetArg: TPasArgument; AContext: TConvertContext): TJSElement;
var
  ExprResolved, ArgResolved: TPasResolverResult;
  ExprFlags: TPasResolverComputeFlags;
  NeedVar: Boolean;
  ArgTypeEl, ExprTypeEl: TPasType;
begin
  Result:=nil;
  if TargetArg=nil then
    begin
    // simple conversion
    AContext.Access:=caRead;
    Result:=ConvertElement(El,AContext);
    exit;
    end;

  if not (TargetArg.Access in [argDefault,argVar,argOut,argConst]) then
    DoError(20170213220927,nPasElementNotSupported,sPasElementNotSupported,
            [AccessNames[TargetArg.Access]],El);

  NeedVar:=TargetArg.Access in [argVar,argOut];
  AContext.Resolver.ComputeElement(TargetArg,ArgResolved,[]);
  ArgTypeEl:=AContext.Resolver.ResolveAliasType(ArgResolved.TypeEl);
  ExprFlags:=[];
  if NeedVar then
    Include(ExprFlags,rcNoImplicitProc)
  else if AContext.Resolver.IsProcedureType(ArgResolved,true) then
    Include(ExprFlags,rcNoImplicitProcType);

  if (ArgTypeEl is TPasArrayType)
      and (El is TParamsExpr) and (TParamsExpr(El).Kind=pekSet) then
    begin
    // passing a set to an open array
    if NeedVar then
      RaiseNotSupported(El,AContext,20170326213042);
    Result:=ConvertOpenArrayParam(ArgTypeEl,TParamsExpr(El),AContext);
    exit;
    end;

  AContext.Resolver.ComputeElement(El,ExprResolved,ExprFlags);

  // consider TargetArg access
  if NeedVar then
    Result:=CreateProcCallArgRef(El,ExprResolved,TargetArg,AContext)
  else
    begin
    // pass as default, const or constref
    AContext.Access:=caRead;

    if (ExprResolved.BaseType=btNil) and (ArgTypeEl is TPasArrayType) then
      begin
      // arrays must never be null -> pass []
      Result:=TJSArrayLiteral(CreateElement(TJSArrayLiteral,El));
      exit;
      end;

    Result:=ConvertElement(El,AContext);

    if TargetArg.Access=argDefault then
      begin
      if (ExprResolved.BaseType=btSet) and (ExprResolved.IdentEl<>nil) then
        begin
        // right side is a set variable -> create reference
        {$IFDEF VerbosePas2JS}
        writeln('TPasToJSConverter.CreateProcedureCallArg create reference of SET variable Right={',GetResolverResultDbg(ExprResolved),'} AssignContext.RightResolved.IdentEl=',GetObjName(ExprResolved.IdentEl));
        {$ENDIF}
        // create  rtl.refSet(right)
        Result:=CreateReferencedSet(El,Result);
        exit;
        end
      else if ExprResolved.BaseType=btContext then
        begin
        ExprTypeEl:=AContext.Resolver.ResolveAliasType(ExprResolved.TypeEl);
        if (ExprTypeEl.ClassType=TPasArrayType) then
          begin
          if length(TPasArrayType(ExprTypeEl).Ranges)>0 then
            begin
            // right side is a static array -> clone
            Result:=CreateCloneStaticArray(El,TPasArrayType(ExprTypeEl),Result,AContext);
            exit;
            end;
          end
        else if ExprTypeEl.ClassType=TPasRecordType then
          begin
          // right side is a record -> clone
          {$IFDEF VerbosePas2JS}
          writeln('TPasToJSConverter.CreateProcedureCallArg clone RECORD variable Right={',GetResolverResultDbg(ExprResolved),'} AssignContext.RightResolved.IdentEl=',GetObjName(ExprResolved.IdentEl));
          {$ENDIF}
          // create  "new RightRecordType(RightRecord)"
          Result:=CreateCloneRecord(El,TPasRecordType(ExprTypeEl),Result,AContext);
          exit;
          end;
        end;
      end;
    end;
end;

function TPasToJSConverter.CreateProcCallArgRef(El: TPasExpr;
  ResolvedEl: TPasResolverResult; TargetArg: TPasArgument;
  AContext: TConvertContext): TJSElement;
const
  GetPathName = 'p';
  SetPathName = 's';
  ParamName = 'a';
var
  Obj: TJSObjectLiteral;

  procedure AddVar(const aName: string; var Expr: TJSElement);
  var
    ObjLit: TJSObjectLiteralElement;
  begin
    if Expr=nil then exit;
    ObjLit:=Obj.Elements.AddElement;
    ObjLit.Name:=TJSString(aName);
    ObjLit.Expr:=Expr;
    Expr:=nil;
  end;

var
  ParamContext: TParamContext;
  FullGetter, GetPathExpr, SetPathExpr, GetExpr, SetExpr, ParamExpr: TJSElement;
  AssignSt: TJSSimpleAssignStatement;
  ObjLit: TJSObjectLiteralElement;
  FuncSt: TJSFunctionDeclarationStatement;
  RetSt: TJSReturnStatement;
  GetDotPos, SetDotPos: Integer;
  GetPath, SetPath: String;
  BracketExpr: TJSBracketMemberExpression;
  DotExpr: TJSDotMemberExpression;
begin
  // pass reference -> create a temporary JS object with a FullGetter and setter
  Obj:=nil;
  FullGetter:=nil;
  ParamContext:=TParamContext.Create(El,nil,AContext);
  GetPathExpr:=nil;
  SetPathExpr:=nil;
  GetExpr:=nil;
  SetExpr:=nil;
  try
    // create FullGetter and setter
    ParamContext.Access:=caByReference;
    ParamContext.Arg:=TargetArg;
    ParamContext.Expr:=El;
    ParamContext.ResolvedExpr:=ResolvedEl;
    FullGetter:=ConvertElement(El,ParamContext);
    // FullGetter is now a full JS expression to retrieve the value.
    if ParamContext.ReusingReference then
      begin
      // result is already a reference
      Result:=FullGetter;
      exit;
      end;

    // if ParamContext.Getter is set then
    // ParamContext.Getter is the last part of the FullGetter
    // FullSetter is created from FullGetter by replacing the Getter with the Setter
    {$IFDEF VerbosePas2JS}
    writeln('TPasToJSConverter.CreateProcedureCallArg VAR FullGetter=',GetObjName(FullGetter),' Getter=',GetObjName(ParamContext.Getter),' Setter=',GetObjName(ParamContext.Setter));
    {$ENDIF}
    if (ParamContext.Getter=nil)<>(ParamContext.Setter=nil) then
      begin
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.CreateProcedureCallArg FullGetter=',GetObjName(FullGetter),' Getter=',GetObjName(ParamContext.Getter),' Setter=',GetObjName(ParamContext.Setter));
      {$ENDIF}
      RaiseInconsistency(20170213222941,El);
      end;

    // create "{p:Result,get:function(){return this.p.Getter},set:function(v){this.p.Setter(v);}}"
    Obj:=TJSObjectLiteral(CreateElement(TJSObjectLiteral,El));

    if FullGetter.ClassType=TJSPrimaryExpressionIdent then
      begin
      // create "{get:function(){return FullGetter;},set:function(v){FullGetter=v;}}"
      if (ParamContext.Getter<>nil) and (ParamContext.Getter<>FullGetter) then
        RaiseInconsistency(20170213224339,El);
      GetPath:=String(TJSPrimaryExpressionIdent(FullGetter).Name);
      GetDotPos:=PosLast('.',GetPath);
      if GetDotPos>0 then
        begin
        // e.g. path1.path2.readvar
        // create
        //    GetPathExpr: path1.path2
        //    GetExpr:     this.p.readvar
        // Will create "{p:GetPathExpr, get:function(){return GetExpr;},
        //                              set:function(v){GetExpr = v;}}"
        GetPathExpr:=CreatePrimitiveDotExpr(LeftStr(GetPath,GetDotPos-1),El);
        GetExpr:=CreateDotExpression(El,CreatePrimitiveDotExpr('this.'+GetPathName,El),
            CreatePrimitiveDotExpr(copy(GetPath,GetDotPos+1),El));
        if ParamContext.Setter=nil then
          SetExpr:=CreateDotExpression(El,CreatePrimitiveDotExpr('this.'+GetPathName,El),
            CreatePrimitiveDotExpr(copy(GetPath,GetDotPos+1),El));
        end
      else
        begin
        // local var
        GetExpr:=FullGetter;
        FullGetter:=nil;
        if ParamContext.Setter=nil then
          SetExpr:=CreatePrimitiveDotExpr(GetPath,El);
        end;

      if ParamContext.Setter<>nil then
        begin
        // custom Setter
        SetExpr:=ParamContext.Setter;
        ParamContext.Setter:=nil;
        if SetExpr.ClassType=TJSPrimaryExpressionIdent then
          begin
          SetPath:=String(TJSPrimaryExpressionIdent(SetExpr).Name);
          SetDotPos:=PosLast('.',SetPath);
          FreeAndNil(SetExpr);
          if LeftStr(GetPath,GetDotPos)=LeftStr(SetPath,SetDotPos) then
            begin
            // use GetPathExpr for setter
            SetExpr:=CreateDotExpression(El,CreatePrimitiveDotExpr('this.'+GetPathName,El),
                CreatePrimitiveDotExpr(copy(SetPath,GetDotPos+1),El));
            end
          else
            begin
            // setter needs its own SetPathExpr
            SetPathExpr:=CreatePrimitiveDotExpr(LeftStr(SetPath,SetDotPos-1),El);
            SetExpr:=CreateDotExpression(El,CreatePrimitiveDotExpr('this.'+SetPathName,El),
                CreatePrimitiveDotExpr(copy(SetPath,GetDotPos+1),El));
            end;
          end;
        end;
      end
    else if FullGetter.ClassType=TJSDotMemberExpression then
      begin
      if ParamContext.Setter<>nil then
        RaiseNotSupported(El,AContext,20170214231900);
      // convert  this.r.i  to
      // {p:this.r,
      //  get:function{return this.p.i;},
      //  set:function(v){this.p.i=v;}
      // }
      // GetPathExpr:  this.r
      // GetExpr:  this.p.i
      // SetExpr:  this.p.i
      DotExpr:=TJSDotMemberExpression(FullGetter);
      GetPathExpr:=DotExpr.MExpr;
      DotExpr.MExpr:=CreatePrimitiveDotExpr('this.'+GetPathName,El);
      GetExpr:=DotExpr;
      FullGetter:=nil;
      SetExpr:=CreateDotExpression(El,
        CreatePrimitiveDotExpr('this.'+GetPathName,El),
        CreatePrimitiveDotExpr(String(DotExpr.Name),El));
      end
    else if FullGetter.ClassType=TJSBracketMemberExpression then
      begin
      if ParamContext.Setter<>nil then
        RaiseNotSupported(El,AContext,20170214215150);
      // convert  this.arr[value]  to
      // {a:value,
      //  p:this.arr,
      //  get:function{return this.p[this.a];},
      //  set:function(v){this.p[this.a]=v;}
      // }
      BracketExpr:=TJSBracketMemberExpression(FullGetter);
      ParamExpr:=BracketExpr.Name;

      // create "a:value"
      BracketExpr.Name:=CreatePrimitiveDotExpr('this.'+ParamName,El);
      AddVar(ParamName,ParamExpr);

      // create GetPathExpr "this.arr"
      GetPathExpr:=BracketExpr.MExpr;
      BracketExpr.MExpr:=CreatePrimitiveDotExpr('this.'+GetPathName,El);

      // GetExpr  "this.p[this.a]"
      GetExpr:=BracketExpr;
      FullGetter:=nil;

      // SetExpr  "this.p[this.a]"
      BracketExpr:=TJSBracketMemberExpression(CreateElement(TJSBracketMemberExpression,El));
      SetExpr:=BracketExpr;
      BracketExpr.MExpr:=CreatePrimitiveDotExpr('this.'+GetPathName,El);
      BracketExpr.Name:=CreatePrimitiveDotExpr('this.'+ParamName,El);

      end
    else
      begin
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.CreateProcedureCallArg FullGetter=',GetObjName(FullGetter),' Getter=',GetObjName(ParamContext.Getter),' Setter=',GetObjName(ParamContext.Setter));
      {$ENDIF}
      RaiseNotSupported(El,AContext,20170213230336);
      end;

    if (SetExpr.ClassType=TJSPrimaryExpressionIdent)
        or (SetExpr.ClassType=TJSDotMemberExpression)
        or (SetExpr.ClassType=TJSBracketMemberExpression) then
      begin
      // create   SetExpr = v;
      AssignSt:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,El));
      AssignSt.LHS:=SetExpr;
      AssignSt.Expr:=CreatePrimitiveDotExpr(TempRefObjSetterArgName,El);
      SetExpr:=AssignSt;
      end
    else if (SetExpr.ClassType=TJSCallExpression) then
      // has already the form  Func(v)
    else
      RaiseInconsistency(20170213225940,El);

    // add   p:GetPathExpr
    AddVar(GetPathName,GetPathExpr);

    // add   get:function(){ return GetExpr; }
    ObjLit:=Obj.Elements.AddElement;
    ObjLit.Name:=TempRefObjGetterName;
    FuncSt:=CreateFunctionSt(El);
    ObjLit.Expr:=FuncSt;
    RetSt:=TJSReturnStatement(CreateElement(TJSReturnStatement,El));
    FuncSt.AFunction.Body.A:=RetSt;
    RetSt.Expr:=GetExpr;
    GetExpr:=nil;

    // add   s:GetPathExpr
    AddVar(SetPathName,SetPathExpr);

    // add   set:function(v){ SetExpr }
    ObjLit:=Obj.Elements.AddElement;
    ObjLit.Name:=TempRefObjSetterName;
    FuncSt:=CreateFunctionSt(El);
    ObjLit.Expr:=FuncSt;
    FuncSt.AFunction.Params.Add(TempRefObjSetterArgName);
    FuncSt.AFunction.Body.A:=SetExpr;
    SetExpr:=nil;

    Result:=Obj;
  finally
    if Result=nil then
      begin
      GetPathExpr.Free;
      SetPathExpr.Free;
      GetExpr.Free;
      SetExpr.Free;
      Obj.Free;
      ParamContext.Setter.Free;
      FullGetter.Free;
      end;
    ParamContext.Free;
  end;
end;

function TPasToJSConverter.CreateArgumentAccess(Arg: TPasArgument;
  AContext: TConvertContext; PosEl: TPasElement): TJSElement;
var
  Call: TJSCallExpression;
  AssignContext: TAssignContext;
  ParamContext: TParamContext;
  Name: String;
begin
  if Arg.Access in [argVar,argOut] then
    begin
    // Arg is a reference object
    case AContext.Access of
      caRead:
        begin
        // create arg.get()
        Call:=CreateCallExpression(PosEl);
        Call.Expr:=CreateDotExpression(PosEl,
          CreateIdentifierExpr(Arg.Name,PosEl,AContext),
          CreatePrimitiveDotExpr(TempRefObjGetterName,PosEl));
        Result:=Call;
        exit;
        end;
      caAssign:
        begin
        // create arg.set(RHS)
        AssignContext:=AContext.AccessContext as TAssignContext;
        if AssignContext.Call<>nil then
          RaiseNotSupported(Arg,AContext,20170214120606);
        Call:=CreateCallExpression(PosEl);
        AssignContext.Call:=Call;
        Call.Expr:=CreateDotExpression(PosEl,
                      CreateIdentifierExpr(Arg.Name,PosEl,AContext),
                      CreatePrimitiveDotExpr(TempRefObjSetterName,PosEl));
        Call.AddArg(AssignContext.RightSide);
        AssignContext.RightSide:=nil;
        Result:=Call;
        exit;
        end;
      caByReference:
        begin
        // simply pass the reference
        ParamContext:=AContext.AccessContext as TParamContext;
        ParamContext.ReusingReference:=true;
        Result:=CreateIdentifierExpr(Arg.Name,PosEl,AContext);
        exit;
        end;
      else
        RaiseNotSupported(Arg,AContext,20170214120739);
    end;
    end;
  if (CompareText(Arg.Name,'Self')=0) and (AContext.GetSelfContext<>nil) then
    Name:=AContext.GetLocalName(Arg)
  else
    Name:=TransformVariableName(Arg,Arg.Name,AContext);
  Result:=CreatePrimitiveDotExpr(Name,PosEl);
end;

function TPasToJSConverter.ConvertExceptOn(El: TPasImplExceptOn;
  AContext: TConvertContext): TJSElement;
// convert "on T do ;" to "if(T.isPrototypeOf(exceptObject)){}"
// convert "on E:T do ;" to "if(T.isPrototypeOf(exceptObject)){ var E=exceptObject; }"
Var
  IfSt : TJSIfStatement;
  ListFirst , ListLast: TJSStatementList;
  DotExpr: TJSDotMemberExpression;
  Call: TJSCallExpression;
  V: TJSVariableStatement;
begin
  Result:=nil;
  // create "if()"
  IfSt:=TJSIfStatement(CreateElement(TJSIfStatement,El));
  try
    // create "T.isPrototypeOf"
    DotExpr:=TJSDotMemberExpression(CreateElement(TJSDotMemberExpression,El));
    DotExpr.MExpr:=CreateReferencePathExpr(El.TypeEl,AContext);
    DotExpr.Name:='isPrototypeOf';
    // create "T.isPrototypeOf(exceptObject)"
    Call:=CreateCallExpression(El);
    Call.Expr:=DotExpr;
    Call.AddArg(CreatePrimitiveDotExpr(FBuiltInNames[pbivnExceptObject],El));
    IfSt.Cond:=Call;

    if El.VarEl<>nil then
      begin
      // add "var E=exceptObject;"
      ListFirst:=TJSStatementList(CreateElement(TJSStatementList,El.Body));
      ListLast:=ListFirst;
      IfSt.BTrue:=ListFirst;
      V:=CreateVarStatement(TransformVariableName(El,El.VariableName,AContext),
        CreatePrimitiveDotExpr(FBuiltInNames[pbivnExceptObject],El),El);
      ListFirst.A:=V;
      // add statements
      AddToStatementList(ListFirst,ListLast,ConvertElement(El.Body,AContext),El);
      end
    else if El.Body<>nil then
      // add statements
      IfSt.BTrue:=ConvertElement(El.Body,AContext);

    Result:=IfSt;
  finally
    if Result=nil then
      IfSt.Free;
  end;
end;

function TPasToJSConverter.ConvertStatement(El: TPasImplStatement;
  AContext: TConvertContext): TJSElement;

begin
  Result:=Nil;
  if (El is TPasImplRaise) then
    Result:=ConvertRaiseStatement(TPasImplRaise(El),AContext)
  else if (El is TPasImplAssign) then
    Result:=ConvertAssignStatement(TPasImplAssign(El),AContext)
  else if (El is TPasImplWhileDo) then
    Result:=ConvertWhileStatement(TPasImplWhileDo(El),AContext)
  else if (El is TPasImplSimple) then
    Result:=ConvertSimpleStatement(TPasImplSimple(El),AContext)
  else if (El is TPasImplWithDo) then
    Result:=ConvertWithStatement(TPasImplWithDo(El),AContext)
  else if (El is TPasImplExceptOn) then
    Result:=ConvertExceptOn(TPasImplExceptOn(El),AContext)
  else if (El is TPasImplForLoop) then
    Result:=ConvertForStatement(TPasImplForLoop(El),AContext)
  else if (El is TPasImplAsmStatement) then
    Result:=ConvertAsmStatement(TPasImplAsmStatement(El),AContext)
  else
    RaiseNotSupported(El,AContext,20161024192759);
{
  TPasImplCaseStatement = class(TPasImplStatement)
}
end;

function TPasToJSConverter.ConvertConst(El: TPasConst; AContext: TConvertContext
  ): TJSElement;
// Important: returns nil if const was added to higher context
Var
  AssignSt: TJSSimpleAssignStatement;
  Obj: TJSObjectLiteral;
  ObjLit: TJSObjectLiteralElement;
  ConstContext: TFunctionContext;
  C: TJSElement;
  V: TJSVariableStatement;
  Src: TJSSourceElements;
  Proc: TPasProcedure;
  ProcScope: TPas2JSProcedureScope;
begin
  Result:=nil;
  if El.AbsoluteExpr<>nil then
    exit; // absolute: do not add a declaration
  if not AContext.IsGlobal then
    begin
    // local const are stored in interface/implementation
    ConstContext:=AContext.GetGlobalFunc;
    if not (ConstContext.JSElement is TJSSourceElements) then
      begin
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.CreateConstDecl ConstContext=',GetObjName(ConstContext),' JSElement=',GetObjName(ConstContext.JSElement));
      {$ENDIF}
      RaiseNotSupported(El,AContext,20170220153216);
      end;
    Src:=TJSSourceElements(ConstContext.JSElement);
    C:=ConvertVariable(El,AContext);
    V:=TJSVariableStatement(CreateElement(TJSVariableStatement,El));
    V.A:=C;
    AddToSourceElements(Src,V);

    if (coStoreImplJS in Options) and (AContext.Resolver<>nil) then
      begin
      Proc:=AContext.Resolver.GetTopLvlProc(AContext.PasElement);
      if Proc<>nil then
        begin
        ProcScope:=TPas2JSProcedureScope(Proc.CustomData);
        ProcScope.AddGlobalJS(StorePrecompiledJS(V));
        end;
      end;
    end
  else if AContext is TObjectContext then
    begin
    // create 'A: initvalue'
    Obj:=TObjectContext(AContext).JSElement as TJSObjectLiteral;
    ObjLit:=Obj.Elements.AddElement;
    ObjLit.Name:=TJSString(TransformVariableName(El,AContext));
    ObjLit.Expr:=CreateVarInit(El,AContext);
    end
  else
    begin
    // create 'this.A=initvalue'
    AssignSt:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,El));
    Result:=AssignSt;
    AssignSt.LHS:=CreateSubDeclNameExpr(El,El.Name,AContext);
    AssignSt.Expr:=CreateVarInit(El,AContext);
    end;
end;

function TPasToJSConverter.ConvertLabelMark(El: TPasImplLabelMark;
  AContext: TConvertContext): TJSElement;

begin
  RaiseNotSupported(El,AContext,20161024192857);
  Result:=Nil;
  // ToDo:   TPasImplLabelMark = class(TPasImplLabelMark) then
end;

function TPasToJSConverter.ConvertElement(El: TPasElement;
  AContext: TConvertContext): TJSElement;
var
  C: TClass;
begin
  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.ConvertElement El=',GetObjName(El),' Context=',GetObjName(AContext));
  {$ENDIF}
  if El=nil then
    begin
    Result:=nil;
    RaiseInconsistency(20161024190203,El);
    end;
  C:=El.ClassType;
  if (C=TPasConst) then
    Result:=ConvertConst(TPasConst(El),AContext)
  else if (C=TPasProperty) then
    Result:=ConvertProperty(TPasProperty(El),AContext)
  else if (C=TPasVariable) then
    Result:=ConvertVariable(TPasVariable(El),AContext)
  else if (C=TPasResString) then
    Result:=ConvertResString(TPasResString(El),AContext)
  else if (C=TPasExportSymbol) then
    Result:=ConvertExportSymbol(TPasExportSymbol(El),AContext)
  else if (C=TPasLabels) then
    Result:=ConvertLabels(TPasLabels(El),AContext)
  else if (C=TPasImplLabelMark) then
    Result:=ConvertLabelMark(TPasImplLabelMark(El),AContext)
  else if C.InheritsFrom(TPasExpr) then
    Result:=ConvertExpression(TPasExpr(El),AContext)
  else if C.InheritsFrom(TPasDeclarations) then
    Result:=ConvertDeclarations(TPasDeclarations(El),AContext)
  else if C.InheritsFrom(TPasProcedure) then
    Result:=ConvertProcedure(TPasProcedure(El),AContext)
  else if C.InheritsFrom(TPasImplBlock) then
    Result:=ConvertImplBlock(TPasImplBlock(El),AContext)
  else if C.InheritsFrom(TPasModule)  then
    Result:=ConvertModule(TPasModule(El),AContext)
  else If (C=TPasPackage)  then
    Result:=ConvertPackage(TPasPackage(El),AContext)
  else
    begin
    Result:=nil;
    RaiseNotSupported(El, AContext, 20161024190449);
    end;
  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.ConvertElement END ',GetObjName(El));
  {$ENDIF}
end;

function TPasToJSConverter.ConvertRecordType(El: TPasRecordType;
  AContext: TConvertContext): TJSElement;
(*
  type
    TMyRecord = record
      i: longint;
      s: string;
      d: double;
      r: TOtherRecord;
    end;

    this.TMyRecord=function(s) {
      if (s){
        this.i = s.i;
        this.s = s.s;
        this.d = s.d;
        this.r = new this.TOtherRecord(s.r);
      } else {
        this.i = 0;
        this.s = "";
        this.d = 0.0;
        this.r = new this.TOtherRecord();
      };
      this.$equal = function(b){
        return (this.i == b.i) && (this.s == b.s) && (this.d == b.d)
          && (this.r.$equal(b.r))
      };
    };
*)
const
  SrcParamName = 's';
  EqualParamName = 'b';

  procedure AddCloneStatements(IfSt: TJSIfStatement;
    FuncContext: TFunctionContext);
  var
    i: Integer;
    PasVar: TPasVariable;
    VarAssignSt: TJSSimpleAssignStatement;
    First, Last: TJSStatementList;
    VarDotExpr: TJSDotMemberExpression;
    PasVarType: TPasType;
  begin
    // init members with s
    First:=nil;
    Last:=nil;
    for i:=0 to El.Members.Count-1 do
      begin
      PasVar:=TPasVariable(El.Members[i]);
      if not IsElementUsed(PasVar) then continue;
      // create 'this.A = s.A;'
      VarAssignSt:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,PasVar));
      AddToStatementList(First,Last,VarAssignSt,PasVar);
      if i=0 then IfSt.BTrue:=First;
      VarAssignSt.LHS:=CreateSubDeclNameExpr(PasVar,PasVar.Name,FuncContext);
      VarDotExpr:=TJSDotMemberExpression(CreateElement(TJSDotMemberExpression,PasVar));
      VarAssignSt.Expr:=VarDotExpr;
      VarDotExpr.MExpr:=CreatePrimitiveDotExpr(SrcParamName,PasVar);
      VarDotExpr.Name:=TJSString(TransformVariableName(PasVar,FuncContext));
      if (AContext.Resolver<>nil) then
        begin
        PasVarType:=AContext.Resolver.ResolveAliasType(PasVar.VarType);
        if PasVarType.ClassType=TPasArrayType then
          begin
          if length(TPasArrayType(PasVarType).Ranges)>0 then
            begin
            // clone sub static array
            VarAssignSt.Expr:=CreateCloneStaticArray(PasVar,TPasArrayType(PasVarType),
                                                VarDotExpr,FuncContext);
            end;
          end
        else if PasVarType.ClassType=TPasRecordType then
          begin
          // clone sub record
          VarAssignSt.Expr:=CreateCloneRecord(PasVar,TPasRecordType(PasVarType),
                                              VarDotExpr,FuncContext);
          end
        else if PasVarType.ClassType=TPasSetType then
          begin
          // clone sub set
          VarAssignSt.Expr:=CreateReferencedSet(PasVar,VarDotExpr);
          end
        end;
      end;
  end;

  procedure AddInitDefaultStatements(IfSt: TJSIfStatement;
    FuncContext: TFunctionContext);
  var
    i: Integer;
    PasVar: TPasVariable;
    JSVar: TJSElement;
    First, Last: TJSStatementList;
  begin
    // the "else" part:
    // when there is no s parameter, init members with default value
    First:=nil;
    Last:=nil;
    for i:=0 to El.Members.Count-1 do
      begin
      PasVar:=TPasVariable(El.Members[i]);
      if not IsElementUsed(PasVar) then continue;
      JSVar:=CreateVarDecl(PasVar,FuncContext);
      AddToStatementList(First,Last,JSVar,PasVar);
      if IfSt.BFalse=nil then
        IfSt.BFalse:=First;
      end;
  end;

  procedure Add_AndExpr_ToReturnSt(RetSt: TJSReturnStatement;
    PasVar: TPasVariable; var LastAndExpr: TJSLogicalAndExpression;
    Expr: TJSElement);
  var
    AndExpr: TJSLogicalAndExpression;
  begin
    if RetSt.Expr=nil then
      RetSt.Expr:=Expr
    else
      begin
      AndExpr:=TJSLogicalAndExpression(CreateElement(TJSLogicalAndExpression,PasVar));
      if LastAndExpr=nil then
        begin
        AndExpr.A:=RetSt.Expr;
        RetSt.Expr:=AndExpr;
        end
      else
        begin
        AndExpr.A:=LastAndExpr.B;
        LastAndExpr.B:=AndExpr;
        end;
      AndExpr.B:=Expr;
      LastAndExpr:=AndExpr;
      end;
  end;

  procedure AddEqualFunction(var BodyFirst, BodyLast: TJSStatementList;
    FuncContext: TFunctionContext);
  // add equal function:
  // this.$equal = function(b){
  //   return (this.member1 == b.member1);
  // };
  var
    AssignSt: TJSSimpleAssignStatement;
    FD: TJSFuncDef;
    RetSt: TJSReturnStatement;
    i: Integer;
    PasVar: TPasVariable;
    FDS: TJSFunctionDeclarationStatement;
    EqExpr: TJSEqualityExpressionSEQ;
    LastAndExpr: TJSLogicalAndExpression;
    VarType: TPasType;
    Call: TJSCallExpression;
    VarName: String;
  begin
    // add "this.$equal ="
    AssignSt:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,El));
    AssignSt.LHS:=CreateMemberExpression(['this',FBuiltInNames[pbifnRecordEqual]]);
    AddToStatementList(BodyFirst,BodyLast,AssignSt,El);
    // add "function(b){"
    FDS:=CreateFunctionSt(El);
    AssignSt.Expr:=FDS;
    FD:=FDS.AFunction;
    FD.Params.Add(EqualParamName);
    FD.Body:=TJSFunctionBody(CreateElement(TJSFunctionBody,El));
    // add "return "
    RetSt:=TJSReturnStatement(CreateElement(TJSReturnStatement,El));
    FD.Body.A:=RetSt;
    LastAndExpr:=nil;
    for i:=0 to El.Members.Count-1 do
      begin
      PasVar:=TPasVariable(El.Members[i]);
      if not IsElementUsed(PasVar) then continue;
      // "this.member = b.member;"
      VarType:=PasVar.VarType;
      if FuncContext.Resolver<>nil then
        VarType:=FuncContext.Resolver.ResolveAliasType(VarType);
      VarName:=TransformVariableName(PasVar,FuncContext);
      if VarType.ClassType=TPasRecordType then
        begin
        // record
        // add "this.member.$equal(b.member)"
        Call:=CreateCallExpression(PasVar);
        Add_AndExpr_ToReturnSt(RetSt,PasVar,LastAndExpr,Call);
        Call.Expr:=CreateMemberExpression(['this',VarName,FBuiltInNames[pbifnRecordEqual]]);
        Call.AddArg(CreateMemberExpression([EqualParamName,VarName]));
        end
      else if VarType.ClassType=TPasSetType then
        begin
        // set
        // add "rtl.eqSet(this.member,b.member)"
        Call:=CreateCallExpression(PasVar);
        Add_AndExpr_ToReturnSt(RetSt,PasVar,LastAndExpr,Call);
        Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnSet_Equal]]);
        Call.AddArg(CreateMemberExpression(['this',VarName]));
        Call.AddArg(CreateMemberExpression([EqualParamName,VarName]));
        end
      else if VarType is TPasProcedureType then
        begin
        // proc type
        // add "rtl.eqCallback(this.member,b.member)"
        Call:=CreateCallExpression(PasVar);
        Add_AndExpr_ToReturnSt(RetSt,PasVar,LastAndExpr,Call);
        Call.Expr:=CreateMemberExpression([FBuiltInNames[pbivnRTL],FBuiltInNames[pbifnProcType_Equal]]);
        Call.AddArg(CreateMemberExpression(['this',VarName]));
        Call.AddArg(CreateMemberExpression([EqualParamName,VarName]));
        end
      else
        begin
        // default: use simple equal "=="
        EqExpr:=TJSEqualityExpressionSEQ(CreateElement(TJSEqualityExpressionSEQ,PasVar));
        Add_AndExpr_ToReturnSt(RetSt,PasVar,LastAndExpr,EqExpr);
        EqExpr.A:=CreateMemberExpression(['this',VarName]);
        EqExpr.B:=CreateMemberExpression([EqualParamName,VarName]);
        end;
      end;
  end;

  procedure AddRTTIFields(Args: TJSArguments; var First, Last: TJSStatementList);
  var
    i: Integer;
    PasVar: TPasVariable;
    VarType: TPasType;
  begin
    for i:=0 to El.Members.Count-1 do
      begin
      PasVar:=TPasVariable(El.Members[i]);
      if not IsElementUsed(PasVar) then continue;
      VarType:=PasVar.VarType;
      if VarType.Name='' then
        CreateRTTIAnonymous(VarType,AContext,First,Last);
      // add quoted "fieldname"
      Args.AddElement(CreateLiteralString(PasVar,TransformVariableName(PasVar,AContext)));
      // add typeinfo ref
      Args.AddElement(CreateTypeInfoRef(VarType,AContext,PasVar));
      end;
  end;

var
  AssignSt: TJSSimpleAssignStatement;
  FDS: TJSFunctionDeclarationStatement;
  FD: TJSFuncDef;
  BodyFirst, BodyLast, ListFirst, ListLast: TJSStatementList;
  FuncContext: TFunctionContext;
  ObjLit: TJSObjectLiteral;
  ObjEl: TJSObjectLiteralElement;
  IfSt: TJSIfStatement;
  Call, Call2: TJSCallExpression;
  ok: Boolean;
begin
  Result:=nil;
  FuncContext:=nil;
  ListFirst:=nil;
  ListLast:=nil;
  ok:=false;
  try
    FDS:=CreateFunctionSt(El);
    if AContext is TObjectContext then
      begin
      // add 'TypeName: function(){}'
      ObjLit:=TObjectContext(AContext).JSElement as TJSObjectLiteral;
      Result:=ObjLit;
      ObjEl:=ObjLit.Elements.AddElement;
      ObjEl.Name:=TJSString(TransformVariableName(El,AContext));
      ObjEl.Expr:=FDS;
      end
    else
      begin
      // add 'this.TypeName = function(){}'
      AssignSt:=TJSSimpleAssignStatement(CreateElement(TJSSimpleAssignStatement,El));
      Result:=AssignSt;
      AssignSt.LHS:=CreateSubDeclNameExpr(El,El.Name,AContext);
      AssignSt.Expr:=FDS;
      end;
    FD:=FDS.AFunction;
    // add param s
    FD.Params.Add(SrcParamName);
    // create function body
    FuncContext:=TFunctionContext.Create(El,FD.Body,AContext);
    FuncContext.ThisPas:=El;
    FuncContext.IsGlobal:=true;
    if El.Members.Count>0 then
      begin
      BodyFirst:=nil;
      BodyLast:=nil;

      // add if(s)
      IfSt:=TJSIfStatement(CreateElement(TJSIfStatement,El));
      AddToStatementList(BodyFirst,BodyLast,IfSt,El);
      FD.Body.A:=BodyFirst;
      IfSt.Cond:=CreatePrimitiveDotExpr(SrcParamName,El);
      // add clone statements
      AddCloneStatements(IfSt,FuncContext);
      // add init default statements
      AddInitDefaultStatements(IfSt,FuncContext);

      // add equal function
      AddEqualFunction(BodyFirst,BodyLast,FuncContext);

      end;

    if HasTypeInfo(El,AContext) then
      begin
      // add $rtti as second statement
      if not (AContext is TFunctionContext) then
        RaiseNotSupported(El,AContext,20170412120012);

      AddToStatementList(ListFirst,ListLast,Result,El);
      Result:=nil;
      // module.$rtti.$Record("typename",{});
      Call:=CreateRTTINewType(El,FBuiltInNames[pbifnRTTINewRecord],false,AContext,ObjLit);
      if ObjLit=nil then
        RaiseInconsistency(20170412124804,El);
      if El.Members.Count>0 then
        begin
        // module.$rtti.$Record("typename",{}).addFields(
        //  "fieldname1",type1,"fieldname2",type2,...
        //  );
        Call2:=CreateCallExpression(El);
        Call2.Expr:=CreateDotExpression(El,Call,
          CreatePrimitiveDotExpr(FBuiltInNames[pbifnRTTIAddFields],El));
        Call:=Call2;
        AddRTTIFields(Call.Args,ListFirst,ListLast);
        end;
      AddToStatementList(ListFirst,ListLast,Call,El);
      Result:=ListFirst;
      ListFirst:=nil;
      ListLast:=nil;
      end;
    ok:=true;
  finally
    FuncContext.Free;
    if ListFirst<>nil then
      FreeAndNil(ListFirst)
    else if not ok then
      FreeAndNil(Result);
  end;
end;

procedure TPasToJSConverter.DoError(Id: int64; const Msg: String);
var
  E: EPas2JS;
begin
  E:=EPas2JS.Create(Msg);
  E.Id:=Id;
  E.MsgType:=mtError;
  Raise E;
end;

procedure TPasToJSConverter.DoError(Id: int64; const Msg: String;
  const Args: array of const);
var
  E: EPas2JS;
begin
  E:=EPas2JS.CreateFmt(Msg,Args);
  E.Id:=Id;
  E.MsgType:=mtError;
  Raise E;
end;

procedure TPasToJSConverter.DoError(Id: int64; MsgNumber: integer;
  const MsgPattern: string; const Args: array of const; El: TPasElement);
var
  E: EPas2JS;
begin
  E:=EPas2JS.CreateFmt(MsgPattern,Args);
  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.DoError ',id,' ',El.FullName,':',El.ClassName,' Msg="',E.Message,'"');
  {$ENDIF}
  E.PasElement:=El;
  E.MsgNumber:=MsgNumber;
  E.Id:=Id;
  E.MsgType:=mtError;
  CreateMsgArgs(E.Args,Args);
  raise E;
end;

procedure TPasToJSConverter.RaiseNotSupported(El: TPasElement;
  AContext: TConvertContext; Id: int64; const Msg: string);
var
  E: EPas2JS;
begin
  {$IFDEF VerbosePas2JS}
  writeln('TPasToJSConverter.RaiseNotSupported ',id,' ',El.FullName,':',El.ClassName,' Msg="',Msg,'"');
  {$ENDIF}
  if AContext=nil then ;
  E:=EPas2JS.CreateFmt(sPasElementNotSupported,[GetObjName(El)]);
  if Msg<>'' then
    E.Message:=E.Message+': '+Msg;
  E.PasElement:=El;
  E.MsgNumber:=nPasElementNotSupported;
  SetLength(E.Args,1);
  E.Args[0]:=El.ClassName;
  E.Id:=Id;
  E.MsgType:=mtError;
  raise E;
end;

procedure TPasToJSConverter.RaiseIdentifierNotFound(Identifier: string;
  El: TPasElement; Id: int64);
var
  E: EPas2JS;
begin
  E:=EPas2JS.CreateFmt(sIdentifierNotFound,[Identifier]);
  E.PasElement:=El;
  E.MsgNumber:=nIdentifierNotFound;
  SetLength(E.Args,1);
  E.Args[0]:=Identifier;
  E.Id:=Id;
  E.MsgType:=mtError;
  raise E;
end;

procedure TPasToJSConverter.RaiseInconsistency(Id: int64; El: TPasElement);
var
  s: String;
begin
  s:='TPasToJSConverter.RaiseInconsistency['+IntToStr(Id)+']: you found a bug';
  if El<>nil then
    begin
    s:=s+El.FullName;
    if El.Name<>'' then
      s:=s+El.Name
    else
      s:=s+GetElementTypeName(El);
    s:=s+' at '+TPas2JSResolver.GetDbgSourcePosStr(El);
    end;
  raise Exception.Create(s);
end;

function TPasToJSConverter.TransformVariableName(El: TPasElement;
  const AName: String; AContext: TConvertContext): String;
var
  i: Integer;
  c: Char;
begin
  if AContext=nil then ;
  if Pos('.',AName)>0 then
    RaiseInconsistency(20170203164711,El);
  if UseLowerCase then
    Result:=LowerCase(AName)
  else
    Result:=AName;
  if not IsPreservedWord(Result) then
    exit;
  for i:=1 to length(Result) do
    begin
    c:=Result[i];
    case c of
    'a'..'z','A'..'Z':
      begin
      Result[i]:=chr(ord(c) xor 32);
      if not IsPreservedWord(Result) then
        exit;
      end;
    end;
    end;
  RaiseNotSupported(El,AContext,20170203131832);
end;

function TPasToJSConverter.TransformVariableName(El: TPasElement;
  AContext: TConvertContext): String;
begin
  if (El is TPasProcedure) and (TPasProcedure(El).LibrarySymbolName<>nil) then
    Result:=ComputeConstString(TPasProcedure(El).LibrarySymbolName,AContext,true)
  else if (El is TPasVariable) and (TPasVariable(El).ExportName<>nil) then
    Result:=ComputeConstString(TPasVariable(El).ExportName,AContext,true)
  else if (El is TPasType) then
    Result:=TransformVariableName(El,AContext.Resolver.ResolveAliasType(TPasType(El)).Name,AContext)
  else
    Result:=TransformVariableName(El,El.Name,AContext);
end;

function TPasToJSConverter.TransformModuleName(El: TPasModule;
  AddModulesPrefix: boolean; AContext: TConvertContext): String;
var
  p, StartP: Integer;
  aName, Part: String;
begin
  if El is TPasProgram then
    Result:='program'
  else
    begin
    Result:='';
    aName:=El.Name;
    p:=1;
    while p<=length(aName) do
      begin
      StartP:=p;
      while (p<=length(aName)) and (aName[p]<>'.') do inc(p);
      Part:=copy(aName,StartP,p-StartP);
      Part:=TransformVariableName(El,Part,AContext);
      if Result<>'' then Result:=Result+'.';
      Result:=Result+Part;
      inc(p);
      end;
    end;
  if AddModulesPrefix then
    begin
    if Pos('.',Result)>0 then
      Result:=FBuiltInNames[pbivnModules]+'["'+Result+'"]'
    else
      Result:=FBuiltInNames[pbivnModules]+'.'+Result;
    end;
end;

function TPasToJSConverter.IsPreservedWord(const aName: string): boolean;
var
  l, r, m, cmp: Integer;
begin
  Result:=true;
  if aName=FBuiltInNames[pbivnModules] then exit;
  if aName=FBuiltInNames[pbivnRTL] then exit;

  // search default list
  l:=low(JSReservedWords);
  r:=high(JSReservedWords);
  while l<=r do
    begin
    m:=(l+r) div 2;
    cmp:=CompareStr(aName,JSReservedWords[m]);
    //writeln('TPasToJSConverter.IsPreservedWord Name="',aName,'" l=',l,' r=',r,' m=',m,' JSReservedWords[m]=',JSReservedWords[m],' cmp=',cmp);
    if cmp>0 then
      l:=m+1
    else if cmp<0 then
      r:=m-1
    else
      exit;
    end;

  // search user list
  l:=0;
  r:=length(FPreservedWords)-1;
  while l<=r do
    begin
    m:=(l+r) div 2;
    cmp:=CompareStr(aName,FPreservedWords[m]);
    //writeln('TPasToJSConverter.IsPreservedWord Name="',aName,'" l=',l,' r=',r,' m=',m,' FReservedWords[m]=',FReservedWords[m],' cmp=',cmp);
    if cmp>0 then
      l:=m+1
    else if cmp<0 then
      r:=m-1
    else
      exit;
    end;

  Result:=false;
end;

function TPasToJSConverter.GetTypeInfoName(El: TPasType;
  AContext: TConvertContext; ErrorEl: TPasElement): String;
var
  C: TClass;
  bt: TResolverBaseType;
  jbt: TPas2jsBaseType;
  CurEl: TPasElement;
  aName: String;
begin
  Result:='';
  El:=AContext.Resolver.ResolveAliasType(El);
  if El=nil then
    RaiseInconsistency(20170409172756,El);
  if El=AContext.PasElement then
    begin
    // referring to itself
    if El is TPasClassType then
      begin
      // use this
      Result:=FBuiltInNames[pbivnRTTILocal];
      exit;
      end
    else
      RaiseNotSupported(ErrorEl,AContext,20170905150746,'cannot typeinfo itself');
    end;
  C:=El.ClassType;
  if C=TPasUnresolvedSymbolRef then
    begin
    if El.Name='' then
      DoError(20170905150752,nTypeXCannotBePublished,sTypeXCannotBePublished,
        ['typeinfo of anonymous '+El.ElementTypeName],ErrorEl);
    if El.CustomData is TResElDataBaseType then
      begin
      bt:=TResElDataBaseType(El.CustomData).BaseType;
      case bt of
      btShortInt,btByte,
      btSmallInt,btWord,
      btLongint,btLongWord,
      btIntDouble,btUIntDouble,
      btString,btChar,
      btDouble,
      btBoolean,
      btPointer:
        begin
        // create rtl.basename
        Result:=FBuiltInNames[pbivnRTL]+'.'+lowercase(AContext.Resolver.BaseTypeNames[bt]);
        exit;
        end;
      btCustom:
        if El.CustomData is TResElDataPas2JSBaseType then
          begin
          jbt:=TResElDataPas2JSBaseType(El.CustomData).JSBaseType;
          case jbt of
          pbtJSValue:
            begin
            // create rtl.basename
            Result:=FBuiltInNames[pbivnRTL]+'.'+lowercase(Pas2jsBaseTypeNames[jbt]);
            exit;
            end;
          else
            {$IFDEF VerbosePas2JS}
            writeln('TPasToJSConverter.CreateTypeInfoRef [20170905150833] El=',GetObjName(El),' El.CustomData=',GetObjName(El.CustomData),' jbt=',Pas2jsBaseTypeNames[jbt]);
            {$ENDIF}
          end;
          end
        else
          begin
          {$IFDEF VerbosePas2JS}
          writeln('TPasToJSConverter.CreateTypeInfoRef [20170905150840] El=',GetObjName(El),' El.CustomData=',GetObjName(El.CustomData),' bt=',AContext.Resolver.BaseTypeNames[bt]);
          {$ENDIF}
          end
      else
        {$IFDEF VerbosePas2JS}
        writeln('TPasToJSConverter.CreateTypeInfoRef [20170905150842] El=',GetObjName(El),' El.CustomData=',GetObjName(El.CustomData),' bt=',AContext.Resolver.BaseTypeNames[bt]);
        {$ENDIF}
      end;
      end
    else
      begin
      {$IFDEF VerbosePas2JS}
      writeln('TPasToJSConverter.CreateTypeInfoRef [20170905150844] El=',GetObjName(El),' El.CustomData=',GetObjName(El.CustomData));
      {$ENDIF}
      end;
    end
  else if (C=TPasEnumType)
      or (C=TPasSetType)
      or (C=TPasClassType)
      or (C=TPasClassOfType)
      or (C=TPasArrayType)
      or (C=TPasProcedureType)
      or (C=TPasFunctionType)
      or (C=TPasPointerType)
      // ToDo or (C=TPasTypeAliasType)
      or (C=TPasRecordType)
      or (C=TPasRangeType)
      then
    begin
    // user type  ->  module.$rtti[typename]
    // Notes:
    // a nested type gets the parent types prepended: classnameA.ElName
    // an anonymous type gets for each level '$a' prepended
    // an anonymous type of a variable/argument gets the variable name prepended
    CurEl:=El;
    repeat
      if CurEl.Name<>'' then
        begin
        aName:=TransformVariableName(CurEl,AContext);
        if aName='' then
          RaiseNotSupported(CurEl,AContext,20170905144902,'name conversion failed');
        Result:=aName+Result;
        end
      else
        begin
        // anonymous type -> prepend '$a'
        // for example:
        //   "var AnArray: array of array of char;" becomes AnArray$a$a
        Result:=FBuiltInNames[pbitnAnonymousPostfix]+Result;
        end;
      CurEl:=CurEl.Parent;
      if CurEl=nil then
        break;
      C:=CurEl.ClassType;
      if (C=TPasClassType)
          or (C=TPasRecordType) then
        // nested
        Result:='.'+Result
      else if C.InheritsFrom(TPasType)
          or (C=TPasVariable)
          or (C=TPasConst)
          or (C=TPasArgument)
          or (C=TPasProperty) then
        begin
        // for example: var a: array of longint;
        end
      else
        break;
    until false;

    if CurEl is TPasSection then
      exit;
    end;
  aName:=El.Name;
  if aName='' then aName:=El.ClassName;
  DoError(20170409173329,nTypeXCannotBePublished,sTypeXCannotBePublished,
    [aName],ErrorEl);
end;

function TPasToJSConverter.ConvertPasElement(El: TPasElement;
  Resolver: TPas2JSResolver): TJSElement;
var
  aContext: TRootContext;
begin
  aContext:=TRootContext.Create(El,nil,nil);
  try
    aContext.Resolver:=Resolver;
    if (El.ClassType=TPasImplBeginBlock) then
      Result:=ConvertBeginEndStatement(TPasImplBeginBlock(El),AContext,false)
    else
      Result:=ConvertElement(El,aContext);
  finally
    FreeAndNil(aContext);
  end;
end;

var
  i: integer;
initialization
  for i:=low(JSReservedWords) to High(JSReservedWords)-1 do
    if CompareStr(JSReservedWords[i],JSReservedWords[i+1])>=0 then
      raise Exception.Create('20170203135442 '+JSReservedWords[i]+' >= '+JSReservedWords[i+1]);

end.

