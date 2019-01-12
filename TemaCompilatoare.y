%{
	#include <stdio.h>
    #include <string.h>
	#include <cstring>
	#include <iostream>
	#include <unistd.h>
	extern FILE* yyin;
	int yylex();
	int yyerror(const char *msg);
	char msg[500];

	class TVAR // tabela de simboli	
	{
	     char* nume;  //numele variabilei
	     int valoare; //valuarea variabilei
	     TVAR* next; 
	     bool are_val ; 

	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n); //exista in tabela de simboli ->a mai fost declarata
         void add(char* n, int v = -1); //add o variabila in tabela de simboli
         int getValue(char* n); //valoarea variabilei
	     void setValue(char* n, int v); //modificarea valorii
	     bool hasValue(const char *n) ; 

	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, int v)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
	 this->next = NULL;
	 this->are_val= false;
	}

	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	  this->are_val=false;
	}

	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }

    void TVAR::add(char* n, int v)
	 {
	   TVAR* elem = new TVAR(n, v);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	
	 }

    int TVAR::getValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->valoare;
	     tmp = tmp->next;
	   }
	   return -1;
	  }

	void TVAR::setValue(char* n, int v)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
			tmp->valoare = v;
			tmp->are_val=true ; 
			return;
	      }
	      tmp = tmp->next;
	    }

	  }
	  bool TVAR::hasValue(const char *n )
	  {

	  	TVAR* tmp = TVAR::head;
	   	while(tmp != NULL)
	  	{
	     	if(strcmp(tmp->nume,n) == 0)
	     	return tmp->are_val;
	     	tmp = tmp->next;
	   	}
	  	return -1;
	  }
	  

	TVAR* ts = NULL;
%}



%union { char* sir; int val; char lista_id[500]; } // yyval de tip sir pt numele variabilei si val pt valoarea acesteia 

%token TOK_EQUALS TOK_PROGRAM TOK_VAR TOK_BEGIN TOK_END TOK_INTEGER TOK_DIVIDE TOK_READ TOK_WRITE TOK_FOR TOK_DO TOK_TO TOK_ERROR 
%token <sir> TOK_ID
%token <val> TOK_INT
%type <val> EXP
%type <val> FACTOR
%type <val> TERM

%type <lista_id> ID_LIST


%start P

%left TOK_PLUS TOK_MINUS 

%left TOK_MULTIPLY TOK_DIVIDE//precedenta mai mare 

%locations	


%%
P 			: TOK_PROGRAM P_NAME TOK_VAR DEC_LIST TOK_BEGIN STMT_LIST TOK_END '.'
			

P_NAME 		: TOK_ID 
				
DEC_LIST 	: DEC
			{
				
			}
				
		  	  |
		   	  DEC_LIST';'DEC 
		   	  {
		   	  	

		   	  }
		   	

DEC    	 	: ID_LIST':'TYPE  //adaugam toate variabile coresp declaratiei in tabela de simboli
			{
				{
					char* id = strtok($1,",") ; 
					while(id!=NULL)
					{
						if(ts!=NULL)
						{
							if(ts->exists(id))
							{
								sprintf(msg," Eroare semantica : declaratie multipla a variabilei %s",id);
								yyerror(msg);
								
							}
							else
								ts->add(id);
						}
						else{
							ts= new TVAR() ; 
							ts->add(id);
						}
						id = strtok(NULL, ",") ; 
					}
					


				}
			}
				

TYPE 		: TOK_INTEGER

ID_LIST 	: TOK_ID 
				{
					
					strcpy($$,$1); 

				}
			  |
			  ID_LIST','TOK_ID
			  {
			  	
				strcat($$,","); //lista de id-uri este un sir de id-uri separate prin ","
				strcat($$,$3);
						
			  }
			
			  

STMT_LIST   : STMT
				{
					
				}
			  |
			  STMT_LIST';'STMT 
			  	{
					
				}
			  |
			  STMT_LIST error 
			  {
			  		sprintf(msg, "Eroare sintactica");

			  }

			 

STMT 		: ASSIGN 
			  |
			  READ 
			  |
			  WRITE 
			  |
			  FOR    
ASSIGN      : TOK_ID TOK_EQUALS EXP
			{

				if (ts==NULL || ts->exists($1)==0)
					{
							sprintf(msg,"%d:%d Eroare semantica : variabila %s nu a fost declarata" , @1.first_line,@1.first_column,$1);
							yyerror(msg);
								
					}
					else
					{
						ts->setValue($1,$3); //modificam valoarea in tabela de simboli 

					}
			}
				
EXP			: EXP TOK_PLUS TERM
			  {
			  	$$=$1+$3 ;
					

			  }
			  |
			
			  EXP TOK_MINUS TERM
			  {
			  	$$=$1-$3 ; 
			  	
			  }
			  
			  |
			  TERM
			  {
			  	$$=$1; 
			  	
			  }

TERM 		:  TERM TOK_DIVIDE FACTOR
				{
					if($3 == 0 )
					{
						sprintf(msg,"Eroare semantica; impartirea la 0\n" );
						yyerror(msg);
						
					}
					else
						$$ = $1/$3; 
					
				}
			 
			  |
			  TERM TOK_MULTIPLY FACTOR
			  {
			  	$$ = $1 *$3 ;
			  	
			  }

			  |
			   FACTOR 
			   {
			   	 $$ = $1 ;
			   	 
			   }
				
INDEX_EXP 	: TOK_ID TOK_EQUALS EXP TOK_TO EXP
				{
					if(ts == NULL || ts->exists($1) == 0) 
					{
						sprintf(msg,"Eroare semantica; variabila %s nu a fost declarata\n",$1 );
						yyerror(msg);
					 
					}
					

				}

			
FACTOR      : TOK_ID
				{
					if(ts == NULL || ts->hasValue($1) == false) 
					{
						sprintf(msg,"Eroare semantica; variabila %s nu a fost initializata\n",$1 );
						yyerror(msg);
						 
					}
					else
						$$  = ts->getValue($1) ; 
					
				}
				
			  | 
			  TOK_INT
			  {
			   $$ = $1 ;
			   

			  }
			  
			  |
			  EXP
			  {
			  	$$=$1 ; 

			  }
			 
READ 		: TOK_READ'('ID_LIST')'
				{
					char* id = strtok($3,",") ; 
					while(id!=NULL)
					{
						if(ts==NULL || ts->exists(id) == 0)
						{
							sprintf(msg,"Eroare semantica, variabila %s nu a fost declarata " , id);
					 		yyerror(msg);
					  		
						}
						else 
						{
							
							ts->setValue(id , 0) ;  //pt a stii ca e initializat
						}
						id = strtok(NULL,",");
					}
				}
			
WRITE       : TOK_WRITE'('ID_LIST')'
			{
				char* id = strtok($3,",") ;  
					while(id!=NULL) //verificam doar daca variabilele din lista au fost declarate
					{
						if(ts==NULL || ts->exists(id) == 0 )
						{
							sprintf(msg,"Eroare semantica, variabila %s nu a fost declarata " , id);
					 		yyerror(msg);
					  		
						}
						
						id = strtok(NULL,",");
					}
			}


FOR 		: TOK_FOR INDEX_EXP TOK_DO BODY 



BODY        : 
			  TOK_BEGIN STMT_LIST TOK_END
			 


%%	

int main(int argc , char* argv[])
{
	
	yyin = fopen(argv[1],"r");
	yyparse();
	
	
}

int yyerror(const char *msg)
{
	printf("Error: %s\n", msg);
	return 1;
}