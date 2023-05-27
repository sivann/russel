#include <stdio.h>
#ifdef DEBUGGING
#include <ctype.h>
#endif
#include "symbol.hpp"

// Methods for class Scope
Scope::Scope (Scope *enclos, char *szName, ErrorHandlerClass *eh, int nl)
{
  LocalNegofs = FRAME_START_NEGOFS;
  EnclosingScope = enclos;
  Entity = NULL;
  ErrorHandler = eh;
  NestingLevel = nl;
  if ((ScopeName = strdup(szName)) == NULL)
    ErrorHandler->Internal("Not enough memory");
}

//********************************************************
Scope::~Scope (void)
{
  SymbolTableEntry* tempEntity;

  while (Entity != NULL)
  {
    tempEntity = Entity;
    Entity = Entity->GetNext();
    if (tempEntity->WhatIs() == FunctionEnt) 
      if (((FunctionEntry *)tempEntity)->GetEntryType() == UnresolvedPrototype)
      {
    	char sztmp[120];
    	char *szp;
    	if (tempEntity->GetName()[0]>='0' && tempEntity->GetName()[0]<='9')
    	  szp = strchr(tempEntity->GetName(), '_') + 1;
    	else
    	  szp = tempEntity->GetName();

    	sprintf(sztmp, "Definition of function %s not found in scope of function %s\n",
    		    szp, ScopeName);
    	ErrorHandler->Error(sztmp);
      }

    if (tempEntity->WhatIs() != ParameterEnt)
      delete tempEntity;
  }
}

//********************************************************
ReturnCodes Scope::Insert(SymbolTableEntry* entry)
{                                                   
  SymbolTableEntry *tempEntity;                     
						    
  if (entry == NULL)
    ErrorHandler->Internal("Not enough memory");

  entry->SetNestingLevel(NestingLevel+1);

  if (Entity != NULL) {
    tempEntity = Entity;
    int bDone = 0;
    do {
       if (*entry == *tempEntity) {
          char sztmp[80];
	  sprintf(sztmp, "Duplicate identifier : %s", entry->GetName());
	  ErrorHandler->Error(sztmp);
	  return DuplicateIdentifier;
       }
       else if (tempEntity->GetNext() != NULL)
	  tempEntity = tempEntity->GetNext();
       else
          bDone = 1;
    }while (!bDone);

    tempEntity->SetNext(entry);
  }
  else
    Entity = entry;
  return OK;
}

//********************************************************
SymbolTableEntry* Scope::Lookup(char* name, int mode)
{
  SymbolTableEntry* tempEntity = Entity;

  while (tempEntity != NULL)
    if (*tempEntity == name)
      //check if it is a wrongly resolved prototype so as not to return it ...
      if (tempEntity->WhatIs() == FunctionEnt)
	if (((FunctionEntry *)tempEntity)->GetEntryType() == WronglyResolved)
	  tempEntity = tempEntity->GetNext();
	else
	  return tempEntity;

      else
	return tempEntity;
    else
      tempEntity = tempEntity->GetNext();

  if (mode == SEARCH_CURRENT_SCOPE)
    return NULL;

  // If not found in current scope, search enclosing scopes recursively
  if (EnclosingScope != NULL)
    return EnclosingScope->Lookup(name);
  else
    return NULL;
}

//********************************************************
int Scope::GetNegOffset(int space)
{
  return (LocalNegofs -= space);
}
//********************************************************
SymbolTableEntry* Scope::GetNextExternal(void)
{
  static SymbolTableEntry *p;
  static int nFlag = 0;

  if (nFlag == 0)
    p = Entity;

  if (p==NULL)
    return NULL;

  do {
    if (p->WhatIs() == FunctionEnt)
      if (((FunctionEntry *)p)->GetEntryType() == ExternalPrototype) {
	SymbolTableEntry *tmp = p;
	p = p->GetNext();
        nFlag++;
        return tmp;
      }

    p = p->GetNext();
  } while (p!=NULL);

  nFlag = 0;
  return NULL;
}


//********************************************************
// Methods for class SymbolTableClass
//********************************************************
SymbolTableClass::SymbolTableClass(ErrorHandlerClass *eh)
{
  CurrentScope = NULL;
  SetErrorHandler(eh);
}

//********************************************************

SymbolTableClass::~SymbolTableClass(void)
{
  while (CurrentScope != NULL)
    CloseScope();
}

//********************************************************
void SymbolTableClass::OpenScope(char *szName)
{
  if (CurrentScope == NULL)
    CurrentScope = new Scope(CurrentScope, szName, ErrorHandler, 0);
  else
    CurrentScope = new Scope(CurrentScope, szName, ErrorHandler,
			CurrentScope->GetNestingLevel()+1);

  if (CurrentScope == NULL)
    ErrorHandler->Internal("Not enough memory");
}

//********************************************************
void SymbolTableClass::CloseScope(void)
{
  Scope *tempScope = CurrentScope;

  CurrentScope = CurrentScope->GetEnclosing();
  delete tempScope;

  TemporaryEntry::ResetCounter();
}

//********************************************************
ReturnCodes SymbolTableClass::Insert(SymbolTableEntry *entry)
{
  if (CurrentScope != NULL)
    return CurrentScope->Insert(entry);

  ErrorHandler->Internal("No current scope");
  return OK;
}

//********************************************************
SymbolTableEntry *SymbolTableClass::Lookup(char *name, int mode)
{
  return CurrentScope->Lookup(name, mode);
}
//********************************************************
int SymbolTableClass::GetNestingLevelOf(char *name)
{
  SymbolTableEntry *tmp = CurrentScope->Lookup(name);
  if (tmp == NULL)
    ErrorHandler->Internal("Symbol not found during final code production.");

  return tmp->GetNestingLevel();
}


//********************************************************
// Methods for class SymbolTableEntry
SymbolTableEntry::SymbolTableEntry (char *name)
{
  EntryName = strdup(name);
  NextEntity = NULL;
}

//********************************************************
SymbolTableEntry::~SymbolTableEntry ()
{
  delete [] EntryName;
}

//********************************************************
int SymbolTableEntry::operator == (SymbolTableEntry & entry)
{
  return (strcmp(EntryName, entry.EntryName) == 0);
}

//********************************************************
int SymbolTableEntry::operator == (char *name)
{
  return (strcmp(EntryName, name) == 0);
}

//********************************************************
// Methods for class FunctionEntry
//********************************************************
int FunctionEntry::NextNumber = 1;
//********************************************************
FunctionEntry::FunctionEntry (char *name, ReturnTypes type) :
               SymbolTableEntry(name)
{
  Arguments = NULL;
  Number = NextNumber++;
  ReturnType = type;
}

//********************************************************
FunctionEntry::~FunctionEntry (void)
{
  ParameterEntry *arg = Arguments;

  while (arg != NULL) {
    ParameterEntry *tempArg = arg;

    arg = arg->GetNextPar();
    delete tempArg;
  }
}

//********************************************************
int FunctionEntry::operator == (SymbolTableEntry &entry)
{
  SymbolTableEntry *p = &entry;
  if (entry.WhatIs() == FunctionEnt)
    if (((((FunctionEntry *)p)->GetEntryType() == FunctionBody) && (EntryStatus != FunctionBody)) ||
        ((((FunctionEntry *)p)->GetEntryType() != FunctionBody) && (EntryStatus == FunctionBody)))
	return 0;

// Kai twra mporeite na pa na sigrithite ...
  return ((*this).SymbolTableEntry::operator==(entry));
}
//********************************************************
ParameterEntry* FunctionEntry::GetArgument(int index)
{
  ParameterEntry *tmp = Arguments;

  for ( ; index>1; index--)
    if (tmp->GetNextPar() != NULL)
      tmp = tmp->GetNextPar();
    else
      return NULL;

  return tmp;
}
//********************************************************
int FunctionEntry::GetSizeOfArguments(void)
{
  int   size;

  if (Arguments == NULL)
    return 0;

                ////<<<<
  size = Arguments->GetOffset();

  if (Arguments->GetMode()==ByReference)
     size -= 6;      // offset + 2 - 8
  else
    switch (Arguments->GetType()) {
    case CharType:
    case BooleanType:
        size -= 7;      // offset + 1 - 8
        break;
    case StringType:
        size += 8;      // offset + 16 - 8
        break;
    case IntegerType:
        size -= 6;      // offset + 2 - 8
    }

  return size;

/*
  return Arguments->GetOffset() +
        (Arguments->GetType() == StringType) ? 8 : -6;
                                        //    16-8  2-8
*/
/*
  return Arguments->GetOffset() - 6; // this is Offset - 8 + 2
				      	 // 8 is the offset of the last parameter,
				             // 2 is the size of the first
*/
}
//********************************************************
int FunctionEntry::GetTotalArguments(void)
{
  int index=0;
  ParameterEntry *tmp = Arguments;

  while (tmp != NULL)
    index++, tmp=tmp->GetNextPar();

  return index;
}
//********************************************************
int FunctionEntry::CompareArgumentsToThatOf(FunctionEntry *entry)
{
  int result=0;
  ParameterEntry *p1=Arguments, *p2=entry->Arguments;

  for (;;){
    if ((p1 == NULL) && (p2 == NULL))
      return 0;
    else if (p1 == NULL)
      return result + 1001;
    else if (p2 == NULL)
      return result + 2001;
    else if ((strcmp(p1->GetName(), p2->GetName())!=0) ||
             (p1->GetType() != p2->GetType()) ||
	       (p1->GetMode() != p2->GetMode()))
      return result+1;
    else {
      result++;
      p1 = p1->GetNextPar();
      p2 = p2->GetNextPar();
    }
  }
}
//********************************************************
void FunctionEntry::AddParameter(ParameterEntry* param)
{
   ParameterEntry *paramlist = Arguments, *last = NULL;

   while (paramlist != NULL)
   {                                            ////<<<<
        if ((param->GetType() == CharType || param->GetType() == BooleanType)
                && param->GetMode() == ByValue)
	  paramlist->MoveUp(1);
        else if (param->GetType() == StringType && param->GetMode() == ByValue)
          paramlist->MoveUp(16);            ////<<<<
        else
	  paramlist->MoveUp(2);

	last = paramlist;
	paramlist = paramlist->GetNextPar();
   }

   if (last == NULL)
      Arguments = param;
   else
      last->AddAfter(param);
}

//********************************************************
// Methods for class VariableEntry
//********************************************************
VariableEntry::VariableEntry(char *name, VarTypes type, Scope *current,
                             unsigned int dim, int isParam) :
   SymbolTableEntry(name)
{
  Type = type;
  Dimension = dim;

  if (!isParam) {                               ////<<<<
    int sizeForOne = (type == CharType || type == BooleanType) ? 1 : 2;

    if (type==StringType) sizeForOne = 16;      ////<<<<

    if (Dimension == 0)
        Offset = current->GetNegOffset(sizeForOne);
    else
        Offset = current->GetNegOffset(sizeForOne * Dimension);
  }
}

//**************************************************
// Methods for class ParameterEntry
//**************************************************
ParameterEntry::ParameterEntry(char *name, PassModes mode, VarTypes type,
			             FunctionEntry* unit, Scope *current,
                                     int isarray) :
   VariableEntry(name, type, current, (isarray != 0 ? 1 : 0), TRUE)
{
  PassMode = mode;
  NextParameter = NULL;
                                ////VVVV
  Offset = 8;
  //Offset = (((type==StringType) && (mode==ByValue)) ? 23 :      // = 8+16-1
  //              (((type==CharType) && (mode==ByValue)) ? 8 :    // = 8+1-1
  //              9));                                            // = 8+2-1
  unit->AddParameter(this);
}

//**************************************************
// Methods for class ConstantEntry
//**************************************************
int ConstantEntry::Counter = 1;
//**************************************************
ConstantEntry::ConstantEntry(int val, Scope *current) :
               VariableEntry("", IntegerType, current)
{
  char szTmp[80];
  sprintf(szTmp, "%d", val);
  SetName(szTmp);
  Value.i = val;
  Offset = current->GetNegOffset(-2);
} 
//**************************************************
ConstantEntry::ConstantEntry(char ch, Scope *current) :
               VariableEntry("", CharType, current)
{
  char szTmp[80];
  sprintf(szTmp, "@CHAR_%d", (int)ch);
  SetName(szTmp);
  Value.ch = ch;
  Offset = current->GetNegOffset(-1);
}
//**************************************************
ConstantEntry::ConstantEntry(char *str, Scope *current) :
	         VariableEntry("", CharType, current, strlen(str)+1)
{
  char szTmp[80];
  sprintf(szTmp, "@STRING_%d", Counter++);
  SetName(szTmp);
  Value.str = str;
  Offset = current->GetNegOffset(-strlen(str)-1);
}
ConstantEntry::ConstantEntry(MBOOL b, Scope *current) :          ////<<<<
                 VariableEntry("", BooleanType, current, 1)
{
  char szTmp[80];
  sprintf(szTmp, "@MBOOL_%d", Counter++);
  SetName(szTmp);
  Value.mbool = b;
  Offset = current->GetNegOffset(-1);
}

//**************************************************
// Methods for class TemporaryEntry
//**************************************************

int TemporaryEntry::Counter = 1;

//**************************************************
TemporaryEntry::TemporaryEntry (Scope *current, VarTypes TempType) :
		    VariableEntry("", TempType, current)
{
   char sztmp[10];
   sprintf(sztmp, "$%d", Counter);
   SetName(sztmp);
   Number = Counter++;
}
//**************************************************
// And now all print functions ...
//**************************************************
#ifdef DEBUGGING
void SymbolTableEntry::Print(ostream &str, char *)
{
  str << EntryName;
}
//--------------------------------------------------
void FunctionEntry::Print(ostream &str, char *leader)
{
  str << leader
      << (ReturnType == VoidRet    ? "void " :
          ReturnType == IntegerRet ? "integer " :
          ReturnType == BooleanRet ? "boolean ":
          ReturnType == CharRet ? "char " :
                                     "string");
  SymbolTableEntry::Print(str, "");
  str << "(\n";
  ParameterEntry *pars = Arguments;
  while (pars != NULL) {
    str << "    ";
    pars->Print(str, leader);
    pars = pars->GetNextPar();
  }
  str << leader << ")\n";
}
//--------------------------------------------------
void VariableEntry::Print(ostream &str, char *leader)
{
  str << leader
      << (Type == IntegerType ? "integer " :
          Type == BooleanType ? "boolean " :
          Type == CharType ? "char " :
                                "string");
  SymbolTableEntry::Print(str, "");
  if (Dimension != 0)
    str << '[' << Dimension << ']';
  str << '\n';
}
//--------------------------------------------------
void ConstantEntry::Print(ostream &str, char *leader)
{
  if (Type == IntegerType)
    str << leader << "INTEGER CONSTANT : " << Value.i << '\n';
  else if (Type == CharType && Dimension) {
    str << leader << "STRING CONSTANT : ";
    for (char *p = Value.str; *p; p++) {
      if (isascii(*p) && isprint(*p))
        str << *p;
      else
        str << '\\' << (int)(*p) << '\\';
    }
    str << '\n';
  }
  else
    if (isascii(Value.ch) && isprint(Value.ch))
      str << Value.ch;
    else
      str << '\\' << (int)(Value.ch) << '\\\n';
}
//--------------------------------------------------
void TemporaryEntry::Print(ostream &str, char *leader)
{
  str << leader
      << '$' << Number << '\n';
}
//--------------------------------------------------
void ParameterEntry::Print(ostream &str, char *leader)
{
  str << leader
      << (Type == IntegerType ? "integer " :
          Type == BooleanType ? "boolean " :
          Type == CharType ? "char " :
                                "string");
  if (PassMode == ByReference)
    str << '&';
  SymbolTableEntry::Print(str, "");
  if (Dimension != 0)
    str << "[]";
  str << '\n';
}
//--------------------------------------------------
void Scope::Print(ostream &str)
{
  char szTmp[80], *p=szTmp;
  for (int i=0; i<NestingLevel; i++)
    *(p++) = ' ', *(p++) = ' ', *(p++) = ' ', *(p++) = ' ';
  *p = 0;

  str << szTmp << "SCOPE : " << ScopeName << '\n';
  SymbolTableEntry *Entries = Entity;
  while (Entries != NULL) {
    if (Entries->WhatIs() != ParameterEnt)
      Entries->Print(str, szTmp);
    Entries = Entries->GetNext();
  }
}
//--------------------------------------------------
void SymbolTableClass::Print(ostream &str)
{
  Scope *sc = CurrentScope;
  while (sc != NULL) {
    sc->Print(str);
    sc = sc->GetEnclosing();
  }
}
#endif

