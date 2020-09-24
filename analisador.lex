%option noyywrap

%{

#include <string.h>
#include <stdbool.h>
#include <stdio.h>
#include <math.h>

const int MAX_IDS = 128;
const int MAX_ESCOPOS = 128;
char varIds[128][128][256] = {};

int idAtual = 0;

int ultimoEscopo = 0;
int profundidadeEscopos = 0;

bool tipoInformado = false;

// Implementação da pilha
struct Pilha {
	int topo;
	int capa;
	int *pElem;
};

void criarpilha(struct Pilha *p, int c){
   p->topo = -1;
   p->capa = c;
   p->pElem = (int*) malloc (c * sizeof(int));
}

void empilhar (struct Pilha *p, int v) {
	p->topo++;
	p->pElem [p->topo] = v;
}

int desempilharTopo (struct Pilha *p ) {
   int aux = p->pElem [p->topo];
   p->topo--;
   return aux;
}

int retornatopo (struct Pilha *p ) {
   return p->pElem [p->topo];
}

int retornarposicao(struct Pilha *p, int indice) {
	return p->pElem [p->topo - indice];
}

struct Pilha pilhaEscopos;

%}

PONTO_E_VIRGULA ;
VIRGULA ,

PAREN_ESQUERDO "("
PAREN_DIREITO ")"
CHAVE_ESQUERDA "{"
CHAVE_DIREITA "}"

TIPO int|char|double|float|void|long|[sS]tring|bool
PALAVRA_RESERVADA {TIPO}|do|while|if|else|switch|for|return|null|break|case|default|goto|auto|signed|const|extern|register|unsigned|continue|sizeof|struct|typedef|NULL
OP_ATRIBUICAO =
DIGIT [0-9]

OP_RELACIONAL "<"|">"|"<="|">="|"=="|"!="
OP_LOGICO "||"|"&&"
OP_ARITMETICO "+"|"-"|"*"|"/"|"++"|"--"

STRING_LITERAL \"([^\\\"]|\\.)*\"

COMENTARIO_LINHA "//"[^{\n}][^\r\n]*
COMENTARIO_BLOCO "/*"([^*]|\*+[^*/])*\*+"/"

ID        [A-Za-z_][A-Za-z_0-9]*
ESPACO   	[ \t\f\r\n]*

VAR_SIMPLES {ID}

INCLUDE "#include <"{ID}(\.{ID})*">"

%%
{COMENTARIO_BLOCO}
{COMENTARIO_LINHA} 

{INCLUDE} { printf("[include, %s]\n", yytext); }

{TIPO}{ESPACO}/{VAR_SIMPLES} {	
	tipoInformado = true;
    REJECT;
}

{ID}/"[]" {
	REJECT;
}

{ID}{ESPACO}/"*" {
	REJECT;
}

{PALAVRA_RESERVADA} { printf("[reserved_word, %s]\n", yytext); }

{OP_ATRIBUICAO} { printf("[Equal_Op, =]\n"); }

{DIGIT}+|{DIGIT}+"."{DIGIT}+ { printf("[num, %s]\n", yytext); }

{PONTO_E_VIRGULA} { printf("[semicolon, %s]\n", yytext); }
{VIRGULA} { printf("[comma, %s]\n", yytext); }

{CHAVE_ESQUERDA} {
	printf("[l_bracket, %s]\n", yytext);
	profundidadeEscopos++;
	empilhar(&pilhaEscopos, ++ultimoEscopo);
}

{CHAVE_DIREITA} {
	printf("[r_bracket, %s]\n\n", yytext);
	profundidadeEscopos--;

	desempilharTopo(&pilhaEscopos);
}

{PAREN_ESQUERDO} { printf("[l_paren, %s]\n", yytext); }

{PAREN_DIREITO} { printf("[r_paren, %s]\n", yytext); }

{OP_RELACIONAL} { printf("[relational_op, %s]\n", yytext);}
{OP_LOGICO} { printf("[logic_op, %s]\n", yytext);}
{OP_ARITMETICO} { printf("[arith_op, %s]\n", yytext);}
{STRING_LITERAL} { printf("[string_literal, %s]\n", yytext); }

"&"|"[]"

{VAR_SIMPLES} {
	bool idExiste = false;

	// Se não tiver informado um tipo, p.e.: "a = 2;"
	if(!tipoInformado) {
		// Procuramos pelo id em todos os escopos de trás pra frente (começando pelo mais atual)			
		for(int indiceEscopo = profundidadeEscopos; indiceEscopo >= 0; indiceEscopo--) { 
			
			int escopo = (&pilhaEscopos)->pElem[indiceEscopo];

			for(int i = 0; i < MAX_IDS; i++) {
				if(strcmp(&yytext[0], varIds[escopo][i]) == 0) {
					printf("[id (%s), %d]\n", yytext, i);
					idExiste = true;
					break;
				}
			}

			if(idExiste) break;
		}
	}

	tipoInformado = false;

	// Se o id não existir (ou se for uma declaração com tipo + id), criamos ele no último escopo
	if(!idExiste){
		int uEscopo = retornatopo(&pilhaEscopos);
		strcpy(varIds[uEscopo][idAtual], &yytext[0]);
		printf("[id (%s), %d]\n", yytext, idAtual);
		idAtual++;
	}

}

[ \t\n]+	


%%

int main(int argc, char *argv[]){
	
	criarpilha(&pilhaEscopos, MAX_ESCOPOS);
	empilhar(&pilhaEscopos, ultimoEscopo);

	yyin = fopen(argv[1], "r");
	yylex();
	fclose(yyin);
	return 0;
}