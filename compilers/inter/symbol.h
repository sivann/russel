#ifndef SYMBOL_H
#define SYMBOL_H

/* Constants */
#define FRAME_START_NEGOFS      0
#define TRUE                    1
#define FALSE                   0
#define SEARCH_ALL_SCOPES       0
#define SEARCH_CURRENT_SCOPE    1

/* Enumeration for types */                     ////<<<<
typedef enum {  IntegerType, CharType, BooleanType, StringType } VarTypes;
                                                ////<<<<
typedef enum {  IntegerRet, CharRet, BooleanRet, StringRet, VoidRet } ReturnTypes;

/* Enumeration for symbol table entries */
typedef enum {  VariableEnt, FunctionEnt, ConstantEnt, 
                ParameterEnt, TemporaryEnt
             } EntityTypes;

/* Enumeration for passing parameters */
typedef enum {  ByValue, ByReference } PassModes;

typedef enum {  OK=1, DuplicateIdentifier } ReturnCodes;

typedef enum {  ExternalPrototype, FunctionBody, UnresolvedPrototype,
                CorrectlyResolved, WronglyResolved
             } RoutineTypes;

typedef unsigned char MBOOL;              ////<<<<
#endif
